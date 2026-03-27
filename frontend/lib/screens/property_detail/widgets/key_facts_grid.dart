import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../models/property.dart';

class KeyFactsGrid extends StatelessWidget {
  final Property property;

  const KeyFactsGrid({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final facts = <_Fact>[
      _Fact(Icons.square_foot, 'Total Area', property.areaLabel),
      _Fact(Icons.bed_rounded, 'Configuration', property.bhkLabel),
      _Fact(Icons.layers, 'Floor', property.floorLabel),
      _Fact(Icons.explore, 'Facing', property.facingDirection),
      _Fact(Icons.calendar_today, 'Age', '${property.ageOfBuilding} years'),
      _Fact(
        Icons.chair_rounded,
        'Furnishing',
        property.furnishing == FurnishingStatus.furnished
            ? 'Furnished'
            : property.furnishing == FurnishingStatus.semiFurnished
                ? 'Semi-Furnished'
                : 'Unfurnished',
      ),
      _Fact(
        Icons.home_rounded,
        'Property Type',
        property.propertyType == PropertyType.apartment
            ? 'Apartment'
            : property.propertyType == PropertyType.villa
                ? 'Villa'
                : 'Independent',
      ),
      _Fact(
        Icons.check_circle_outline,
        'Possession',
        property.possessionStatus,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: facts.length,
      itemBuilder: (context, index) {
        final fact = facts[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(fact.icon, size: 18, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                fact.label,
                style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: 2),
              Text(
                fact.value,
                style: AppTypography.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Fact {
  final IconData icon;
  final String label;
  final String value;

  const _Fact(this.icon, this.label, this.value);
}
