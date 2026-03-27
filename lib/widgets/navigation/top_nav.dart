import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

class DesktopTopNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String selectedCity;
  final VoidCallback? onPostProperty;

  const DesktopTopNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.selectedCity = 'Hyderabad',
    this.onPostProperty,
  });

  static const _navItems = ['Buy', 'Rent', 'PG', 'Commercial', 'Services', 'Resources'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            children: [
              // Logo
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Y',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'EstateHub',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              // Nav items
              ...List.generate(_navItems.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 28),
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: Text(
                      _navItems[index],
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              // City selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      selectedCity,
                      style: AppTypography.labelMedium.copyWith(color: AppColors.primaryDark),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.primaryDark),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Post Property
              ElevatedButton(
                onPressed: onPostProperty,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Post Property',
                      style: AppTypography.buttonMedium.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Login
              GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primaryLight,
                      child: const Icon(Icons.person, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Login',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
