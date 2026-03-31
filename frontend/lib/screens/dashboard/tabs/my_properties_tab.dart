import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../config/responsive.dart';
import '../../../services/property_store.dart';
import '../../../models/property.dart';
import '../../add_property/add_property_wizard.dart';
import '../../property_detail/property_detail_screen.dart';

/// My Properties — Premium property management cards with status, stats, actions
class MyPropertiesTab extends StatefulWidget {
  const MyPropertiesTab({super.key});

  @override
  State<MyPropertiesTab> createState() => _MyPropertiesTabState();
}

class _MyPropertiesTabState extends State<MyPropertiesTab> {
  int _selectedFilter = 0;
  static const _filters = ['All', 'Active', 'Pending', 'Sold'];

  /// Build image widget that supports both base64 data URIs and network URLs
  Widget _buildPropertyImage(String url) {
    if (url.startsWith('data:image/')) {
      try {
        final b64 = url.split(',').last;
        return Image.memory(base64Decode(b64), fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_rounded, size: 40, color: AppColors.textTertiary)));
      } catch (_) {
        return const Center(child: Icon(Icons.image_rounded, size: 40, color: AppColors.textTertiary));
      }
    }
    return Image.network(url, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_rounded, size: 40, color: AppColors.textTertiary)));
  }

  List<Property> get _filteredProperties {
    final allProps = PropertyStore.instance.properties;
    // For now, assign status based on index (future: store status in Property model)
    if (_selectedFilter == 0) return allProps;
    final statusLabels = ['All', 'Active', 'Pending', 'Sold'];
    final targetStatus = statusLabels[_selectedFilter];
    return allProps.where((p) {
      final idx = allProps.indexOf(p);
      final status = _getStatus(idx);
      return status == targetStatus;
    }).toList();
  }

  String _getStatus(int index) {
    final statuses = ['Active', 'Pending', 'Active'];
    return statuses[index % statuses.length];
  }

  Color _getStatusColor(int index) {
    final colors = [AppColors.primary, AppColors.amber, AppColors.primary];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = isMobile ? 16.0 : 28.0;

    return ListenableBuilder(
      listenable: PropertyStore.instance,
      builder: (context, _) {
        final props = _filteredProperties;

        return Column(
          children: [
            // ── Header + Filter Chips ──
            Container(
              color: AppColors.surface,
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_filters.length, (index) {
                          final isActive = _selectedFilter == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFilter = index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isActive ? AppColors.primary : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  _filters[index],
                                  style: AppTypography.labelMedium.copyWith(
                                    color: isActive ? Colors.white : AppColors.textSecondary,
                                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add property button
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyWizard()));
                      if (mounted) setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 4),
                          Text('Add', style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            // ── Properties Grid ──
            Expanded(
              child: props.isEmpty
                  ? _buildEmptyState()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final gridCols = Responsive.value<int>(context, mobile: 1, tablet: 2, desktop: 3);
                        if (gridCols == 1) {
                          return ListView.builder(
                            padding: EdgeInsets.all(hPad),
                            itemCount: props.length,
                            itemBuilder: (context, index) {
                              final p = props[index];
                              final origIdx = PropertyStore.instance.properties.indexOf(p);
                              return _buildPropertyCard(context, p, isMobile, origIdx);
                            },
                          );
                        }
                        return GridView.builder(
                          padding: EdgeInsets.all(hPad),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridCols,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: gridCols == 3 ? 0.58 : 0.62,
                          ),
                          itemCount: props.length,
                          itemBuilder: (context, index) {
                            final p = props[index];
                            final origIdx = PropertyStore.instance.properties.indexOf(p);
                            return _buildPropertyCard(context, p, isMobile, origIdx);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPropertyCard(BuildContext context, Property p, bool isMobile, int index) {
    final status = _getStatus(index);
    final statusColor = _getStatusColor(index);
    final isGrid = !isMobile;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: isGrid ? 0 : 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            // ── Image + Status Badge ──
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: isMobile ? 160 : 200,
                    width: double.infinity,
                    color: AppColors.divider,
                    child: p.images.isNotEmpty
                        ? _buildPropertyImage(p.images.first)
                        : const Center(child: Icon(Icons.image_rounded, size: 40, color: AppColors.textTertiary)),
                  ),
                ),
                // Status badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: statusColor.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      status,
                      style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                  ),
                ),
                // Price badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Text(
                      p.formattedPrice,
                      style: AppTypography.priceMedium.copyWith(color: AppColors.primary, fontSize: isMobile ? 14 : 16),
                    ),
                  ),
                ),
              ],
            ),
            // ── Details ──
            Padding(
              padding: EdgeInsets.all(isMobile ? 14 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    style: AppTypography.headingSmall.copyWith(fontSize: isMobile ? 15 : 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${p.locality}, ${p.city}',
                          style: AppTypography.bodySmall.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // ── Stats Row ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildMiniStat(Icons.visibility_rounded, '${p.views}', 'Views', AppColors.info),
                        _buildStatDivider(),
                        _buildMiniStat(Icons.mark_email_read_rounded, '${p.enquiries}', 'Enquiries', AppColors.amber),
                        _buildStatDivider(),
                        _buildMiniStat(Icons.favorite_rounded, '12', 'Saved', AppColors.error),
                        _buildStatDivider(),
                        _buildMiniStat(Icons.calendar_today_rounded, '${DateTime.now().difference(p.listedDate).inDays}d', 'Listed', AppColors.primaryDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Action Buttons ──
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)));
                          },
                          child: _buildActionButton('Edit', Icons.edit_rounded, AppColors.primary, false),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Boost feature coming soon!'), behavior: SnackBarBehavior.floating),
                            );
                          },
                          child: _buildActionButton('Boost', Icons.rocket_launch_rounded, AppColors.amber, true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          _showPropertyOptions(context, p);
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.more_horiz_rounded, size: 20, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPropertyOptions(BuildContext context, Property p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              const SizedBox(height: 16),
              Text('Property Options', style: AppTypography.headingSmall),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.visibility_rounded, color: AppColors.primary),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailScreen(property: p)));
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded, color: AppColors.info),
                title: const Text('Share Property'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.pause_circle_outline_rounded, color: AppColors.amber),
                title: const Text('Mark as Sold'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${p.title} marked as sold'), behavior: SnackBarBehavior.floating),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                title: const Text('Delete Property'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, p);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Property p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${p.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PropertyStore.instance.removeProperty(p.id);
              if (mounted) setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${p.title} deleted'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 32, color: AppColors.border);
  }

  Widget _buildActionButton(String label, IconData icon, Color color, bool filled) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: filled ? color : color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: filled ? null : Border.all(color: color.withOpacity(0.3)),
        boxShadow: filled
            ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: filled ? Colors.white : color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: filled ? Colors.white : color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.home_work_outlined, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('No properties yet', style: AppTypography.headingSmall),
          const SizedBox(height: 8),
          Text(
            'Start listing your properties to reach\nthousands of potential buyers.',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyWizard()));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Add Your First Property',
                style: AppTypography.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
