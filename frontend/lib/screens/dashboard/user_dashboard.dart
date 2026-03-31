import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../notifications/notifications_screen.dart';
import 'tabs/dashboard_overview_tab.dart';
import 'tabs/my_properties_tab.dart';
import 'tabs/favourites_tab.dart';
import 'tabs/messages_tab.dart';
import 'tabs/profile_tab.dart';

/// User Dashboard — Premium sidebar + content layout
class UserDashboard extends StatefulWidget {
  final int initialTab;
  final VoidCallback? onLogout;

  const UserDashboard({super.key, this.initialTab = 0, this.onLogout});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  late int _currentTab;

  static const _tabs = [
    _TabDef(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard'),
    _TabDef(Icons.home_work_rounded, Icons.home_work_outlined, 'My Properties'),
    _TabDef(Icons.favorite_rounded, Icons.favorite_outline_rounded, 'Favourites'),
    _TabDef(Icons.chat_bubble_rounded, Icons.chat_bubble_outline_rounded, 'Messages'),
    _TabDef(Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
  ];

  List<Widget> get _screens => [
    DashboardOverviewTab(
      onNavigateToMessages: () => setState(() => _currentTab = 3),
      onNavigateToProperties: () => setState(() => _currentTab = 1),
    ),
    const MyPropertiesTab(),
    const FavouritesTab(),
    const MessagesTab(),
    ProfileTab(onLogout: widget.onLogout),
  ];

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      // ── Mobile Bottom Nav ──
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
      body: Column(
        children: [
          // ── Top Header Bar ──
          _buildTopBar(isMobile),
          const Divider(height: 1, color: AppColors.border),
          // ── Content Area ──
          Expanded(
            child: isDesktop
                ? Row(
                    children: [
                      // ── Desktop Sidebar ──
                      _buildSidebar(),
                      const VerticalDivider(width: 1, color: AppColors.border),
                      // ── Main Content ──
                      Expanded(child: _screens[_currentTab]),
                    ],
                  )
                : _screens[_currentTab],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOP HEADER BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTopBar(bool isMobile) {
    return Container(
      height: isMobile ? 60 : 68,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
      ),
      child: Row(
        children: [
          // Back button
          if (isMobile)
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textPrimary),
              ),
            ),
          if (isMobile) const SizedBox(width: 12),
          // Dashboard title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isMobile ? _tabs[_currentTab].label : 'My Dashboard',
                style: AppTypography.headingMedium.copyWith(fontSize: isMobile ? 18 : 20),
              ),
              if (!isMobile)
                Text(
                  'Welcome back, ${FirebaseAuth.instance.currentUser?.displayName ?? 'User'}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                ),
            ],
          ),
          const Spacer(),
          // Notification bell
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
            child: _buildHeaderAction(Icons.notifications_outlined, badge: 3),
          ),
          const SizedBox(width: 8),
          // Settings gear — navigate to Profile tab
          GestureDetector(
            onTap: () => setState(() => _currentTab = 4),
            child: _buildHeaderAction(Icons.settings_outlined),
          ),
          const SizedBox(width: 12),
          // Avatar — navigate to Profile tab
          GestureDetector(
            onTap: () => setState(() => _currentTab = 4),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  (FirebaseAuth.instance.currentUser?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                  style: AppTypography.labelLarge.copyWith(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, {int badge = 0}) {
    return Stack(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 20, color: AppColors.textSecondary),
        ),
        if (badge > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
              child: Center(
                child: Text(
                  '$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP SIDEBAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // User card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text((FirebaseAuth.instance.currentUser?.displayName ?? 'U').substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                          style: AppTypography.labelLarge.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          FirebaseAuth.instance.currentUser?.email ?? '',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Nav items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: List.generate(_tabs.length, (index) => _buildSidebarItem(index)),
            ),
          ),
          const Spacer(),
          // Sign out
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: GestureDetector(
              onTap: widget.onLogout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                    const SizedBox(width: 12),
                    Text(
                      'Sign Out',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.error),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index) {
    final isActive = _currentTab == index;
    final tab = _tabs[index];
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryExtraLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
        ),
        child: Row(
          children: [
            Icon(
              isActive ? tab.activeIcon : tab.inactiveIcon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              tab.label,
              style: AppTypography.labelLarge.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (index == 3) ...[
              const Spacer(),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('3', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE BOTTOM NAV
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isActive = _currentTab == index;
          final tab = _tabs[index];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 44 : 40,
                    height: isActive ? 44 : 40,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryExtraLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          isActive ? tab.activeIcon : tab.inactiveIcon,
                          size: 22,
                          color: isActive ? AppColors.primary : AppColors.textTertiary,
                        ),
                        if (index == 3)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive ? AppColors.primary : AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TabDef {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _TabDef(this.activeIcon, this.inactiveIcon, this.label);
}
