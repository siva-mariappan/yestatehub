import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../config/assets.dart';
import '../../data/mock_data.dart';
import '../../services/property_store.dart';
import '../../models/property.dart';
import '../../widgets/common/property_card.dart';
import '../property_detail/property_detail_screen.dart';

/// Premium category screen for Buy, Rent, PG, Commercial
class CategoryPropertyScreen extends StatefulWidget {
  final String category;
  const CategoryPropertyScreen({super.key, required this.category});

  @override
  State<CategoryPropertyScreen> createState() => _CategoryPropertyScreenState();
}

class _CategoryPropertyScreenState extends State<CategoryPropertyScreen>
    with SingleTickerProviderStateMixin {
  String _selectedSubFilter = 'All';
  String _selectedSort = 'Relevance';
  String _selectedQuickTag = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 300;
      if (show != _showBackToTop) setState(() => _showBackToTop = show);
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // CATEGORY CONFIG
  // ═══════════════════════════════════════════════════════════════
  _CategoryConfig get _config {
    switch (widget.category) {
      case 'Buy':
        return _CategoryConfig(
          title: 'Buy Property',
          subtitle: 'Find your dream home to own',
          icon: Icons.home_rounded,
          gradient: [const Color(0xFF10B981), const Color(0xFF059669)],
          accentColor: const Color(0xFF10B981),
          accentLight: const Color(0xFFECFDF5),
          subFilters: ['All', 'Flat', 'House', 'Villa', 'Plot', 'Commercial'],
          quickTags: ['Ready to Move', 'Under Construction', 'Resale', 'New Launch', 'Verified Owner', 'RERA Approved'],
          stats: [
            _StatItem('2,500+', 'Properties', Icons.apartment_rounded),
            _StatItem('50+', 'Cities', Icons.location_city_rounded),
            _StatItem('₹45L', 'Avg Price', Icons.trending_up_rounded),
          ],
          highlights: [
            _HighlightItem('Zero Brokerage', 'Direct from owners', Icons.money_off_rounded, const Color(0xFF10B981)),
            _HighlightItem('RERA Verified', 'Govt approved listings', Icons.verified_rounded, const Color(0xFF3B82F6)),
            _HighlightItem('Home Loans', 'Pre-approved offers', Icons.account_balance_rounded, const Color(0xFFF59E0B)),
          ],
          searchHint: 'Search by locality, project or city...',
        );
      case 'Rent':
        return _CategoryConfig(
          title: 'Rent Property',
          subtitle: 'Find affordable rentals near you',
          icon: Icons.vpn_key_rounded,
          gradient: [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          accentColor: const Color(0xFF3B82F6),
          accentLight: const Color(0xFFDBEAFE),
          subFilters: ['All', 'Flat', 'House', 'Villa', 'Independent Floor', 'Office'],
          quickTags: ['Zero Deposit', 'Furnished', 'Semi Furnished', 'Bachelor Friendly', 'Family Only', 'Pet Friendly'],
          stats: [
            _StatItem('5,000+', 'Rentals', Icons.key_rounded),
            _StatItem('80+', 'Cities', Icons.location_city_rounded),
            _StatItem('₹15K', 'Avg Rent', Icons.trending_down_rounded),
          ],
          highlights: [
            _HighlightItem('No Brokerage', 'Deal directly with owners', Icons.handshake_rounded, const Color(0xFF3B82F6)),
            _HighlightItem('Verified Tenants', 'Background checked', Icons.shield_rounded, const Color(0xFF10B981)),
            _HighlightItem('Rent Agreement', 'Doorstep delivery', Icons.description_rounded, const Color(0xFF8B5CF6)),
          ],
          searchHint: 'Search rentals by area or landmark...',
        );
      case 'PG':
        return _CategoryConfig(
          title: 'PG & Co-Living',
          subtitle: 'Affordable stays with all amenities',
          icon: Icons.group_rounded,
          gradient: [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
          accentColor: const Color(0xFF8B5CF6),
          accentLight: const Color(0xFFEDE9FE),
          subFilters: ['All', 'Single Room', 'Shared Room', 'PG for Men', 'PG for Women', 'Co-Living'],
          quickTags: ['With Food', 'WiFi Included', 'AC Room', 'Near Metro', 'Near College', 'Attached Bathroom'],
          stats: [
            _StatItem('3,200+', 'PG Listings', Icons.bed_rounded),
            _StatItem('40+', 'Cities', Icons.location_city_rounded),
            _StatItem('₹5K', 'Starting', Icons.currency_rupee_rounded),
          ],
          highlights: [
            _HighlightItem('Meals Included', 'Home-cooked food', Icons.restaurant_rounded, const Color(0xFF8B5CF6)),
            _HighlightItem('WiFi & Laundry', 'All utilities included', Icons.wifi_rounded, const Color(0xFF10B981)),
            _HighlightItem('No Lock-in', 'Flexible stay options', Icons.lock_open_rounded, const Color(0xFFF59E0B)),
          ],
          searchHint: 'Search PG near college or office...',
        );
      case 'Commercial':
        return _CategoryConfig(
          title: 'Commercial',
          subtitle: 'Office spaces, shops & warehouses',
          icon: Icons.business_rounded,
          gradient: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          accentColor: const Color(0xFFF59E0B),
          accentLight: const Color(0xFFFEF3C7),
          subFilters: ['All', 'Office', 'Shop', 'Warehouse', 'Commercial Land', 'Co-Working'],
          quickTags: ['Plug & Play', 'Bare Shell', 'Prime Location', 'Road Facing', 'Corner Property', 'Furnished'],
          stats: [
            _StatItem('1,800+', 'Listings', Icons.storefront_rounded),
            _StatItem('35+', 'Cities', Icons.location_city_rounded),
            _StatItem('₹1.2Cr', 'Avg Price', Icons.trending_up_rounded),
          ],
          highlights: [
            _HighlightItem('Ready Offices', 'Move in today', Icons.meeting_room_rounded, const Color(0xFFF59E0B)),
            _HighlightItem('High ROI', 'Commercial investments', Icons.show_chart_rounded, const Color(0xFF10B981)),
            _HighlightItem('Flexi Lease', 'Short & long term', Icons.event_note_rounded, const Color(0xFF3B82F6)),
          ],
          searchHint: 'Search commercial spaces by area...',
        );
      default:
        return _CategoryConfig(
          title: widget.category,
          subtitle: 'Browse properties',
          icon: Icons.home_rounded,
          gradient: [AppColors.primary, AppColors.primaryDark],
          accentColor: AppColors.primary,
          accentLight: AppColors.primaryExtraLight,
          subFilters: ['All'],
          quickTags: [],
          stats: [],
          highlights: [],
          searchHint: 'Search properties...',
        );
    }
  }

  List<Property> get _filteredProperties => PropertyStore.instance.properties;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              onPressed: () => _scrollController.animateTo(0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut),
              backgroundColor: config.accentColor,
              child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
            )
          : null,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── Hero Header ──────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeroHeader(config, isMobile)),

          // ── Search Bar ───────────────────────────────────────
          SliverToBoxAdapter(child: _buildSearchBar(config)),

          // ── Highlights Row ───────────────────────────────────
          if (config.highlights.isNotEmpty)
            SliverToBoxAdapter(child: _buildHighlights(config, isMobile)),

          // ── Quick Tags ───────────────────────────────────────
          SliverToBoxAdapter(child: _buildQuickTags(config)),

          // ── Sub-filter chips ─────────────────────────────────
          SliverToBoxAdapter(child: _buildSubFilters(config)),

          // ── Results Header ───────────────────────────────────
          SliverToBoxAdapter(child: _buildResultsHeader(config)),

          // ── Property Grid ────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : Responsive.isTablet(context) ? 2 : 4,
                childAspectRatio: isMobile ? 0.85 : Responsive.isTablet(context) ? 0.75 : 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final property = _filteredProperties[index];
                  return PropertyCard(
                    property: property,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PropertyDetailScreen(property: property)),
                    ),
                  );
                },
                childCount: _filteredProperties.length.clamp(0, 12),
              ),
            ),
          ),

          // ── Bottom Spacing ───────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HERO HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHeroHeader(_CategoryConfig config, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 20 : 32, 12, isMobile ? 20 : 32, 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Row: Back + Title + Icon ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.title,
                          style: AppTypography.headingLarge
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          config.subtitle,
                          style: AppTypography.bodySmall
                              .copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(config.icon, color: Colors.white, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Stats Row ──
              if (config.stats.isNotEmpty)
                Row(
                  children: config.stats.asMap().entries.map((entry) {
                    final stat = entry.value;
                    final isLast = entry.key == config.stats.length - 1;
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: isLast ? 0 : 12),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(stat.icon,
                                  size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stat.value,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    stat.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchBar(_CategoryConfig config) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            SvgPicture.asset(
              AppAssets.icLocation,
              width: 20,
              height: 20,
              colorFilter:
                  ColorFilter.mode(config.accentColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: config.searchHint,
                  hintStyle: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: AppColors.border,
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(16)),
                onTap: () {},
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SvgPicture.asset(
                    AppAssets.icFilter,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                        AppColors.textPrimary, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HIGHLIGHTS ROW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildHighlights(_CategoryConfig config, bool isMobile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: config.highlights.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final item = config.highlights[index];
            return Container(
              width: isMobile ? 200 : 220,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, size: 22, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // QUICK TAGS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildQuickTags(_CategoryConfig config) {
    if (config.quickTags.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 4),
      child: SizedBox(
        height: 38,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: config.quickTags.length,
          itemBuilder: (context, index) {
            final tag = config.quickTags[index];
            final isSelected = _selectedQuickTag == tag;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  _selectedQuickTag = isSelected ? '' : tag;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? config.accentColor.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? config.accentColor
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? config.accentColor
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUB FILTERS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSubFilters(_CategoryConfig config) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: config.subFilters.map((filter) {
            final isSelected = _selectedSubFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _selectedSubFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? config.accentColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? config.accentColor
                          : AppColors.border,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: config.accentColor.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RESULTS HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildResultsHeader(_CategoryConfig config) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: config.accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_filteredProperties.length} Properties Found',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSortSheet(config),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded,
                      size: 16, color: config.accentColor),
                  const SizedBox(width: 6),
                  Text(
                    _selectedSort,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet(_CategoryConfig config) {
    final sortOptions = [
      'Relevance',
      'Price: Low to High',
      'Price: High to Low',
      'Newest First',
      'Most Popular',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...sortOptions.map((option) {
                final isActive = _selectedSort == option;
                return ListTile(
                  onTap: () {
                    setState(() => _selectedSort = option);
                    Navigator.pop(ctx);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isActive
                      ? config.accentColor.withOpacity(0.06)
                      : null,
                  leading: Icon(
                    isActive
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isActive
                        ? config.accentColor
                        : AppColors.textTertiary,
                    size: 22,
                  ),
                  title: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? config.accentColor
                          : AppColors.textPrimary,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════
class _CategoryConfig {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accentColor;
  final Color accentLight;
  final List<String> subFilters;
  final List<String> quickTags;
  final List<_StatItem> stats;
  final List<_HighlightItem> highlights;
  final String searchHint;

  const _CategoryConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.accentLight,
    required this.subFilters,
    required this.quickTags,
    required this.stats,
    required this.highlights,
    required this.searchHint,
  });
}

class _StatItem {
  final String value;
  final String label;
  final IconData icon;
  const _StatItem(this.value, this.label, this.icon);
}

class _HighlightItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _HighlightItem(this.title, this.subtitle, this.icon, this.color);
}
