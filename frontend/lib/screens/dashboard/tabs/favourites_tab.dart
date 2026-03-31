import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../config/responsive.dart';
import '../../../services/property_store.dart';
import '../../../widgets/common/property_card.dart';

/// Favourites Tab — Saved properties grid with search and empty state
class FavouritesTab extends StatefulWidget {
  const FavouritesTab({super.key});

  @override
  State<FavouritesTab> createState() => _FavouritesTabState();
}

class _FavouritesTabState extends State<FavouritesTab> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = isMobile ? 16.0 : 28.0;
    var saved = PropertyStore.instance.properties.toList();
    final gridCols = Responsive.value<int>(context, mobile: 1, tablet: 2, desktop: 3);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      saved = saved.where((p) =>
        p.title.toLowerCase().contains(q) ||
        p.locality.toLowerCase().contains(q) ||
        p.city.toLowerCase().contains(q) ||
        p.address.toLowerCase().contains(q)
      ).toList();
    }

    return Column(
      children: [
        // ── Header Title + Search ──
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite_rounded, size: 20, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    'Your Liked Properties',
                    style: AppTypography.headingSmall.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  Text(
                    '${saved.length} properties saved',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) => setState(() => _searchQuery = v),
                              style: AppTypography.bodyMedium.copyWith(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search your liked properties...',
                                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textTertiary),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Count badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${saved.length}',
                          style: AppTypography.labelLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        // ── Grid ──
        Expanded(
          child: saved.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  padding: EdgeInsets.all(hPad),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCols,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: gridCols == 1 ? 0.85 : 0.72,
                  ),
                  itemCount: saved.length,
                  itemBuilder: (context, index) {
                    return PropertyCard(property: saved[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.favorite_outline_rounded, size: 40, color: AppColors.error),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No matching properties' : 'No liked properties yet',
            style: AppTypography.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term.'
                : 'Properties you like will appear here.\nStart exploring to find your dream home!',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Explore Properties',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
