import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../config/assets.dart';
import '../../data/mock_data.dart';
import 'property_listing_screen.dart';

/// Full-screen search page — opened when the user taps the "Search properties"
/// link in the header or the search icon on mobile.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Simulated recent searches
  final List<String> _recentSearches = [
    '3 BHK in Gachibowli',
    'Villa in Kokapet',
    '2 BHK Rent in Kondapur',
    'Plots in Tellapur',
  ];

  // Suggestions as user types
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  static const List<Map<String, dynamic>> _popularCities = [
    {'name': 'Hyderabad', 'icon': Icons.location_city_rounded, 'color': Color(0xFF10B981)},
    {'name': 'Bangalore', 'icon': Icons.location_city_rounded, 'color': Color(0xFF3B82F6)},
    {'name': 'Mumbai', 'icon': Icons.location_city_rounded, 'color': Color(0xFFF59E0B)},
    {'name': 'Delhi NCR', 'icon': Icons.location_city_rounded, 'color': Color(0xFFEF4444)},
    {'name': 'Chennai', 'icon': Icons.location_city_rounded, 'color': Color(0xFF8B5CF6)},
    {'name': 'Pune', 'icon': Icons.location_city_rounded, 'color': Color(0xFFEC4899)},
    {'name': 'Kolkata', 'icon': Icons.location_city_rounded, 'color': Color(0xFF14B8A6)},
    {'name': 'Ahmedabad', 'icon': Icons.location_city_rounded, 'color': Color(0xFFF97316)},
  ];

  static const List<Map<String, String>> _trendingLocalities = [
    {'name': 'Gachibowli', 'city': 'Hyderabad'},
    {'name': 'Hitech City', 'city': 'Hyderabad'},
    {'name': 'Kondapur', 'city': 'Hyderabad'},
    {'name': 'Madhapur', 'city': 'Hyderabad'},
    {'name': 'Kokapet', 'city': 'Hyderabad'},
    {'name': 'Miyapur', 'city': 'Hyderabad'},
    {'name': 'Banjara Hills', 'city': 'Hyderabad'},
    {'name': 'Jubilee Hills', 'city': 'Hyderabad'},
    {'name': 'Manikonda', 'city': 'Hyderabad'},
    {'name': 'Nallagandla', 'city': 'Hyderabad'},
    {'name': 'Tellapur', 'city': 'Hyderabad'},
    {'name': 'Kukatpally', 'city': 'Hyderabad'},
  ];

  static const List<Map<String, dynamic>> _quickCategories = [
    {'label': 'Buy Apartments', 'icon': Icons.apartment_rounded, 'color': Color(0xFF10B981)},
    {'label': 'Rent Houses', 'icon': Icons.home_rounded, 'color': Color(0xFF3B82F6)},
    {'label': 'PG / Co-Living', 'icon': Icons.people_rounded, 'color': Color(0xFFF59E0B)},
    {'label': 'Commercial', 'icon': Icons.business_rounded, 'color': Color(0xFF8B5CF6)},
    {'label': 'Plots & Land', 'icon': Icons.landscape_rounded, 'color': Color(0xFFEF4444)},
    {'label': 'New Projects', 'icon': Icons.new_releases_rounded, 'color': Color(0xFFEC4899)},
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    // Generate suggestions from cities + localities
    final allOptions = [
      ...MockData.cities,
      ...MockData.popularLocalities.map((l) => '$l, Hyderabad'),
    ];
    setState(() {
      _suggestions = allOptions
          .where((o) => o.toLowerCase().contains(query))
          .take(8)
          .toList();
      _showSuggestions = _suggestions.isNotEmpty;
    });
  }

  void _navigateToResults({String? query, String? city}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyListingScreen(city: city ?? query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Header ──
            _buildSearchHeader(isDesktop),
            const Divider(height: 1, color: AppColors.border),
            // ── Content ──
            Expanded(
              child: _showSuggestions
                  ? _buildSuggestionsList()
                  : SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 40 : 16,
                              vertical: 24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Recent Searches
                                if (_recentSearches.isNotEmpty) ...[
                                  _buildRecentSearches(),
                                  const SizedBox(height: 32),
                                ],
                                // Quick Categories
                                _buildQuickCategories(isDesktop),
                                const SizedBox(height: 32),
                                // Popular Cities
                                _buildPopularCities(isDesktop),
                                const SizedBox(height: 32),
                                // Trending Localities
                                _buildTrendingLocalities(isDesktop),
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
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
  // SEARCH HEADER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSearchHeader(bool isDesktop) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(isDesktop ? 40 : 12, 12, isDesktop ? 40 : 12, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 12),
              // Search input
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      SvgPicture.asset(
                        AppAssets.icSearch,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          style: AppTypography.bodyMedium.copyWith(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Search city, locality, project or landmark...',
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              _navigateToResults(query: value.trim());
                            }
                          },
                        ),
                      ),
                      if (_controller.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _controller.clear();
                            _focusNode.requestFocus();
                          },
                          icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textTertiary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36),
                        ),
                      Container(width: 1, height: 24, color: AppColors.border),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.mic_none_rounded, size: 22, color: AppColors.textTertiary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 44),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUGGESTIONS LIST
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSuggestionsList() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _suggestions.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 56, color: AppColors.divider),
          itemBuilder: (context, index) {
            final suggestion = _suggestions[index];
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                ),
              ),
              title: Text(
                suggestion,
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Location',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 12),
              ),
              trailing: const Icon(Icons.north_west_rounded, size: 16, color: AppColors.textTertiary),
              onTap: () => _navigateToResults(query: suggestion),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RECENT SEARCHES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history_rounded, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Recent Searches',
              style: AppTypography.labelLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _recentSearches.clear()),
              child: Text(
                'Clear All',
                style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _recentSearches.map((search) {
            return GestureDetector(
              onTap: () => _navigateToResults(query: search),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_rounded, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Text(
                      search,
                      style: AppTypography.bodySmall.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // QUICK CATEGORIES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildQuickCategories(bool isDesktop) {
    final cols = isDesktop ? 6 : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What are you looking for?',
          style: AppTypography.labelLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: isDesktop ? 2.2 : 1.6,
          ),
          itemCount: _quickCategories.length,
          itemBuilder: (context, index) {
            final cat = _quickCategories[index];
            return GestureDetector(
              onTap: () => _navigateToResults(query: cat['label'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(cat['icon'] as IconData, size: 22, color: cat['color'] as Color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['label'] as String,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // POPULAR CITIES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPopularCities(bool isDesktop) {
    final cols = isDesktop ? 8 : 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Cities',
          style: AppTypography.labelLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: _popularCities.length,
          itemBuilder: (context, index) {
            final city = _popularCities[index];
            return GestureDetector(
              onTap: () => _navigateToResults(city: city['name'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (city['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        city['icon'] as IconData,
                        size: 24,
                        color: city['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      city['name'] as String,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TRENDING LOCALITIES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTrendingLocalities(bool isDesktop) {
    final cols = isDesktop ? 4 : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up_rounded, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Trending Localities',
              style: AppTypography.labelLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Use fixed-height rows instead of GridView to avoid overflow
        ..._buildLocalityRows(cols),
      ],
    );
  }

  List<Widget> _buildLocalityRows(int cols) {
    final rows = <Widget>[];
    for (var i = 0; i < _trendingLocalities.length; i += cols) {
      final rowItems = _trendingLocalities.sublist(
        i,
        (i + cols) > _trendingLocalities.length ? _trendingLocalities.length : i + cols,
      );
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + cols < _trendingLocalities.length ? 10 : 0),
          child: Row(
            children: [
              for (var j = 0; j < rowItems.length; j++) ...[
                if (j > 0) const SizedBox(width: 10),
                Expanded(child: _buildLocalityTile(rowItems[j])),
              ],
              // Fill remaining space if row is incomplete
              for (var k = rowItems.length; k < cols; k++) ...[
                const SizedBox(width: 10),
                const Expanded(child: SizedBox.shrink()),
              ],
            ],
          ),
        ),
      );
    }
    return rows;
  }

  Widget _buildLocalityTile(Map<String, String> loc) {
    return GestureDetector(
      onTap: () => _navigateToResults(query: '${loc['name']}, ${loc['city']}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc['name']!,
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    loc['city']!,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
