import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../config/assets.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F0F2),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 20,
              vertical: 40,
            ),
            child: Column(
              children: [
                isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                const SizedBox(height: 32),
                Divider(color: AppColors.border),
                const SizedBox(height: 20),
                // Bottom bar
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    Text(
                      '\u00A9 2026 YEstateHub. All rights reserved.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                    ),
                    // Social icons using SVGs
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _socialSvgIcon(AppAssets.icFacebook),
                        _socialSvgIcon(AppAssets.icInstagram),
                        _socialSvgIcon(AppAssets.icTwitter),
                        _socialSvgIcon(AppAssets.icYoutube),
                        _socialSvgIcon(AppAssets.icWhatsapp),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand column with logo from assets
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(AppAssets.logo, height: 40, fit: BoxFit.contain),
              const SizedBox(height: 12),
              Text(
                'Your complete home journey platform.\nFind, rent, buy, and manage — all in one place.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SvgPicture.asset(AppAssets.icMail, width: 16, height: 16, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                  const SizedBox(width: 6),
                  Text(
                    'support@yestatehub.com',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SvgPicture.asset(AppAssets.icPhone, width: 16, height: 16, colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                  const SizedBox(width: 6),
                  Text(
                    '+91 9876 543 210',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        // Quick links
        Expanded(flex: 2, child: _linkColumn('Company', ['About Us', 'Careers', 'Blog', 'Press', 'Contact'])),
        Expanded(flex: 2, child: _linkColumn('Properties', ['Buy', 'Rent', 'PG / Co-living', 'Commercial', 'New Projects'])),
        Expanded(flex: 2, child: _linkColumn('Services', ['Pay Rent', 'Rent Agreement', 'Packers & Movers', 'Home Cleaning', 'Interiors'])),
        Expanded(flex: 2, child: _linkColumn('Resources', ['Price Trends', 'Locality Guide', 'EMI Calculator', 'RERA Info', 'Legal Help'])),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(AppAssets.logo, height: 32, fit: BoxFit.contain),
        const SizedBox(height: 8),
        Text(
          'Your complete home journey platform.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 20,
          runSpacing: 14,
          children: [
            _linkItem('About'),
            _linkItem('Buy'),
            _linkItem('Rent'),
            _linkItem('Services'),
            _linkItem('Contact'),
            _linkItem('Blog'),
            _linkItem('Careers'),
          ],
        ),
      ],
    );
  }

  Widget _linkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary, fontSize: 14),
        ),
        const SizedBox(height: 14),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  link,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            )),
      ],
    );
  }

  Widget _linkItem(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
    );
  }

  Widget _socialSvgIcon(String svgPath) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: SvgPicture.asset(svgPath, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn)),
          ),
        ),
      ),
    );
  }
}
