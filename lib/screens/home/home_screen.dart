import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../data/mock_data.dart';
import '../../models/property.dart';
import '../../config/assets.dart';
import '../../widgets/common/search_bar_widget.dart';
import '../../widgets/common/intent_tabs.dart';
import '../../widgets/common/property_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/featured_service_card.dart';
import '../../widgets/common/small_service_card.dart';
import '../../widgets/ads/ad_carousel.dart';
import '../../widgets/footer/app_footer.dart';
import '../property_detail/property_detail_screen.dart';
// import 'widgets/hero_section.dart'; // Removed
import 'widgets/quick_filters.dart';
import 'widgets/city_selector.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  final int selectedIntent;
  final ValueChanged<int>? onIntentChanged;

  const HomeScreen({
    super.key,
    this.onNavigate,
    this.selectedIntent = 0,
    this.onIntentChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCity = 'Hyderabad';

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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: IntentTabs(
              selectedIndex: widget.selectedIntent,
              onTabChanged: (i) => widget.onIntentChanged?.call(i),
            ),
          ),
        ),
        // Featured Listings Header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 24, bottom: 12),
            child: SectionHeader(title: 'Featured Listings', actionText: 'See All'),
          ),
        ),
        // Featured Listings
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PropertyCard(
                    property: MockData.featuredProperties[index],
                    onTap: () => _openPropertyDetail(context, MockData.featuredProperties[index]),
                  ),
                );
              },
              childCount: MockData.featuredProperties.length,
            ),
          ),
        ),
        // ─── Home Services Section ─────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 16, bottom: 12),
            child: SectionHeader(title: 'Home Services', actionText: 'See All'),
          ),
        ),
        // Featured Service Cards
        SliverToBoxAdapter(
          child: SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: MockData.featuredServices.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 280,
                  child: FeaturedServiceCard(
                    service: MockData.featuredServices[index],
                  ),
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        // Small Service Cards
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => SmallServiceCard(
                service: MockData.services[index],
              ),
              childCount: MockData.services.length.clamp(0, 8),
            ),
          ),
        ),
        // ─── Ad Carousel ───────────────────────────────────────────
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 8, bottom: 12),
            child: SectionHeader(title: 'Sponsored', actionText: ''),
          ),
        ),
        SliverToBoxAdapter(
          child: AdCarousel(ads: mockAds, height: 480),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // Footer
        const SliverToBoxAdapter(child: AppFooter()),
      ],
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
    final serviceGridCols = Responsive.value<int>(context, mobile: 3, tablet: 4, desktop: 5);

    final adHeight = Responsive.value<double>(context, mobile: 480, tablet: 500, desktop: 520);

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
          // Services strip (scrollable)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: AppColors.surface,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildServiceChip(Icons.home_work_outlined, 'Home Loan'),
                        _buildServiceChip(Icons.description_outlined, 'Rental Agreement'),
                        _buildServiceChip(Icons.local_shipping_outlined, 'Packers & Movers'),
                        _buildServiceChip(Icons.cleaning_services_outlined, 'Home Cleaning'),
                        _buildServiceChip(Icons.format_paint_outlined, 'Home Painting'),
                        _buildServiceChip(Icons.chair_outlined, 'Interior Design'),
                        _buildServiceChip(Icons.gavel_outlined, 'Legal Help'),
                        _buildServiceChip(Icons.plumbing_outlined, 'Home Repair'),
                        _buildServiceChip(Icons.explore_outlined, 'Vastu Consulting'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Ad carousel (full width)
          AdCarousel(ads: mockAds, height: adHeight),
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
                    _buildListingsGrid(gridCols),
                    const SizedBox(height: 40),
                    // ─── Home Services ─────────────────────────────
                    const SectionHeader(
                      title: 'Home Services',
                      actionText: 'See All',
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 20),
                    _buildFeaturedServices(),
                    const SizedBox(height: 24),
                    _buildServicesGrid(serviceGridCols),
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
      itemCount: MockData.featuredProperties.length.clamp(0, 12),
      itemBuilder: (context, index) {
        return PropertyCard(
          property: MockData.featuredProperties[index],
          onTap: () => _openPropertyDetail(context, MockData.featuredProperties[index]),
        );
      },
    );
  }

  Widget _buildFeaturedServices() {
    return Row(
      children: MockData.featuredServices.map((service) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: service == MockData.featuredServices.last ? 0 : 16,
            ),
            child: FeaturedServiceCard(service: service),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServicesGrid(int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.8,
      ),
      itemCount: MockData.services.length,
      itemBuilder: (context, index) => SmallServiceCard(
        service: MockData.services[index],
      ),
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
