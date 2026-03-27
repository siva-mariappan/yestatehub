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
import '../property_detail/property_detail_screen.dart';
import 'widgets/filter_panel.dart';
import 'widgets/sort_options.dart';

/// Full property listing/search results page
/// Desktop (>900px): Persistent 320px left sidebar + Grid/List content
/// Mobile: Drawer filter from right + scrollable results
class PropertyListingScreen extends StatefulWidget {
  final String? searchQuery;
  final String? city;
  final String? initialCategory;

  const PropertyListingScreen({super.key, this.searchQuery, this.city, this.initialCategory});

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  bool _showSidebar = true;
  String _sortBy = 'Relevance';
  PropertyFilter _filter = const PropertyFilter();

  List<Property> get _results => MockData.featuredProperties;

  bool get _isWideScreen => MediaQuery.of(context).size.width > 900;

  int get _activeFilterCount {
    // Attempt to get from filter panel key
    return 0; // simplified — filter panel tracks internally
  }

  @override
  void initState() {
    super.initState();
    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
    } else if (widget.initialCategory != null) {
      _searchController.text = '${widget.initialCategory} Properties';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: _isWideScreen ? null : _buildMobileFilterDrawer(),
      body: _isWideScreen ? _buildDesktopListing() : _buildMobileListing(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopListing() {
    return Column(
      children: [
        // Search bar row
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1360),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SearchBarWidget(
                      controller: _searchController,
                      expanded: true,
                      hint: 'Search by city, locality or project...',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 1),
        // Control bar
        _buildDesktopControlBar(),
        const Divider(height: 1),
        // Main area: sidebar + results
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1360),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Left sidebar (320px) ──
                  if (_showSidebar)
                    Container(
                      width: 320,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: FilterPanel(
                          filter: _filter,
                          onFilterChanged: (f) => setState(() => _filter = f),
                          resultCount: _results.length,
                        ),
                      ),
                    ),
                  // ── Results grid ──
                  Expanded(
                    child: _buildGridView(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Desktop Control Bar ──────────────────────────────────────
  Widget _buildDesktopControlBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Row(
            children: [
              // Results count with green badge
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${_results.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.initialCategory != null
                        ? '${widget.initialCategory} Properties'
                        : 'Properties Found',
                    style: AppTypography.labelLarge.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  if (widget.city != null)
                    Text(
                      'in ${widget.city}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                ],
              ),
              const Spacer(),
              // Show/Hide Filters button
              GestureDetector(
                onTap: () => setState(() => _showSidebar = !_showSidebar),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _showSidebar ? AppColors.primaryExtraLight : AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _showSidebar ? AppColors.primary.withOpacity(0.3) : AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(AppAssets.icFilter, width: 18, height: 18, colorFilter: ColorFilter.mode(_showSidebar ? AppColors.textPrimary : AppColors.textSecondary, BlendMode.srcIn)),
                      const SizedBox(width: 6),
                      Text(
                        _showSidebar ? 'Hide Filters' : 'Show Filters',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _showSidebar ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SortOptions(
                selectedSort: _sortBy,
                onSortChanged: (s) => setState(() => _sortBy = s),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileListing() {
    return Column(
      children: [
        // Search bar header
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 8, 12, 10),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36),
              ),
              Expanded(
                child: SearchBarWidget(
                  controller: _searchController,
                  expanded: true,
                ),
              ),
            ],
          ),
        ),
        // Mobile control bar
        _buildMobileControlBar(),
        const Divider(height: 1),
        // Results
        Expanded(
          child: _buildGridView(1),
        ),
      ],
    );
  }

  // ── Mobile Control Bar ────────────────────────────────────────
  Widget _buildMobileControlBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          // Filters button with badge
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryExtraLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(AppAssets.icFilter, width: 16, height: 16, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
                      const SizedBox(width: 6),
                      Text('Filters', style: AppTypography.labelMedium.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Results count
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Center(
              child: Text('${_results.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 8),
          Text('results', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          SortOptions(
            selectedSort: _sortBy,
            onSortChanged: (s) => setState(() => _sortBy = s),
          ),
        ],
      ),
    );
  }

  // ── Mobile Filter Drawer ──────────────────────────────────────
  Widget _buildMobileFilterDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Text('Filters', style: AppTypography.headingMedium),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _filter = const PropertyFilter()),
                    child: const Text('Reset All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            // Filter content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FilterPanel(
                  filter: _filter,
                  onFilterChanged: (f) {
                    setState(() => _filter = f);
                  },
                  resultCount: _results.length,
                  onApply: () => Navigator.pop(context),
                ),
              ),
            ),
            // Apply button at bottom
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Show ${_results.length} Properties',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
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
  // GRID / LIST VIEWS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildGridView(int columns) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 0.85 : columns >= 4 ? 0.72 : 0.78,
      ),
      itemCount: _results.length,
      itemBuilder: (context, index) => PropertyCard(
        property: _results[index],
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: _results[index])));
        },
      ),
    );
  }

}
