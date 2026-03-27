import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../config/assets.dart';
import '../../data/mock_data.dart';
import '../../models/property.dart';
import '../../widgets/common/property_card.dart';
import '../../widgets/common/search_bar_widget.dart';
import 'widgets/filter_panel.dart';
import 'widgets/sort_options.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  String _sortBy = 'Relevance';
  bool _isMapView = false;
  PropertyFilter _filter = const PropertyFilter();

  List<Property> get _filteredProperties => MockData.featuredProperties;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileSearch(),
      desktop: _buildDesktopSearch(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE SEARCH
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileSearch() {
    return Column(
      children: [
        // Search header
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 8, 16, 12),
          child: Column(
            children: [
              // Search bar + back
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36),
                  ),
                  Expanded(
                    child: SearchBarWidget(
                      controller: _searchController,
                      expanded: true,
                      autofocus: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Filter chips + sort
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildActiveFilterChip('Gachibowli'),
                          const SizedBox(width: 8),
                          _buildFilterButton(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Map toggle
                  GestureDetector(
                    onTap: () => setState(() => _isMapView = !_isMapView),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isMapView ? AppColors.primaryLight : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        _isMapView ? Icons.list_rounded : Icons.map_rounded,
                        size: 20,
                        color: _isMapView ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Results header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredProperties.length} Properties Found',
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
              ),
              SortOptions(
                selectedSort: _sortBy,
                onSortChanged: (s) => setState(() => _sortBy = s),
              ),
            ],
          ),
        ),
        // Results
        Expanded(
          child: _isMapView
              ? _buildMapPlaceholder()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: _filteredProperties.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    return PropertyCard(
                      property: _filteredProperties[index],
                      onTap: () {},
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP SEARCH
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopSearch() {
    return Column(
      children: [
        // Desktop search bar
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBarWidget(
                      controller: _searchController,
                      expanded: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SortOptions(
                    selectedSort: _sortBy,
                    onSortChanged: (s) => setState(() => _sortBy = s),
                  ),
                  const SizedBox(width: 12),
                  // Map toggle
                  GestureDetector(
                    onTap: () => setState(() => _isMapView = !_isMapView),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isMapView ? AppColors.primaryLight : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.map_rounded,
                            size: 18,
                            color: _isMapView ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Map',
                            style: AppTypography.labelMedium.copyWith(
                              color: _isMapView ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        // Three-column layout: Filters | Listings | Map
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter panel (left)
                  SizedBox(
                    width: 280,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: FilterPanel(
                        filter: _filter,
                        onFilterChanged: (f) => setState(() => _filter = f),
                        resultCount: _filteredProperties.length,
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  // Listings (center)
                  Expanded(
                    flex: _isMapView ? 1 : 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Text(
                            '${_filteredProperties.length} Properties Found',
                            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _isMapView ? 1 : Responsive.value<int>(context, mobile: 1, tablet: 2, desktop: 4),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: _isMapView ? 0.85 : Responsive.value<double>(context, mobile: 0.85, tablet: 0.68, desktop: 0.72),
                            ),
                            itemCount: _filteredProperties.length,
                            itemBuilder: (context, index) {
                              return PropertyCard(
                                property: _filteredProperties[index],
                                onTap: () {},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Map panel (right) — desktop only when map is active
                  if (_isMapView) ...[
                    const VerticalDivider(width: 1),
                    Expanded(
                      flex: 1,
                      child: _buildMapPlaceholder(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(width: 4),
          Icon(Icons.close, size: 14, color: AppColors.primaryDark),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return GestureDetector(
      onTap: () => _showMobileFilters(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppAssets.icFilter, width: 16, height: 16, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
            const SizedBox(width: 6),
            Text('Filters', style: AppTypography.labelMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_rounded, size: 64, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              'Map View',
              style: AppTypography.headingSmall.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: 4),
            Text(
              'Google Maps integration will render here',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showMobileFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters', style: AppTypography.headingMedium),
                      TextButton(
                        onPressed: () => setState(() => _filter = const PropertyFilter()),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilterPanel(
                    filter: _filter,
                    onFilterChanged: (f) => setState(() => _filter = f),
                    resultCount: _filteredProperties.length,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Show ${_filteredProperties.length} Properties',
                        style: AppTypography.buttonLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
