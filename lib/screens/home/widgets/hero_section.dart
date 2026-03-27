import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../config/responsive.dart';
import '../../../config/assets.dart';
import '../../../widgets/common/typewriter_text.dart';
import '../../../data/mock_data.dart';

class HeroSection extends StatelessWidget {
  final String selectedCity;
  final ValueChanged<String> onCityChanged;

  const HeroSection({
    super.key,
    required this.selectedCity,
    required this.onCityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final hPad = Responsive.value<double>(context, mobile: 20, tablet: 30, desktop: 40);
    final vPadTop = Responsive.value<double>(context, mobile: 36, tablet: 44, desktop: 60);
    final vPadBottom = Responsive.value<double>(context, mobile: 32, tablet: 40, desktop: 48);
    final headlineSize = Responsive.value<double>(context, mobile: 26, tablet: 32, desktop: 38);
    final subSize = Responsive.value<double>(context, mobile: 14, tablet: 15, desktop: 16);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.navyGradient,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, vPadTop, hPad, vPadBottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TypewriterText(
                      texts: const [
                        'Find Your Perfect Home Without Any Hassle',
                        'Zero Brokerage. Direct Owner Deals.',
                        'Buy, Rent or Sell — All in One Place',
                        'Trusted by Thousands Across India',
                      ],
                      style: GoogleFonts.inter(
                        fontSize: headlineSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Browse verified listings with zero brokerage across India\'s top cities',
                      style: GoogleFonts.inter(
                        fontSize: subSize,
                        color: Colors.white.withOpacity(0.65),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // Search form — tablet shows simplified, desktop shows full
                    isTablet ? _buildTabletSearchForm(context) : _buildDesktopSearchForm(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSearchForm(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSearchFieldSvg(svgPath: AppAssets.icLocation, label: selectedCity, flex: 2, onTap: () => _showCityPicker(context)),
          _divider(),
          _buildSearchFieldSvg(svgPath: AppAssets.icSearch, label: 'Search locality, landmark or project', flex: 4, isHint: true),
          _divider(),
          _buildSearchField(icon: Icons.currency_rupee_rounded, label: 'Budget', flex: 2, isHint: true),
          _divider(),
          _buildSearchField(icon: Icons.bed_rounded, label: 'BHK', flex: 1, isHint: true),
          const SizedBox(width: 6),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildTabletSearchForm(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 700),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSearchFieldSvg(svgPath: AppAssets.icLocation, label: selectedCity, flex: 2, onTap: () => _showCityPicker(context)),
          _divider(),
          _buildSearchFieldSvg(svgPath: AppAssets.icSearch, label: 'Search locality or project', flex: 4, isHint: true),
          const SizedBox(width: 6),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(AppAssets.icSearch, width: 22, height: 22, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
      ),
    );
  }

  Widget _buildSearchField({
    required IconData icon,
    required String label,
    required int flex,
    bool isHint = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isHint ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFieldSvg({
    required String svgPath,
    required String label,
    required int flex,
    bool isHint = false,
    VoidCallback? onTap,
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              SvgPicture.asset(svgPath, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isHint ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 28, color: AppColors.border);
  }

  void _showCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select City', style: AppTypography.headingMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: MockData.cities.map((city) {
                  final isSelected = city == selectedCity;
                  return ChoiceChip(
                    label: Text(city),
                    selected: isSelected,
                    onSelected: (_) {
                      onCityChanged(city);
                      Navigator.pop(context);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
