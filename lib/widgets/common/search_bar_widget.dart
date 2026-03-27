import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/assets.dart';

class SearchBarWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final bool expanded;
  final String hint;

  const SearchBarWidget({
    super.key,
    this.onTap,
    this.onChanged,
    this.controller,
    this.autofocus = false,
    this.expanded = false,
    this.hint = 'Search locality, landmark or project',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.primary.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            SvgPicture.asset(AppAssets.icLocation, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
            const SizedBox(width: 12),
            Expanded(
              child: expanded
                  ? TextField(
                      controller: controller,
                      autofocus: autofocus,
                      onChanged: onChanged,
                      style: AppTypography.bodyMedium,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    )
                  : Text(
                      hint,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
            ),
            Container(
              width: 1,
              height: 24,
              color: AppColors.border,
            ),
            const SizedBox(width: 12),
            const Icon(Icons.mic_none_rounded, color: AppColors.textTertiary, size: 22),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
