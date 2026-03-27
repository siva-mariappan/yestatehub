import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../data/mock_data.dart';

class CitySelector extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCityChanged;

  const CitySelector({
    super.key,
    required this.selectedCity,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCitySheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryExtraLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              selectedCity,
              style: AppTypography.labelMedium.copyWith(color: AppColors.primaryDark),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.primaryDark),
          ],
        ),
      ),
    );
  }

  void _showCitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Select City', style: AppTypography.headingMedium),
              const SizedBox(height: 8),
              Text(
                'Choose a city to browse properties',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 20),
              // Search
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: MockData.cities.map((city) {
                  final isSelected = city == selectedCity;
                  return GestureDetector(
                    onTap: () {
                      onCityChanged(city);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            const Icon(Icons.check_circle, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            city,
                            style: AppTypography.labelLarge.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
