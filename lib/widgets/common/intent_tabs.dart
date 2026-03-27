import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

class IntentTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<String> tabs;

  const IntentTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    this.tabs = const ['Buy', 'Rent', 'PG', 'Commercial', 'Services'],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: index < tabs.length - 1 ? 10 : 0),
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  tabs[index],
                  style: AppTypography.labelLarge.copyWith(
                    color: isSelected ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
