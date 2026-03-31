import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../models/property.dart';
import '../../services/property_store.dart';
import '../../config/assets.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/common/intent_tabs.dart';
import '../../widgets/common/property_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/ads/ad_carousel.dart';
import '../../widgets/footer/app_footer.dart';
import '../property_detail/property_detail_screen.dart';
import '../analytics/analytics_screen.dart';
import '../chat/chat_screen.dart';
import '../dashboard/user_dashboard.dart';
import '../notifications/notifications_screen.dart';
import '../add_property/add_property_wizard.dart';
// import 'widgets/hero_section.dart'; // Removed
import 'widgets/quick_filters.dart';
import 'widgets/city_selector.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  final int selectedIntent;
  final ValueChanged<int>? onIntentChanged;
  final bool isAdmin;

  const HomeScreen({
    super.key,
    this.onNavigate,
    this.selectedIntent = 0,
    this.onIntentChanged,
    this.isAdmin = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCity = 'Hyderabad';
  final PropertyStore _store = PropertyStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return _buildMobileHome();
    }
    return _buildDesktopHome();
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE HOME
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileHome() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverToBoxAdapter(child: _buildMobileHeader()),
        // Intent Tabs
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: IntentTabs(
              selectedIndex: widget.selectedIntent,
              onTabChanged: (i) => widget.onIntentChanged?.call(i),
            ),
          ),
        ),
        // ─── Ad Carousel (right after header) ────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AdCarousel(isAdmin: widget.isAdmin, mobileHeight: 200, desktopHeight: 420),
            ),
          ),
        ),
        // ─── Quick Actions Row ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildMobileQuickActions(),
          ),
        ),
        // Featured Listings Header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 8, bottom: 12),
            child: SectionHeader(title: 'Featured Listings', actionText: 'See All'),
          ),
        ),
        // Featured Listings
        if (_store.properties.isEmpty)
          SliverToBoxAdapter(
            child: _buildEmptyListingsState(context),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PropertyCard(
                      property: _store.properties[index],
                      onTap: () => _openPropertyDetail(context, _store.properties[index]),
                    ),
                  );
                },
                childCount: _store.properties.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Footer
        const SliverToBoxAdapter(child: AppFooter()),
      ],
    );
  }

  Widget _buildMobileQuickActions() {
    final actions = [
      _QuickAction(Icons.insights_rounded, 'EstateIQ', AppColors.primary, () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
      }),
      _QuickAction(Icons.chat_bubble_outline_rounded, 'Messages', const Color(0xFF3B82F6), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
      }),
      _QuickAction(Icons.dashboard_outlined, 'Dashboard', const Color(0xFF8B5CF6), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const UserDashboard()));
      }),
      _QuickAction(Icons.notifications_none_rounded, 'Alerts', const Color(0xFFD97706), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
      }),
      _QuickAction(Icons.add_home_outlined, 'Sell/Rent', const Color(0xFFEF4444), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyWizard()));
      }),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Expanded(
          child: GestureDetector(
            onTap: action.onTap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(action.icon, size: 24, color: action.color),
                ),
                const SizedBox(height: 6),
                Text(
                  action.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(AppAssets.logo, height: 32, fit: BoxFit.contain),
          CitySelector(
            selectedCity: _selectedCity,
            onCityChanged: (city) => setState(() => _selectedCity = city),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABLET + DESKTOP HOME
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopHome() {
    final hPad = Responsive.value<double>(context, mobile: 20, tablet: 24, desktop: 40);
    final gridCols = Responsive.value<int>(context, mobile: 1, tablet: 2, desktop: 4);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Intent tabs bar (scrollable)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFB),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: IntentTabs(
                    selectedIndex: widget.selectedIntent,
                    onTabChanged: (i) => widget.onIntentChanged?.call(i),
                  ),
                ),
              ),
            ),
          ),
          // Ad carousel (full width)
          AdCarousel(isAdmin: widget.isAdmin, desktopHeight: 520, mobileHeight: 420),
          // Content area
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Featured Listings
                    const SectionHeader(
                      title: 'Featured Listings',
                      actionText: 'Explore All Properties',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 20),
                    _store.properties.isEmpty
                        ? _buildEmptyListingsState(context)
                        : _buildListingsGrid(gridCols),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildEmptyListingsState(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 350,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_rounded, size: 56, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              'Properties Space',
              style: AppTypography.bodyLarge.copyWith(color: const Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingsGrid(int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: columns == 1 ? 0.85 : columns == 2 ? 0.68 : 0.72,
      ),
      itemCount: _store.properties.length.clamp(0, 12),
      itemBuilder: (context, index) {
        return PropertyCard(
          property: _store.properties[index],
          onTap: () => _openPropertyDetail(context, _store.properties[index]),
        );
      },
    );
  }

  void _openPropertyDetail(BuildContext context, Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }

  Widget _buildServiceChip(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction(this.icon, this.label, this.color, this.onTap);
}
