import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import 'sp_settings_screen.dart';
import 'sp_reviews_screen.dart';
import 'sp_chat_screen.dart';
import 'sp_notifications_screen.dart';

class SpProfileScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const SpProfileScreen({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildStatsBar(),
              const SizedBox(height: 20),
              _buildCompletionCard(),
              const SizedBox(height: 24),
              _buildMenuSection('Account Settings', [
                _menuItem(Icons.person_outline_rounded, 'Edit Profile', 'Name, photo, bio', AppColors.primary),
                _menuItem(Icons.location_on_outlined, 'Service Areas', 'Hyderabad, Secunderabad +3', AppColors.info),
                _menuItem(Icons.verified_outlined, 'Verification', 'ID & address proof verified', const Color(0xFF8B5CF6)),
                _menuItem(Icons.account_balance_outlined, 'Bank Details', 'HDFC ****1234', const Color(0xFFF59E0B)),
              ]),
              const SizedBox(height: 16),
              _buildMenuSection('Work Preferences', [
                _menuItem(Icons.notifications_outlined, 'Notifications', 'Booking alerts, reviews', AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpNotificationsScreen()))),
                _menuItem(Icons.schedule_outlined, 'Availability', 'Mon-Sat, 8 AM - 6 PM', AppColors.info),
                _menuItem(Icons.star_outline_rounded, 'Reviews & Ratings', '4.8 avg from 86 reviews', const Color(0xFFEC4899), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpReviewsScreen()))),
                _menuItem(Icons.chat_bubble_outline_rounded, 'Messages', '3 unread conversations', AppColors.info, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpChatScreen()))),
              ]),
              const SizedBox(height: 16),
              _buildMenuSection('Help & Support', [
                _menuItem(Icons.settings_outlined, 'Settings', 'Notifications, preferences, security', AppColors.primary, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpSettingsScreen()))),
                _menuItem(Icons.help_outline_rounded, 'Help Center', 'FAQs & troubleshooting', AppColors.info),
                _menuItem(Icons.headset_mic_outlined, 'Contact Support', '24/7 chat & call', const Color(0xFF8B5CF6)),
                _menuItem(Icons.description_outlined, 'Terms & Policies', 'Service agreements', AppColors.textSecondary),
              ]),
              const SizedBox(height: 24),
              // Logout
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Material(
                  color: AppColors.error.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: onLogout,
                    borderRadius: BorderRadius.circular(14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                        const SizedBox(width: 10),
                        Text('Logout', style: AppTypography.labelLarge.copyWith(color: AppColors.error)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(top: -20, right: -15, child: Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06)))),
          Positioned(bottom: -15, left: 30, child: Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04)))),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Avatar with ring
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2.5),
                  ),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: Text('J', style: AppTypography.displayMedium.copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('JSV', style: AppTypography.headingLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('jsv@gmail.com', style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.7))),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _profileBadge(Icons.verified_rounded, 'Verified', Colors.greenAccent),
                    _profileBadge(Icons.workspace_premium_rounded, 'Pro', Colors.amberAccent),
                    _profileBadge(Icons.star_rounded, '4.8', Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileBadge(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 5),
          Text(label, style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          _statItem('4.8', 'Rating', Icons.star_rounded, AppColors.amber),
          _vDivider(),
          _statItem('156', 'Jobs', Icons.work_rounded, AppColors.info),
          _vDivider(),
          _statItem('98%', 'On Time', Icons.timer_rounded, AppColors.primary),
          _vDivider(),
          _statItem('2 yrs', 'Exp', Icons.calendar_today_rounded, const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.headingSmall.copyWith(color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 44, color: AppColors.border.withOpacity(0.5));

  Widget _buildCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.shield_rounded, size: 24, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile 85% Complete', style: AppTypography.labelMedium.copyWith(color: AppColors.primaryDark)),
                const SizedBox(height: 4),
                Text('Add portfolio photos to boost your visibility', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 8),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.85,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('Complete', style: AppTypography.labelSmall.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: AppTypography.labelMedium.copyWith(color: AppColors.textTertiary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  e.value,
                  if (e.key < items.length - 1) Divider(height: 1, indent: 68, color: AppColors.border.withOpacity(0.5)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
        ],
      ),
    ),
    );
  }
}
