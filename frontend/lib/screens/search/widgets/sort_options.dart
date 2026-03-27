import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';

class SortOptions extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  const SortOptions({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  static const _options = [
    'Relevance',
    'Price: Low to High',
    'Price: High to Low',
    'Newest First',
    'Most Viewed',
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSortChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              selectedSort,
              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
      itemBuilder: (context) => _options.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              if (option == selectedSort)
                const Icon(Icons.check, size: 16, color: AppColors.primary)
              else
                const SizedBox(width: 16),
              const SizedBox(width: 8),
              Text(
                option,
                style: AppTypography.bodyMedium.copyWith(
                  color: option == selectedSort ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: option == selectedSort ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
