import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../services/property_store.dart';
import '../../services/advertisement_store.dart';
import 'advertisement_editor_screen.dart';

/// Owner Admin Panel — Premium Dashboard Design
/// Sidebar (desktop) / bottom nav (mobile) with rich inner pages
class OwnerAdminScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onViewAsUser;

  const OwnerAdminScreen({super.key, this.onLogout, this.onViewAsUser});

  @override
  State<OwnerAdminScreen> createState() => _OwnerAdminScreenState();
}

class _OwnerAdminScreenState extends State<OwnerAdminScreen> {
  int _selectedTab = 0;
  bool _isLoading = false;

  /// Build image widget that supports both base64 data URIs and network URLs
  Widget _buildPropImage(String url, IconData fallbackIcon) {
    if (url.startsWith('data:image/')) {
      try {
        final b64 = url.split(',').last;
        return Image.memory(base64Decode(b64), fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: const Color(0xFFCBD5E1)));
      } catch (_) {
        return Icon(fallbackIcon, color: const Color(0xFFCBD5E1));
      }
    }
    return Image.network(url, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(fallbackIcon, color: const Color(0xFFCBD5E1)));
  }
  String _propertyFilter = 'All';
  String _propertySearch = '';
  String _userSearch = '';
  String _userFilter = 'All';
  String _spSearch = '';
  String _spFilter = 'All';
  final _searchController = TextEditingController();
  final _userSearchController = TextEditingController();
  final _spSearchController = TextEditingController();

  // Settings toggles
  bool _notifNewListing = true;
  bool _notifNewUser = true;
  bool _notifPendingAlert = false;
  bool _autoVerifyOwner = false;
  bool _autoVerifyDealer = false;
  bool _maintenanceMode = false;

  // Data getters
  int get _totalProperties => PropertyStore.instance.properties.length;
  int get _activeProperties =>
      PropertyStore.instance.properties.where((p) => p.isVerified).length;
  int get _pendingProperties => _totalProperties - _activeProperties;
  final int _totalUsers = 156;
  int get _totalAds => AdvertisementStore.instance.ads.length;

  List<dynamic> get _filteredProperties {
    var props = PropertyStore.instance.properties;
    if (_propertyFilter == 'Active') {
      props = props.where((p) => p.isVerified).toList();
    } else if (_propertyFilter == 'Pending') {
      props = props.where((p) => !p.isVerified).toList();
    }
    if (_propertySearch.isNotEmpty) {
      final q = _propertySearch.toLowerCase();
      props = props
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.city.toLowerCase().contains(q))
          .toList();
    }
    return props;
  }

  static const _mockUsers = [
    _UserItem('Rahul Sharma', 'rahul@gmail.com', '+91 98765 43210',
        3, 'Owner', true, 'Nov 15, 2025'),
    _UserItem('Priya Verma', 'priya@gmail.com', '+91 87654 32109',
        1, 'Buyer', true, 'Dec 03, 2025'),
    _UserItem('Amit Reddy', 'amit@gmail.com', '+91 76543 21098',
        5, 'Dealer', true, 'Jan 20, 2026'),
    _UserItem('Sneha Iyer', 'sneha@gmail.com', '+91 65432 10987',
        2, 'Owner', false, 'Feb 08, 2026'),
    _UserItem('Vikram Das', 'vikram@gmail.com', '+91 54321 09876',
        0, 'Buyer', true, 'Mar 01, 2026'),
    _UserItem('Meera Patel', 'meera@gmail.com', '+91 43210 98765',
        4, 'Dealer', true, 'Mar 15, 2026'),
    _UserItem('Kiran Rao', 'kiran@gmail.com', '+91 98712 34567',
        1, 'Owner', true, 'Mar 22, 2026'),
    _UserItem('Ananya Nair', 'ananya@gmail.com', '+91 87612 45678',
        0, 'Buyer', false, 'Mar 25, 2026'),
  ];

  static const _mockProviders = [
    _ServiceProviderItem('Rajesh Kumar', 'rajesh@packers.com', '+91 98765 11111', 'Packers & Movers', 4.8, 156, '₹2.4L', true, 'Oct 10, 2025'),
    _ServiceProviderItem('Lakshmi Devi', 'lakshmi@cleaning.com', '+91 87654 22222', 'Home Cleaning', 4.6, 89, '₹1.1L', true, 'Nov 22, 2025'),
    _ServiceProviderItem('Mohammed Ali', 'ali@painting.com', '+91 76543 33333', 'Home Painting', 4.9, 203, '₹3.8L', true, 'Sep 05, 2025'),
    _ServiceProviderItem('Sunita Rao', 'sunita@interior.com', '+91 65432 44444', 'Interior Design', 4.7, 67, '₹5.2L', true, 'Dec 15, 2025'),
    _ServiceProviderItem('Arjun Nair', 'arjun@legal.com', '+91 54321 55555', 'Legal Help', 4.5, 112, '₹4.1L', false, 'Jan 08, 2026'),
    _ServiceProviderItem('Deepa Sharma', 'deepa@repair.com', '+91 43210 66666', 'Home Repair', 4.3, 45, '₹0.8L', true, 'Feb 20, 2026'),
    _ServiceProviderItem('Venkat Reddy', 'venkat@vastu.com', '+91 32109 77777', 'Vastu Consultation', 4.4, 78, '₹1.9L', true, 'Mar 01, 2026'),
    _ServiceProviderItem('Preethi Das', 'preethi@loan.com', '+91 21098 88888', 'Home Loan', 4.2, 34, '₹0.5L', false, 'Mar 18, 2026'),
  ];

  int get _totalProviders => _mockProviders.length;

  List<_ServiceProviderItem> get _filteredProviders {
    var providers = _mockProviders.toList();
    if (_spFilter == 'Active') {
      providers = providers.where((p) => p.isActive).toList();
    } else if (_spFilter == 'Inactive') {
      providers = providers.where((p) => !p.isActive).toList();
    } else if (_spFilter != 'All') {
      providers = providers.where((p) => p.service == _spFilter).toList();
    }
    if (_spSearch.isNotEmpty) {
      final q = _spSearch.toLowerCase();
      providers = providers.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.email.toLowerCase().contains(q) ||
          p.service.toLowerCase().contains(q)).toList();
    }
    return providers;
  }

  List<_UserItem> get _filteredUsers {
    var users = _mockUsers.toList();
    if (_userFilter == 'Active') {
      users = users.where((u) => u.isActive).toList();
    } else if (_userFilter == 'Inactive') {
      users = users.where((u) => !u.isActive).toList();
    } else if (_userFilter == 'Owner' || _userFilter == 'Buyer' || _userFilter == 'Dealer') {
      users = users.where((u) => u.role == _userFilter).toList();
    }
    if (_userSearch.isNotEmpty) {
      final q = _userSearch.toLowerCase();
      users = users
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }
    return users;
  }

  void _refreshData() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _userSearchController.dispose();
    _spSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 768;
    if (_isLoading) return _buildLoadingState();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  // ─── Loading ──────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
              ),
            ),
            const SizedBox(height: 20),
            Text('Loading Dashboard...', style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildSidebar(),
        Expanded(
          child: Column(
            children: [_buildTopBar(), Expanded(child: _buildPageContent())],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    final navItems = [
      _NavItem('Dashboard', Icons.dashboard_rounded),
      _NavItem('Properties', Icons.home_work_rounded),
      _NavItem('Users', Icons.people_rounded),
      _NavItem('Service Providers', Icons.home_repair_service_rounded),
      _NavItem('Analytics', Icons.insights_rounded),
      _NavItem('Settings', Icons.settings_rounded),
    ];
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YEstateHub', style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w800)),
                      Text('Admin Panel', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
          // Overview label
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
            child: Text('OVERVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.2)),
          ),
          // Nav items
          ...List.generate(navItems.length, (i) {
            final item = navItems[i];
            final isSelected = _selectedTab == i;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _selectedTab = i),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
                    ),
                    child: Row(
                      children: [
                        Icon(item.icon, size: 20, color: isSelected ? AppColors.primary : AppColors.textTertiary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(item.label, style: AppTypography.labelLarge.copyWith(
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          )),
                        ),
                        if (i == 1 && _pendingProperties > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                            child: Text('$_pendingProperties', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B))),
                          ),
                        if (i == 2)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text('$_totalUsers', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
                          ),
                        if (i == 3)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFF06B6D4).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: Text('$_totalProviders', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF06B6D4))),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 6),
            child: Text('TOOLS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 1.2)),
          ),
          // Advertisements nav
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvertisementEditorScreen())),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign_rounded, size: 20, color: AppColors.textTertiary),
                      const SizedBox(width: 12),
                      Expanded(child: Text('Advertisements', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFD97706).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text('$_totalAds', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFD97706))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Divider(color: AppColors.border, height: 1),
          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _sidebarAction(Icons.visibility_rounded, 'View as User', () => widget.onViewAsUser?.call()),
                const SizedBox(height: 4),
                _sidebarAction(Icons.logout_rounded, 'Logout', () => widget.onLogout?.call(), color: AppColors.error),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarAction(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final c = color ?? AppColors.textSecondary;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: c),
              const SizedBox(width: 12),
              Text(label, style: AppTypography.labelMedium.copyWith(color: c, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final titles = ['Dashboard', 'Properties', 'Users', 'Service Providers', 'Analytics', 'Settings'];
    final subtitles = [
      'Overview of your platform',
      'Manage all listed properties',
      'Manage registered users',
      'Manage service provider accounts',
      'Platform performance metrics',
      'Configure your platform',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titles[_selectedTab], style: AppTypography.headingLarge.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(subtitles[_selectedTab], style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
            ],
          ),
          const Spacer(),
          _topBarBtn(Icons.refresh_rounded, _refreshData),
          const SizedBox(width: 10),
          _topBarBtn(Icons.notifications_outlined, () {}),
          const SizedBox(width: 16),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))),
          ),
        ],
      ),
    );
  }

  Widget _topBarBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildMobileHeader(),
        Expanded(child: _buildPageContent()),
        _buildBottomNav(),
      ],
    );
  }

  Widget _buildMobileHeader() {
    final titles = ['Dashboard', 'Properties', 'Users', 'Providers', 'Analytics', 'Settings'];
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => widget.onViewAsUser?.call(),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(titles[_selectedTab], style: AppTypography.headingMedium.copyWith(fontWeight: FontWeight.w800))),
          _topBarBtn(Icons.refresh_rounded, _refreshData),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textSecondary),
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (v) { if (v == 'logout') widget.onLogout?.call(); },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'ads', child: Row(children: [Icon(Icons.campaign_rounded, size: 18, color: Color(0xFFD97706)), SizedBox(width: 10), Text('Advertisements')])),
              const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)), SizedBox(width: 10), Text('Logout')])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      _NavItem('Home', Icons.dashboard_rounded),
      _NavItem('Properties', Icons.home_work_rounded),
      _NavItem('Users', Icons.people_rounded),
      _NavItem('Providers', Icons.home_repair_service_rounded),
      _NavItem('Analytics', Icons.insights_rounded),
      _NavItem('Settings', Icons.settings_rounded),
    ];
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 4, top: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isSelected = _selectedTab == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48, height: 32,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(item.icon, size: 22, color: isSelected ? AppColors.primary : AppColors.textTertiary),
                        if (i == 1 && _pendingProperties > 0)
                          Positioned(top: 2, right: 6, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(item.label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.primary : AppColors.textTertiary), maxLines: 1),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PAGE ROUTER
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildPageContent() {
    switch (_selectedTab) {
      case 0: return _buildDashboard();
      case 1: return _buildPropertiesTab();
      case 2: return _buildUsersTab();
      case 3: return _buildServiceProvidersTab();
      case 4: return _buildAnalyticsTab();
      case 5: return _buildSettingsTab();
      default: return const SizedBox.shrink();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TAB 0: DASHBOARD
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildDashboard() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final pad = isMobile ? 16.0 : 28.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner with gradient + illustration
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('Admin Dashboard', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 14),
                      Text('Welcome back!', style: AppTypography.headingLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: isMobile ? 22 : 28)),
                      const SizedBox(height: 8),
                      Text('Here\'s what\'s happening on your platform today. You have $_pendingProperties pending reviews.', style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9), height: 1.5)),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _welcomeActionBtn('Review Pending', Icons.pending_actions_rounded, () {
                            setState(() { _selectedTab = 1; _propertyFilter = 'Pending'; });
                          }),
                          const SizedBox(width: 10),
                          _welcomeActionBtn('View Analytics', Icons.insights_rounded, () {
                            setState(() => _selectedTab = 4);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 24),
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(24)),
                    child: const Icon(Icons.space_dashboard_rounded, size: 56, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats grid
          _buildStatsGrid(isMobile),
          const SizedBox(height: 24),

          // Two-column layout on desktop
          if (!isMobile)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: Column(children: [_buildQuickActions(), const SizedBox(height: 20), _buildRecentListings()])),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: Column(children: [_buildRecentActivity(), const SizedBox(height: 20), _buildPlatformHealth()])),
              ],
            )
          else ...[
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildRecentActivity(),
            const SizedBox(height: 20),
            _buildRecentListings(),
            const SizedBox(height: 20),
            _buildPlatformHealth(),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _welcomeActionBtn(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.3))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isMobile) {
    final stats = [
      _StatData('Total Listings', '$_totalProperties', Icons.home_work_rounded, const Color(0xFF10B981), '+12% this month', Icons.trending_up_rounded),
      _StatData('Active', '$_activeProperties', Icons.check_circle_rounded, const Color(0xFF3B82F6), 'Verified listings', Icons.verified_rounded),
      _StatData('Pending Review', '$_pendingProperties', Icons.schedule_rounded, const Color(0xFFF59E0B), 'Awaiting approval', Icons.hourglass_top_rounded),
      _StatData('Total Users', '$_totalUsers', Icons.people_rounded, const Color(0xFF8B5CF6), '+8% this month', Icons.trending_up_rounded),
      _StatData('Providers', '$_totalProviders', Icons.home_repair_service_rounded, const Color(0xFF06B6D4), '${_mockProviders.where((p) => p.isActive).length} active', Icons.engineering_rounded),
    ];
    if (isMobile) {
      return Column(children: [
        Row(children: [Expanded(child: _buildStatCard(stats[0])), const SizedBox(width: 12), Expanded(child: _buildStatCard(stats[1]))]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: _buildStatCard(stats[2])), const SizedBox(width: 12), Expanded(child: _buildStatCard(stats[3]))]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: _buildStatCard(stats[4])), const SizedBox(width: 12), const Expanded(child: SizedBox())]),
      ]);
    }
    return Column(children: [
      Row(children: stats.take(4).map((s) => Expanded(child: _buildStatCard(s))).toList().expand((w) => [w, const SizedBox(width: 16)]).toList()..removeLast()),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: _buildStatCard(stats[4])), const SizedBox(width: 16), const Expanded(child: SizedBox()), const SizedBox(width: 16), const Expanded(child: SizedBox()), const SizedBox(width: 16), const Expanded(child: SizedBox())]),
    ]);
  }

  Widget _buildStatCard(_StatData stat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stat.color.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: stat.color.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: stat.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(stat.icon, size: 22, color: stat.color),
            ),
            const Spacer(),
            Icon(stat.trendIcon, size: 16, color: stat.color.withOpacity(0.6)),
          ]),
          const SizedBox(height: 16),
          Text(stat.value, style: AppTypography.displaySmall.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(stat.label, style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(stat.badge, style: AppTypography.bodySmall.copyWith(color: stat.color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return _sectionCard('Quick Actions', Icons.flash_on_rounded, const Color(0xFFF59E0B), children: [
      _quickActionTile('Review Pending Properties', '$_pendingProperties awaiting approval', Icons.pending_actions_rounded, const Color(0xFFF59E0B), () => setState(() { _selectedTab = 1; _propertyFilter = 'Pending'; })),
      _quickActionTile('Manage Users', '$_totalUsers registered accounts', Icons.manage_accounts_rounded, const Color(0xFF3B82F6), () => setState(() => _selectedTab = 2)),
      _quickActionTile('Manage Advertisements', '${_totalAds} ads configured', Icons.campaign_rounded, const Color(0xFFD97706), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvertisementEditorScreen()))),
      _quickActionTile('Service Providers', '$_totalProviders registered providers', Icons.home_repair_service_rounded, const Color(0xFF06B6D4), () => setState(() => _selectedTab = 3)),
      _quickActionTile('Platform Settings', 'Configure notifications & security', Icons.tune_rounded, const Color(0xFF10B981), () => setState(() => _selectedTab = 5)),
    ]);
  }

  Widget _buildRecentListings() {
    final recentProps = PropertyStore.instance.properties.take(3).toList();
    return _sectionCard('Recent Listings', Icons.list_alt_rounded, const Color(0xFF10B981), children: [
      if (recentProps.isEmpty)
        Padding(padding: const EdgeInsets.all(20), child: Center(child: Text('No listings yet', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary))))
      else
        ...recentProps.map((p) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 52, height: 52, color: const Color(0xFFE2E8F0),
                child: p.images.isNotEmpty
                  ? _buildPropImage(p.images.first, Icons.home_rounded)
                  : const Icon(Icons.home_rounded, color: Color(0xFFCBD5E1)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.title, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text('${p.locality}, ${p.city}', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: p.isVerified ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(p.isVerified ? 'Active' : 'Pending', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: p.isVerified ? const Color(0xFF10B981) : const Color(0xFFF59E0B))),
            ),
          ]),
        )),
    ]);
  }

  Widget _buildRecentActivity() {
    final activities = [
      _Activity('New property listed', 'Luxury Villa in Jubilee Hills', Icons.add_home_rounded, const Color(0xFF10B981), '2m ago'),
      _Activity('User registered', 'Meera Patel joined the platform', Icons.person_add_rounded, const Color(0xFF3B82F6), '15m ago'),
      _Activity('Property approved', '3BHK Apartment in Gachibowli', Icons.verified_rounded, const Color(0xFF8B5CF6), '1h ago'),
      _Activity('Ad published', 'New banner ad created', Icons.campaign_rounded, const Color(0xFFD97706), '2h ago'),
      _Activity('Review pending', 'Plot in Kompally', Icons.schedule_rounded, const Color(0xFFF59E0B), '3h ago'),
    ];
    return _sectionCard('Recent Activity', Icons.history_rounded, const Color(0xFF3B82F6), children: [
      ...activities.map((a) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: a.color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(a.icon, size: 18, color: a.color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.title, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(a.subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
            child: Text(a.time, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
          ),
        ]),
      )),
    ]);
  }

  Widget _buildPlatformHealth() {
    final approvalRate = _totalProperties > 0 ? (_activeProperties / _totalProperties * 100) : 0.0;
    return _sectionCard('Platform Health', Icons.monitor_heart_rounded, const Color(0xFF8B5CF6), children: [
      _healthRow('Approval Rate', '${approvalRate.toStringAsFixed(0)}%', approvalRate / 100, const Color(0xFF10B981)),
      const SizedBox(height: 14),
      _healthRow('User Growth', '78%', 0.78, const Color(0xFF3B82F6)),
      const SizedBox(height: 14),
      _healthRow('Response Time', '92%', 0.92, const Color(0xFF8B5CF6)),
      const SizedBox(height: 14),
      _healthRow('Uptime', '99.9%', 0.999, const Color(0xFF10B981)),
    ]);
  }

  Widget _healthRow(String label, String value, double progress, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(label, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: color)),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.1), color: color, minHeight: 6),
      ),
    ]);
  }

  // Reusable section card
  Widget _sectionCard(String title, IconData icon, Color color, {required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(title, style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 18),
        ...children,
      ]),
    );
  }

  Widget _quickActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent, borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap, borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: color.withOpacity(0.15)), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
              ])),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: color),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TAB 1: PROPERTIES
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildPropertiesTab() {
    final props = _filteredProperties;
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('All Properties', style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${props.length} properties found', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ])),
          // Stats mini badges
          _miniBadge('$_activeProperties Active', const Color(0xFF10B981)),
          const SizedBox(width: 8),
          _miniBadge('$_pendingProperties Pending', const Color(0xFFF59E0B)),
        ]),
        const SizedBox(height: 18),
        // Search
        TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _propertySearch = v),
          decoration: _searchDecoration('Search by name, city, or locality...'),
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 14),
        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: ['All', 'Active', 'Pending'].map((f) {
            final isSelected = _propertyFilter == f;
            final chipColor = f == 'Active' ? const Color(0xFF10B981) : f == 'Pending' ? const Color(0xFFF59E0B) : AppColors.textSecondary;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _propertyFilter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? chipColor : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: isSelected ? chipColor : AppColors.border),
                    boxShadow: isSelected ? [BoxShadow(color: chipColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))] : null,
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (f != 'All') ...[
                      Icon(f == 'Active' ? Icons.check_circle_rounded : Icons.schedule_rounded, size: 14, color: isSelected ? Colors.white : chipColor),
                      const SizedBox(width: 6),
                    ],
                    Text(f, style: AppTypography.labelMedium.copyWith(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            );
          }).toList()),
        ),
        const SizedBox(height: 20),
        if (props.isEmpty)
          _emptyState(Icons.home_work_outlined, 'No properties found', 'Try adjusting your filters')
        else
          ...List.generate(props.length, (i) => _buildPropertyCard(props[i], i)),
      ]),
    );
  }

  Widget _buildPropertyCard(dynamic p, int index) {
    final isActive = p.isVerified;
    final statusColor = isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: statusColor.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: isMobile ? 72 : 100, height: isMobile ? 72 : 100,
              color: const Color(0xFFF1F5F9),
              child: p.images.isNotEmpty
                ? _buildPropImage(p.images.first, Icons.home_work_rounded)
                : const Icon(Icons.home_work_rounded, size: 28, color: Color(0xFFCBD5E1)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(p.title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isActive ? Icons.check_circle_rounded : Icons.schedule_rounded, size: 12, color: statusColor),
                  const SizedBox(width: 4),
                  Text(isActive ? 'Active' : 'Pending', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                ]),
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Expanded(child: Text('${p.locality}, ${p.city}', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: [
              _tagChip(p.transactionType.toString().split('.').last.toUpperCase(), const Color(0xFF3B82F6)),
              _tagChip(p.propertyType.toString().split('.').last, const Color(0xFF8B5CF6)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(p.formattedPrice, style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _actionChip(isActive ? 'Revoke' : 'Approve', isActive ? Icons.pause_circle_outline_rounded : Icons.check_circle_outline_rounded, isActive ? const Color(0xFFF59E0B) : const Color(0xFF10B981), () => _showSnackBar(isActive ? 'Property revoked' : 'Property approved', statusColor)),
              const SizedBox(width: 6),
              _actionChip('View', Icons.visibility_outlined, const Color(0xFF3B82F6), () {}),
              const SizedBox(width: 6),
              _actionChip('Delete', Icons.delete_outline_rounded, const Color(0xFFEF4444), () => _showDeleteDialog(p.title)),
            ]),
          ])),
        ]),
      ),
    );
  }

  Widget _tagChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _actionChip(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent, borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.15))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      ),
    );
  }

  void _showDeleteDialog(String name) {
    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.delete_forever_rounded, size: 28, color: Color(0xFFEF4444))),
        const SizedBox(height: 16),
        Text('Delete Property?', style: AppTypography.headingSmall),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.06), borderRadius: BorderRadius.circular(10)), child: Text(name, style: AppTypography.labelMedium.copyWith(color: const Color(0xFFEF4444)), textAlign: TextAlign.center)),
        const SizedBox(height: 8),
        Text('This action cannot be undone.', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.border))), child: Text('Cancel', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(context); _showSnackBar('Property deleted', const Color(0xFFEF4444)); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0), child: const Text('Delete'))),
        ]),
      ])),
    ));
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TAB 2: USERS
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildUsersTab() {
    final users = _filteredUsers;
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Registered Users', style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${users.length} users found', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ])),
          _miniBadge('${_mockUsers.where((u) => u.isActive).length} Active', const Color(0xFF10B981)),
          const SizedBox(width: 8),
          _miniBadge('${_mockUsers.where((u) => !u.isActive).length} Inactive', const Color(0xFFF59E0B)),
        ]),
        const SizedBox(height: 18),
        // Search
        TextField(
          controller: _userSearchController,
          onChanged: (v) => setState(() => _userSearch = v),
          decoration: _searchDecoration('Search by name or email...'),
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 14),
        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: ['All', 'Active', 'Inactive', 'Owner', 'Buyer', 'Dealer'].map((f) {
            final isSelected = _userFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _userFilter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : AppColors.border),
                  ),
                  child: Text(f, style: AppTypography.labelMedium.copyWith(color: isSelected ? Colors.white : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ),
            );
          }).toList()),
        ),
        const SizedBox(height: 20),
        if (users.isEmpty)
          _emptyState(Icons.people_outline_rounded, 'No users found', 'Try adjusting your filters')
        else
          ...users.map((u) => _buildUserCard(u)),
      ]),
    );
  }

  Widget _buildUserCard(_UserItem u) {
    final avatarColors = [const Color(0xFF10B981), const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFFF59E0B), const Color(0xFFEF4444), const Color(0xFF06B6D4)];
    final color = avatarColors[u.name.length % avatarColors.length];
    final roleColor = u.role == 'Owner' ? const Color(0xFF10B981) : u.role == 'Dealer' ? const Color(0xFF8B5CF6) : const Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(child: Text(u.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text(u.name, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(u.role, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: roleColor)),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: u.isActive ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 5, height: 5, decoration: BoxDecoration(color: u.isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B), shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(u.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: u.isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B))),
              ]),
            ),
          ]),
          const SizedBox(height: 5),
          Text(u.email, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.home_work_outlined, size: 13, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text('${u.listingCount} listings', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
            const SizedBox(width: 14),
            Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text('Joined ${u.joinedStr}', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
          ]),
        ])),
        // Actions
        Column(children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.phone_rounded, size: 16, color: Color(0xFF10B981)),
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.email_outlined, size: 16, color: Color(0xFF3B82F6)),
            ),
          ),
        ]),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TAB 3: SERVICE PROVIDERS
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildServiceProvidersTab() {
    final providers = _filteredProviders;
    final isMobile = MediaQuery.of(context).size.width < 768;
    final activeCount = _mockProviders.where((p) => p.isActive).length;
    final inactiveCount = _mockProviders.length - activeCount;
    final services = _mockProviders.map((p) => p.service).toSet().toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Service Providers', style: AppTypography.headingSmall.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${providers.length} providers found', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ])),
          _miniBadge('$activeCount Active', const Color(0xFF10B981)),
          const SizedBox(width: 8),
          _miniBadge('$inactiveCount Inactive', const Color(0xFFF59E0B)),
        ]),
        const SizedBox(height: 18),

        // Summary cards row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _spSummaryCard('Total Providers', '$_totalProviders', Icons.home_repair_service_rounded, const Color(0xFF06B6D4)),
            const SizedBox(width: 10),
            _spSummaryCard('Avg Rating', '4.6', Icons.star_rounded, const Color(0xFFF59E0B)),
            const SizedBox(width: 10),
            _spSummaryCard('Total Bookings', '784', Icons.calendar_month_rounded, const Color(0xFF8B5CF6)),
            const SizedBox(width: 10),
            _spSummaryCard('Total Revenue', '₹19.8L', Icons.currency_rupee_rounded, const Color(0xFF10B981)),
          ]),
        ),
        const SizedBox(height: 18),

        // Search
        TextField(
          controller: _spSearchController,
          onChanged: (v) => setState(() => _spSearch = v),
          decoration: _searchDecoration('Search by name, email, or service...'),
          style: AppTypography.bodyMedium,
        ),
        const SizedBox(height: 14),

        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _spFilterChip('All', _spFilter == 'All'),
            _spFilterChip('Active', _spFilter == 'Active'),
            _spFilterChip('Inactive', _spFilter == 'Inactive'),
            ...services.map((s) => _spFilterChip(s, _spFilter == s)),
          ]),
        ),
        const SizedBox(height: 20),

        if (providers.isEmpty)
          _emptyState(Icons.home_repair_service_outlined, 'No service providers found', 'Try adjusting your filters')
        else
          ...providers.map((p) => _buildProviderCard(p)),
      ]),
    );
  }

  Widget _spSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 12),
        Text(value, style: AppTypography.headingMedium.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _spFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _spFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF06B6D4) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? const Color(0xFF06B6D4) : AppColors.border),
          ),
          child: Text(label, style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          )),
        ),
      ),
    );
  }

  Widget _buildProviderCard(_ServiceProviderItem p) {
    final avatarColors = [const Color(0xFF06B6D4), const Color(0xFF10B981), const Color(0xFF8B5CF6), const Color(0xFFF59E0B), const Color(0xFFEF4444), const Color(0xFF3B82F6)];
    final color = avatarColors[p.name.length % avatarColors.length];
    final serviceColor = _serviceColor(p.service);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Avatar
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(p.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(p.name, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.isActive ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 5, height: 5, decoration: BoxDecoration(color: p.isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B), shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(p.isActive ? 'Active' : 'Inactive', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: p.isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B))),
                ]),
              ),
            ]),
            const SizedBox(height: 4),
            Text(p.email, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: 8),
            // Service badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: serviceColor.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.home_repair_service_rounded, size: 12, color: serviceColor),
                const SizedBox(width: 5),
                Text(p.service, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: serviceColor)),
              ]),
            ),
          ])),
          // Actions
          Column(children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.phone_rounded, size: 16, color: Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.email_outlined, size: 16, color: Color(0xFF3B82F6)),
              ),
            ),
          ]),
        ]),
        const SizedBox(height: 14),
        // Stats row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(child: _providerStat(Icons.star_rounded, '${p.rating}', 'Rating', const Color(0xFFF59E0B))),
            Container(width: 1, height: 30, color: AppColors.border),
            Expanded(child: _providerStat(Icons.calendar_month_rounded, '${p.totalBookings}', 'Bookings', const Color(0xFF8B5CF6))),
            Container(width: 1, height: 30, color: AppColors.border),
            Expanded(child: _providerStat(Icons.currency_rupee_rounded, p.earnings, 'Earned', const Color(0xFF10B981))),
            Container(width: 1, height: 30, color: AppColors.border),
            Expanded(child: _providerStat(Icons.calendar_today_outlined, '', p.joinedStr, AppColors.textTertiary)),
          ]),
        ),
      ]),
    );
  }

  Widget _providerStat(IconData icon, String value, String label, Color color) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        ],
      ]),
      const SizedBox(height: 3),
      Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.textTertiary), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]);
  }

  Color _serviceColor(String service) {
    switch (service) {
      case 'Packers & Movers': return const Color(0xFF3B82F6);
      case 'Home Cleaning': return const Color(0xFF10B981);
      case 'Home Painting': return const Color(0xFFF59E0B);
      case 'Interior Design': return const Color(0xFF8B5CF6);
      case 'Legal Help': return const Color(0xFF06B6D4);
      case 'Home Repair': return const Color(0xFFEF4444);
      case 'Vastu Consultation': return const Color(0xFFD97706);
      case 'Home Loan': return const Color(0xFF059669);
      default: return const Color(0xFF64748B);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TAB 4: ANALYTICS
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildAnalyticsTab() {
    final approvalRate = _totalProperties > 0 ? (_activeProperties / _totalProperties * 100) : 0.0;
    final pendingRate = _totalProperties > 0 ? (_pendingProperties / _totalProperties * 100) : 0.0;
    final avgPerUser = _totalUsers > 0 ? (_totalProperties / _totalUsers) : 0.0;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Summary header cards
        if (!isMobile)
          Row(children: [
            Expanded(child: _analyticsSummaryCard('Approval Rate', '${approvalRate.toStringAsFixed(0)}%', 'of all listings', Icons.verified_rounded, const Color(0xFF10B981))),
            const SizedBox(width: 14),
            Expanded(child: _analyticsSummaryCard('Avg Listings/User', avgPerUser.toStringAsFixed(1), 'per registered user', Icons.person_rounded, const Color(0xFF3B82F6))),
            const SizedBox(width: 14),
            Expanded(child: _analyticsSummaryCard('Total Revenue', '\u20B912.4L', 'estimated platform value', Icons.currency_rupee_rounded, const Color(0xFF8B5CF6))),
            const SizedBox(width: 14),
            Expanded(child: _analyticsSummaryCard('Active Ads', '$_totalAds', 'running advertisements', Icons.campaign_rounded, const Color(0xFFD97706))),
          ])
        else
          Column(children: [
            Row(children: [
              Expanded(child: _analyticsSummaryCard('Approval', '${approvalRate.toStringAsFixed(0)}%', '', Icons.verified_rounded, const Color(0xFF10B981))),
              const SizedBox(width: 10),
              Expanded(child: _analyticsSummaryCard('Avg/User', avgPerUser.toStringAsFixed(1), '', Icons.person_rounded, const Color(0xFF3B82F6))),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _analyticsSummaryCard('Revenue', '\u20B912.4L', '', Icons.currency_rupee_rounded, const Color(0xFF8B5CF6))),
              const SizedBox(width: 10),
              Expanded(child: _analyticsSummaryCard('Ads', '$_totalAds', '', Icons.campaign_rounded, const Color(0xFFD97706))),
            ]),
          ]),
        const SizedBox(height: 24),

        // Ring charts
        if (!isMobile)
          Row(children: [
            Expanded(child: _ringCard('Approval Rate', approvalRate, const Color(0xFF10B981))),
            const SizedBox(width: 14),
            Expanded(child: _ringCard('Pending Rate', pendingRate, const Color(0xFFF59E0B))),
            const SizedBox(width: 14),
            Expanded(child: _ringCard('User Engagement', 72, const Color(0xFF3B82F6))),
          ])
        else
          Column(children: [
            Row(children: [
              Expanded(child: _ringCard('Approval', approvalRate, const Color(0xFF10B981))),
              const SizedBox(width: 12),
              Expanded(child: _ringCard('Pending', pendingRate, const Color(0xFFF59E0B))),
            ]),
          ]),
        const SizedBox(height: 24),

        // Weekly trend
        _sectionCard('Weekly Trend', Icons.show_chart_rounded, const Color(0xFF3B82F6), children: [
          _buildWeeklyBars(),
        ]),
        const SizedBox(height: 20),

        // Property breakdown
        _sectionCard('Property Breakdown', Icons.pie_chart_rounded, const Color(0xFF8B5CF6), children: [
          _breakdownBar('Active Listings', _activeProperties, _totalProperties, const Color(0xFF10B981)),
          const SizedBox(height: 12),
          _breakdownBar('Pending Review', _pendingProperties, _totalProperties, const Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          _buildPropertyTypeChart(),
        ]),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _analyticsSummaryCard(String label, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: AppTypography.headingMedium.copyWith(fontWeight: FontWeight.w800, color: color)),
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          if (subtitle.isNotEmpty) Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        ])),
      ]),
    );
  }

  Widget _buildWeeklyBars() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [8, 12, 6, 15, 10, 18, 14];
    final maxVal = values.reduce(max);
    return SizedBox(
      height: 160,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(7, (i) {
        final ratio = maxVal > 0 ? values[i] / maxVal : 0.0;
        final isMax = values[i] == maxVal;
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('${values[i]}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isMax ? AppColors.primary : AppColors.textTertiary)),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 100 * ratio,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: isMax ? [AppColors.primaryDark, AppColors.primary] : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(days[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isMax ? AppColors.primary : AppColors.textTertiary)),
          ]),
        ));
      })),
    );
  }

  Widget _ringCard(String label, double percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border.withOpacity(0.5))),
      child: Column(children: [
        SizedBox(width: 90, height: 90, child: CustomPaint(
          painter: _RingPainter(percent / 100, color),
          child: Center(child: Text('${percent.toStringAsFixed(0)}%', style: AppTypography.headingMedium.copyWith(fontWeight: FontWeight.w800, color: color))),
        )),
        const SizedBox(height: 12),
        Text(label, style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _breakdownBar(String label, int count, int total, Color color) {
    final ratio = total > 0 ? count / total : 0.0;
    return Row(children: [
      SizedBox(width: 120, child: Text(label, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: ratio, backgroundColor: color.withOpacity(0.1), color: color, minHeight: 8))),
      const SizedBox(width: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      ),
    ]);
  }

  Widget _buildPropertyTypeChart() {
    final props = PropertyStore.instance.properties;
    final typeCount = <String, int>{};
    for (final p in props) {
      final label = p.propertyType.toString().split('.').last;
      typeCount[label] = (typeCount[label] ?? 0) + 1;
    }
    final colors = [const Color(0xFF10B981), const Color(0xFF3B82F6), const Color(0xFF8B5CF6), const Color(0xFFF59E0B), const Color(0xFFEF4444), const Color(0xFF06B6D4)];
    int colorIdx = 0;
    return Column(children: typeCount.entries.map((e) {
      final color = colors[colorIdx % colors.length];
      colorIdx++;
      final ratio = props.isNotEmpty ? e.value / props.length : 0.0;
      return Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 10),
        SizedBox(width: 100, child: Text(e.key[0].toUpperCase() + e.key.substring(1), style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w500))),
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: ratio, backgroundColor: color.withOpacity(0.1), color: color, minHeight: 6))),
        const SizedBox(width: 12),
        Text('${e.value}', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700, color: color)),
      ]));
    }).toList());
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TAB 4: SETTINGS
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildSettingsTab() {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Notifications section
        _sectionCard('Notifications', Icons.notifications_rounded, const Color(0xFF3B82F6), children: [
          _toggleRow('New listing posted', 'Get notified when a user lists a property', _notifNewListing, (v) => setState(() => _notifNewListing = v)),
          _toggleRow('New user registered', 'Get notified when a user creates an account', _notifNewUser, (v) => setState(() => _notifNewUser = v)),
          _toggleRow('Pending alert', 'Daily digest of pending reviews', _notifPendingAlert, (v) => setState(() => _notifPendingAlert = v)),
        ]),
        const SizedBox(height: 20),

        // Verification rules
        _sectionCard('Auto-Verification Rules', Icons.verified_rounded, const Color(0xFFF59E0B), children: [
          _toggleRow('Auto-verify owner listings', 'Listings by verified owners are auto-approved', _autoVerifyOwner, (v) => setState(() => _autoVerifyOwner = v)),
          _toggleRow('Auto-verify dealer listings', 'Listings by registered dealers are auto-approved', _autoVerifyDealer, (v) => setState(() => _autoVerifyDealer = v)),
        ]),
        const SizedBox(height: 20),

        // Security
        _sectionCard('Security & Access', Icons.shield_rounded, const Color(0xFF10B981), children: [
          _settingsTile(Icons.lock_outline_rounded, 'Change Admin Password', 'Update your login credentials', const Color(0xFF10B981)),
          _settingsTile(Icons.key_rounded, 'API Keys', 'Manage server API keys', const Color(0xFF3B82F6)),
          _toggleRow('Maintenance mode', 'Temporarily disable public access to the platform', _maintenanceMode, (v) => setState(() => _maintenanceMode = v), isDestructive: true),
        ]),
        const SizedBox(height: 20),

        // Data management
        _sectionCard('Data Management', Icons.storage_rounded, const Color(0xFF8B5CF6), children: [
          _settingsTile(Icons.download_rounded, 'Export Properties CSV', 'Download all listing data as a spreadsheet', const Color(0xFF8B5CF6)),
          _settingsTile(Icons.download_rounded, 'Export Users CSV', 'Download all user data as a spreadsheet', const Color(0xFF3B82F6)),
          _settingsTile(Icons.archive_rounded, 'Archive Old Listings', 'Move inactive listings older than 6 months to archive', const Color(0xFFF59E0B)),
          _settingsTile(Icons.delete_sweep_rounded, 'Clear All Data', 'Permanently remove all platform data', const Color(0xFFEF4444)),
        ]),
        const SizedBox(height: 24),

        // About
        Container(
          width: double.infinity, padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text('YEstateHub Admin', style: AppTypography.headingSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Version 1.0.0+1', style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.7))),
            const SizedBox(height: 18),
            _aboutRow('Platform', 'Flutter Web'),
            _aboutRow('Backend', 'FastAPI + MongoDB'),
            _aboutRow('Framework', 'Dart 3.x'),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Text('Built with love for real estate', style: AppTypography.labelSmall.copyWith(color: Colors.white.withOpacity(0.8))),
            ),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged, {bool isDestructive = false}) {
    final activeColor = isDestructive ? const Color(0xFFEF4444) : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600, color: isDestructive && value ? const Color(0xFFEF4444) : null)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        ])),
        const SizedBox(width: 14),
        Switch(
          value: value, onChanged: onChanged,
          activeColor: activeColor,
          activeTrackColor: activeColor.withOpacity(0.3),
        ),
      ]),
    );
  }

  Widget _settingsTile(IconData icon, String title, String subtitle, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent, borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(border: Border.all(color: AppColors.border.withOpacity(0.4)), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 20, color: color)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
              ])),
              Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('$label: ', style: AppTypography.labelSmall.copyWith(color: Colors.white.withOpacity(0.6))),
        Text(value, style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  // ─── Shared Helpers ───────────────────────────────────────────────────
  InputDecoration _searchDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14), isDense: true,
    );
  }

  Widget _miniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _emptyState(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: AppColors.border.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
          child: Icon(icon, size: 36, color: AppColors.textTertiary),
        ),
        const SizedBox(height: 16),
        Text(title, style: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 6),
        Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
      ])),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(color == const Color(0xFFEF4444) ? Icons.warning_rounded : Icons.check_circle_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }
}

// ─── Ring Painter ────────────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  _RingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 10..color = color.withOpacity(0.1));
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round..color = color);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

// ─── Data Classes ────────────────────────────────────────────────────────
class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

class _StatData {
  final String label, value, badge;
  final IconData icon, trendIcon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color, this.badge, this.trendIcon);
}

class _Activity {
  final String title, subtitle, time;
  final IconData icon;
  final Color color;
  const _Activity(this.title, this.subtitle, this.icon, this.color, this.time);
}

class _UserItem {
  final String name, email, phone, role, joinedStr;
  final int listingCount;
  final bool isActive;
  const _UserItem(this.name, this.email, this.phone, this.listingCount, this.role, this.isActive, this.joinedStr);
}

class _ServiceProviderItem {
  final String name, email, phone, service, earnings, joinedStr;
  final double rating;
  final int totalBookings;
  final bool isActive;
  const _ServiceProviderItem(this.name, this.email, this.phone, this.service, this.rating, this.totalBookings, this.earnings, this.isActive, this.joinedStr);
}
