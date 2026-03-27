import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../config/assets.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? currentUserEmail;
  final int currentIndex;
  final VoidCallback? onSellProperty;
  final VoidCallback? onNotifications;
  final VoidCallback? onFilter;
  final ValueChanged<int>? onNavTap;
  final int notificationCount;

  const AppHeader({
    super.key,
    this.currentUserEmail,
    this.currentIndex = 0,
    this.onSellProperty,
    this.onNotifications,
    this.onFilter,
    this.onNavTap,
    this.notificationCount = 0,
  });

  bool get _isAdmin => currentUserEmail == 'yestatehub@gmail.com';
  bool get _isLoggedIn => currentUserEmail != null && currentUserEmail!.isNotEmpty;

  @override
  Size get preferredSize => const Size.fromHeight(90);

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final hPad = Responsive.value<double>(context, mobile: 16, tablet: 20, desktop: 40);
    final logoH = Responsive.value<double>(context, mobile: 40, tablet: 50, desktop: 62);

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Row(
            children: [
              // ── Filter icon ──
              GestureDetector(
                onTap: onFilter,
                child: SvgPicture.asset(
                  AppAssets.icFilter,
                  width: 22,
                  height: 22,
                  colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn),
                ),
              ),
              const SizedBox(width: 10),

              // ── Logo ──
              GestureDetector(
                onTap: () => onNavTap?.call(0),
                child: Image.asset(
                  AppAssets.logo,
                  height: logoH,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(),

              // ── Nav links — desktop only (now on right side) ──
              if (isDesktop) ...[
                _searchNavLink(),
                _navLinkSvg('Analytics', 6, AppAssets.icAnalytic),
                _navLink('Dashboard', 2, Icons.dashboard_outlined),
                _navLinkSvg('Chat', 3, AppAssets.icMessage),
                _navLinkSvg('Favourites', 4, AppAssets.icHeart),
                if (_isAdmin) _navLinkSvg('Admin', 5, AppAssets.icAdminPanel),
                const SizedBox(width: 8),
              ],

              // ── Notification bell ──
              if (_isLoggedIn)
                _buildNotificationBell(),

              const SizedBox(width: 12),

              // ── Add Property CTA — tablet + desktop ──
              ElevatedButton.icon(
                onPressed: onSellProperty,
                icon: SvgPicture.asset(AppAssets.icAddProperty, width: 18, height: 18, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                label: Text(
                  'Add Property',
                  style: AppTypography.buttonMedium.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(width: 14),

              // ── User avatar ──
              _buildUserAvatar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchNavLink() {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: GestureDetector(
        onTap: () => onNavTap?.call(1),
        child: Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.textPrimary, width: 2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(AppAssets.icSearch, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
              const SizedBox(width: 6),
              Text(
                'Search properties',
                style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLinkSvg(String label, int index, String svgPath) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: GestureDetector(
        onTap: () => onNavTap?.call(index),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(svgPath, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navLink(String label, int index, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: GestureDetector(
        onTap: () => onNavTap?.call(index),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.textPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    return GestureDetector(
      onTap: onNotifications,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SvgPicture.asset(AppAssets.icBell, width: 24, height: 24, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
            ),
          ),
          if (notificationCount > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    notificationCount > 9 ? '9+' : '$notificationCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    if (!_isLoggedIn) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Login',
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: () => onNavTap?.call(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              (currentUserEmail ?? 'U')[0].toUpperCase(),
              style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
