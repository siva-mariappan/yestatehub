import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import 'sp_home_screen.dart';
import 'sp_bookings_screen.dart';
import 'sp_my_services_screen.dart';
import 'sp_earnings_screen.dart';
import 'sp_profile_screen.dart';
import 'sp_notifications_screen.dart';
import 'sp_chat_screen.dart';

class SpApp extends StatefulWidget {
  final VoidCallback onLogout;
  const SpApp({super.key, required this.onLogout});

  @override
  State<SpApp> createState() => _SpAppState();
}

class _SpAppState extends State<SpApp> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (!isMobile) _buildHeader(),
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: [
                const SpHomeScreen(),
                const SpBookingsScreen(),
                const SpMyServicesScreen(),
                const SpEarningsScreen(),
                SpProfileScreen(onLogout: widget.onLogout),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildBottomNav() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                // Logo
                _buildLogo(),
                const SizedBox(width: 48),
                // Nav links
                ..._buildNavLinks(),
                const Spacer(),
                // Search
                _buildHeaderSearch(),
                const SizedBox(width: 16),
                // Chat
                _buildHeaderIcon(
                  Icons.chat_bubble_outline_rounded,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpChatScreen())),
                  hasBadge: true,
                ),
                const SizedBox(width: 10),
                // Notification
                _buildNotificationBell(),
                const SizedBox(width: 12),
                // Avatar
                _buildHeaderAvatar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          'YEstateHub',
          style: AppTypography.headingSmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'PRO',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildNavLinks() {
    final links = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Bookings', 'icon': Icons.calendar_month_rounded},
      {'label': 'Services', 'icon': Icons.home_repair_service_rounded},
      {'label': 'Earnings', 'icon': Icons.account_balance_wallet_rounded},
    ];
    return links.asMap().entries.map((entry) {
      final isActive = _currentTab == entry.key;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _currentTab = entry.key),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryExtraLight : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    entry.value['icon'] as IconData,
                    size: 16,
                    color: isActive ? AppColors.primary : AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value['label'] as String,
                    style: AppTypography.labelMedium.copyWith(
                      color: isActive ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildHeaderSearch() {
    return Container(
      width: 200,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Text('Search...', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap, {bool hasBadge = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Stack(
            children: [
              Center(child: Icon(icon, size: 20, color: AppColors.textPrimary)),
              if (hasBadge)
                Positioned(
                  right: 9,
                  top: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationBell() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpNotificationsScreen())),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Stack(
            children: [
              const Center(child: Icon(Icons.notifications_outlined, size: 22, color: AppColors.textPrimary)),
              Positioned(
                right: 9,
                top: 9,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderAvatar() {
    return GestureDetector(
      onTap: () => setState(() => _currentTab = 4),
      child: Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _currentTab == 4 ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 17,
          backgroundColor: AppColors.primaryExtraLight,
          child: Text('J', style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Bookings'),
              _buildNavItem(2, Icons.home_repair_service_rounded, Icons.home_repair_service_outlined, 'Services'),
              _buildNavItem(3, Icons.account_balance_wallet_rounded, Icons.account_balance_wallet_outlined, 'Earnings'),
              _buildNavItem(4, Icons.person_rounded, Icons.person_outline_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentTab == index;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? (isSmall ? 10 : 14) : (isSmall ? 8 : 12),
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryExtraLight : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: isSmall
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? activeIcon : inactiveIcon,
                    size: 20,
                    color: isActive ? AppColors.primary : AppColors.textTertiary,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: isActive ? AppColors.primary : AppColors.textTertiary,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 9,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? activeIcon : inactiveIcon,
                    size: 22,
                    color: isActive ? AppColors.primary : AppColors.textTertiary,
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
