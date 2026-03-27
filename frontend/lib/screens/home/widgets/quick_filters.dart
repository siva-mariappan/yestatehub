import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../config/assets.dart';

class QuickFilters extends StatelessWidget {
  final List<String> filters;
  final ValueChanged<String> onFilterTap;

  const QuickFilters({
    super.key,
    required this.filters,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onFilterTap(filters[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index == 0) ...[
                    SvgPicture.asset(AppAssets.icFilter, width: 14, height: 14, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    filters[index],
                    style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
