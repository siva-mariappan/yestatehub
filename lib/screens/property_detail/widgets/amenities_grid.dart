import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';

class AmenitiesGrid extends StatelessWidget {
  final List<String> amenities;

  const AmenitiesGrid({super.key, required this.amenities});

  static const _allAmenities = <String, IconData>{
    'Parking': Icons.local_parking,
    'Lift': Icons.elevator,
    'Gym': Icons.fitness_center,
    'Pool': Icons.pool,
    'Security': Icons.security,
    'Power Backup': Icons.bolt,
    'Clubhouse': Icons.sports_bar,
    'Children Play Area': Icons.child_care,
    'CCTV': Icons.videocam,
    'Garden': Icons.park,
    'Jogging Track': Icons.directions_run,
    '24h Water': Icons.water_drop,
    'Fire Safety': Icons.local_fire_department,
    'Intercom': Icons.phone_in_talk,
    'Servant Room': Icons.room_preferences,
    'Piped Gas': Icons.gas_meter,
    'Rain Water Harvesting': Icons.water,
    'Waste Disposal': Icons.delete_outline,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _allAmenities.entries.map((entry) {
        final isAvailable = amenities.contains(entry.key);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isAvailable ? AppColors.primaryExtraLight : AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAvailable
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                entry.value,
                size: 16,
                color: isAvailable ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                entry.key,
                style: AppTypography.labelMedium.copyWith(
                  color: isAvailable ? AppColors.primaryDark : AppColors.textTertiary,
                  decoration: isAvailable ? null : TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
