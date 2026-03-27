import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../config/assets.dart';
import '../../data/mock_data.dart';
import '../../models/property.dart';
import '../../widgets/common/property_card.dart';
import '../property_detail/property_detail_screen.dart';

/// Dedicated category screen for Buy, Rent, PG, Commercial
class CategoryPropertyScreen extends StatefulWidget {
  final String category;
  const CategoryPropertyScreen({super.key, required this.category});

  @override
  State<CategoryPropertyScreen> createState() => _CategoryPropertyScreenState();
}

class _CategoryPropertyScreenState extends State<CategoryPropertyScreen> {
  String _selectedSubFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  // Category-specific config
  Map<String, dynamic> get _categoryConfig {
    switch (widget.category) {
      case 'Buy':
        return {
          'title': 'Buy Property',
          'subtitle': 'Find your dream home to own',
          'icon': Icons.home_rounded,
          'gradient': [const Color(0xFF10B981), const Color(0xFF059669)],
          'subFilters': ['All', 'Flat', 'House', 'Villa', 'Plot', 'Commercial'],
          'propertyTypes': ['Flat', 'Individual House', 'Individual Villa', 'Plot/Land', 'Commercial Building', 'Complex'],
          'quickTags': ['Ready to Move', 'Under Construction', 'Resale', 'New Launch', 'Verified Owner'],
          'stats': [
            {'label': 'Properties', 'value': '2,500+'},
            {'label': 'Cities', 'value': '50+'},
            {'label': 'Avg Price', 'value': '₹45L'},
          ],
        };
      case 'Rent':
        return {
          'title': 'Rent Property',
          'subtitle': 'Find affordable rentals near you',
          'icon': Icons.vpn_key_rounded,
          'gradient': [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
          'subFilters': ['All', 'Flat', 'House', 'Villa', 'Independent Floor', 'Office'],
          'propertyTypes': ['Flat', 'Individual House', 'Individual Villa', 'Independent Floor', 'Office Space', 'Shop/Showroom'],
          'quickTags': ['Zero Deposit', 'Furnished', 'Semi Furnished', 'Bachelor Friendly', 'Family Only'],
          'stats': [
            {'label': 'Rentals', 'value': '5,000+'},
            {'label': 'Cities', 'value': '80+'},
            {'label': 'Avg Rent', 'value': '₹15K'},
          ],
        };
      case 'PG':
        return {
          'title': 'PG & Co-Living',
          'subtitle': 'Affordable stays with all amenities',
          'icon': Icons.group_rounded,
          'gradient': [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
          'subFilters': ['All', 'Single Room', 'Shared Room', 'PG for Men', 'PG for Women', 'Co-Living'],
          'propertyTypes': ['PG/Hostel', 'Shared Room'],
          'quickTags': ['With Food', 'WiFi Included', 'AC Room', 'Near Metro', 'Near College'],
          'stats': [
            {'label': 'PG Listings', 'value': '3,200+'},
            {'label': 'Cities', 'value': '40+'},
            {'label': 'Starting', 'value': '₹5K'},
          ],
        };
      case 'Commercial':
        return {
          'title': 'Commercial Property',
          'subtitle': 'Office spaces, shops & warehouses',
          'icon': Icons.business_rounded,
          'gradient': [const Color(0xFFF59E0B), const Color(0xFFD97706)],
          'subFilters': ['All', 'Office', 'Shop', 'Warehouse', 'Commercial Land', 'Co-Working'],
          'propertyTypes': ['Commercial Building', 'Office Space', 'Shop/Showroom', 'Warehouse/Godown', 'Commercial Land'],
          'quickTags': ['Plug & Play', 'Bare Shell', 'Prime Location', 'Road Facing', 'Corner Property'],
          'stats': [
            {'label': 'Listings', 'value': '1,800+'},
            {'label': 'Cities', 'value': '35+'},
            {'label': 'Avg Price', 'value': '₹1.2Cr'},
          ],
        };
      default:
        return {
          'title': widget.category,
          'subtitle': 'Browse properties',
          'icon': Icons.home_rounded,
          'gradient': [AppColors.primary, AppColors.primaryDark],
          'subFilters': ['All'],
          'propertyTypes': <String>[],
          'quickTags': <String>[],
          'stats': <Map<String, String>>[],
        };
    }
  }

  List<Property> get _filteredProperties => MockData.featuredProperties;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _categoryConfig;
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Header
          SliverToBoxAdapter(child: _buildHeroHeader(config)),

          // Search Bar
          SliverToBoxAdapter(child: _buildSearchBar()),

          // Quick Tags
          SliverToBoxAdapter(child: _buildQuickTags(config)),

          // Sub-filter chips
          SliverToBoxAdapter(child: _buildSubFilters(config)),

          // Results count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredProperties.length} Properties Found',
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Icon(Icons.sort_rounded, size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text('Sort', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),

          // Property Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : Responsive.isTablet(context) ? 2 : 4,
                childAspectRatio: isMobile ? 0.85 : Responsive.isTablet(context) ? 0.78 : 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final property = _filteredProperties[index];
                  return PropertyCard(
                    property: property,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: property)),
                    ),
                  );
                },
                childCount: _filteredProperties.length.clamp(0, 12),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(Map<String, dynamic> config) {
    final gradientColors = config['gradient'] as List<Color>;
    final stats = config['stats'] as List<Map<String, String>>;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button + title row
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config['title'] as String,
                          style: AppTypography.headingMedium.copyWith(color: Colors.white),
                        ),
                        Text(
                          config['subtitle'] as String,
                          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(config['icon'] as IconData, color: Colors.white, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stats row
              if (stats.isNotEmpty)
                Row(
                  children: stats.map((stat) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              stat['value']!,
                              style: AppTypography.headingSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stat['label']!,
                              style: TextStyle(fontSize: 11, color: Colors.white70),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search ${widget.category.toLowerCase()} properties...',
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(AppAssets.icFilter, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTags(Map<String, dynamic> config) {
    final tags = config['quickTags'] as List<String>;
    if (tags.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                tags[index],
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubFilters(Map<String, dynamic> config) {
    final filters = config['subFilters'] as List<String>;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedSubFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedSubFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
                        : [],
                  ),
                  child: Text(
                    filter,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
}
