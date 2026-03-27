import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../data/mock_data.dart';

/// My Properties — user's listed properties with management cards
class MyPropertiesTab extends StatelessWidget {
  const MyPropertiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final props = MockData.featuredProperties.take(3).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: props.length,
      itemBuilder: (context, index) {
        final p = props[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 100,
                  height: 80,
                  color: AppColors.divider,
                  child: p.images.isNotEmpty
                      ? Image.network(p.images.first, fit: BoxFit.cover)
                      : const Icon(Icons.image, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.title, style: AppTypography.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('${p.locality}, ${p.city}', style: AppTypography.bodySmall),
                    const SizedBox(height: 8),
                    // Stats row
                    Row(
                      children: [
                        _miniStat(Icons.visibility, '${p.views}'),
                        const SizedBox(width: 14),
                        _miniStat(Icons.message, '${p.enquiries}'),
                        const SizedBox(width: 14),
                        _miniStat(Icons.favorite, '12'),
                        const SizedBox(width: 14),
                        _miniStat(Icons.calendar_today, '${DateTime.now().difference(p.listedDate).inDays}d'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Action buttons
                    Row(
                      children: [
                        _actionBtn('Edit', Icons.edit, AppColors.primary),
                        const SizedBox(width: 8),
                        _actionBtn('Boost', Icons.rocket_launch, AppColors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _miniStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(value, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
