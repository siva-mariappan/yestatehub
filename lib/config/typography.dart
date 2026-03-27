import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// YEstateHub Typography System
/// Inter font family — clean, legible, data-focused
class AppTypography {
  AppTypography._();

  static TextStyle get _baseStyle => GoogleFonts.inter(
        color: AppColors.textPrimary,
      );

  // ─── Display ────────────────────────────────────────────────────
  static TextStyle get displayLarge => _baseStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => _baseStyle.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle get displaySmall => _baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  // ─── Headings ───────────────────────────────────────────────────
  static TextStyle get headingLarge => _baseStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headingMedium => _baseStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.35,
      );

  static TextStyle get headingSmall => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ─── Body ───────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  // ─── Labels ─────────────────────────────────────────────────────
  static TextStyle get labelLarge => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelMedium => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get labelSmall => _baseStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.5,
      );

  // ─── Price ──────────────────────────────────────────────────────
  static TextStyle get priceHero => _baseStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        height: 1.2,
      );

  static TextStyle get priceLarge => _baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get priceMedium => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  // ─── Button ─────────────────────────────────────────────────────
  static TextStyle get buttonLarge => _baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle get buttonMedium => _baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle get buttonSmall => _baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );
}
