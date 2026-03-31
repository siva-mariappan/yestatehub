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
import 'widgets/filter_panel.dart';
import 'widgets/sort_options.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'Relevance';
  bool _isMapView = false;
  PropertyFilter _filter = const PropertyFilter();

  // ── Search section state ──
  int _selectedIntent = 0; // 0 = Buy, 1 = Rent
  int _selectedPropertyType = 0; // 0 = All Types

  static const List<String> _propertyTypes = [
    'All Types',
    'Plot',
    'Commercial Land',
    'Flat',
    'Individual House',
    'Individual Villa',
    'Complex',
    'Commercial Building',
  ];

  List<Property> get _filteredProperties => PropertyStore.instance.properties;

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
  // SHARED SEARCH SECTION — Card-based "Find Your Dream Property"
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchSection(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = isMobile ? 16.0 : 24.0;

    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(hPad, isMobile ? 16 : 24, hPad, isMobile ? 16 : 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 18 : 24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header: Icon + Title ──
                Row(
                  children: [
                    Container(
                      width: isMobile ? 36 : 42,
                      height: isMobile ? 36 : 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryExtraLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.home_rounded,
                        size: isMobile ? 20 : 22,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Find Your Dream Property',
                      style: (isMobile ? AppTypography.headingSmall : AppTypography.headingMedium).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 18 : 22),

                // ── Buy / Rent Tabs ──
                _buildBuyRentTabs(isMobile),
                SizedBox(height: isMobile ? 14 : 16),

                // ── Search Input with Filter Icon ──
                _buildSearchInput(isMobile),
                SizedBox(height: isMobile ? 14 : 16),

                // ── Property Type Chips ──
                _buildPropertyTypeChips(isMobile),
                SizedBox(height: isMobile ? 16 : 20),

                // ── Search Properties Button ──
                _buildSearchButton(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Buy / Rent Toggle Tabs ──
  Widget _buildBuyRentTabs(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedIntent = 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isMobile ? 48 : 52,
              decoration: BoxDecoration(
                color: _selectedIntent == 0 ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedIntent == 0 ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: isMobile ? 18 : 20,
                    color: _selectedIntent == 0 ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Buy',
                    style: AppTypography.labelLarge.copyWith(
                      color: _selectedIntent == 0 ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 15 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedIntent = 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: isMobile ? 48 : 52,
              decoration: BoxDecoration(
                color: _selectedIntent == 1 ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedIntent == 1 ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.vpn_key_outlined,
                    size: isMobile ? 18 : 20,
                    color: _selectedIntent == 1 ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rent',
                    style: AppTypography.labelLarge.copyWith(
                      color: _selectedIntent == 1 ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 15 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Search Input Field with Location + Filter Icons ──
  Widget _buildSearchInput(bool isMobile) {
    return Container(
      height: isMobile ? 50 : 54,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          SvgPicture.asset(
            AppAssets.icLocation,
            width: 20,
            height: 20,
            colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppTypography.bodyMedium.copyWith(fontSize: isMobile ? 14 : 15),
              decoration: InputDecoration(
                hintText: 'City, locality, property name or ID...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: isMobile ? 14 : 15,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          // Filter icon button
          GestureDetector(
            onTap: () => _showMobileFilters(),
            child: Container(
              width: isMobile ? 44 : 48,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.icFilter,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Property Type Chips (Horizontal Scrollable) ──
  Widget _buildPropertyTypeChips(bool isMobile) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_propertyTypes.length, (index) {
          final isSelected = _selectedPropertyType == index;
          return Padding(
            padding: EdgeInsets.only(right: index < _propertyTypes.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedPropertyType = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14 : 18,
                  vertical: isMobile ? 9 : 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _propertyTypes[index],
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Search Properties Button ──
  Widget _buildSearchButton(bool isMobile) {
    return GestureDetector(
      onTap: () {
        // Trigger search / navigate to results
      },
      child: Container(
        width: double.infinity,
        height: isMobile ? 50 : 54,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: isMobile ? 20 : 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Search Properties',
              style: AppTypography.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 15 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE SEARCH
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileSearch() {
    return Column(
      children: [
        // ── Search Section (Buy/Rent + Input + Types + Button) ──
        _buildSearchSection(context),
        const Divider(height: 1, color: AppColors.border),
        // ── Results header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredProperties.length} Properties Found',
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
              ),
              Row(
                children: [
                  SortOptions(
                    selectedSort: _sortBy,
                    onSortChanged: (s) => setState(() => _sortBy = s),
                  ),
                  const SizedBox(width: 8),
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
        // ── Results ──
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
        // ── Search Section (Buy/Rent + Input + Types + Button) ──
        _buildSearchSection(context),
        const Divider(height: 1, color: AppColors.border),
        // ── Three-column layout: Filters | Listings | Map ──
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_filteredProperties.length} Properties Found',
                                style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                              ),
                              Row(
                                children: [
                                  SortOptions(
                                    selectedSort: _sortBy,
                                    onSortChanged: (s) => setState(() => _sortBy = s),
                                  ),
                                  const SizedBox(width: 12),
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
                            ],
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _isMapView ? 1 : Responsive.value<int>(context, mobile: 1, tablet: 2, desktop: 3),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: _isMapView ? 0.85 : Responsive.value<double>(context, mobile: 0.85, tablet: 0.68, desktop: 0.68),
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
