import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';

/// Profile Tab — user info, settings, account management
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Avatar & Name Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 44, color: AppColors.primary),
                ),
                const SizedBox(height: 14),
                Text('JSV', style: AppTypography.headingMedium.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text('jsv@gmail.com', style: AppTypography.bodySmall.copyWith(color: Colors.white70)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Premium Member', style: AppTypography.labelMedium.copyWith(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Quick Stats ──
          Row(
            children: [
              _quickStat('Properties', '3'),
              const SizedBox(width: 12),
              _quickStat('Saved', '12'),
              const SizedBox(width: 12),
              _quickStat('Enquiries', '47'),
            ],
          ),
          const SizedBox(height: 24),

          // ── Account Section ──
          _sectionTitle('Account'),
          const SizedBox(height: 10),
          _menuItem(Icons.person_outline, 'Edit Profile', 'Name, photo, phone'),
          _menuItem(Icons.lock_outline, 'Change Password', 'Update your password'),
          _menuItem(Icons.verified_user_outlined, 'KYC Verification', 'Verify your identity'),
          _menuItem(Icons.location_on_outlined, 'Saved Addresses', 'Manage addresses'),

          const SizedBox(height: 20),

          // ── Preferences Section ──
          _sectionTitle('Preferences'),
          const SizedBox(height: 10),
          _menuItem(Icons.notifications_outlined, 'Notifications', 'Email, push, SMS'),
          _menuItem(Icons.language, 'Language', 'English'),
          _menuItem(Icons.dark_mode_outlined, 'Dark Mode', 'Coming soon'),
          _menuItem(Icons.tune, 'Search Preferences', 'Default filters'),

          const SizedBox(height: 20),

          // ── Support Section ──
          _sectionTitle('Support'),
          const SizedBox(height: 10),
          _menuItem(Icons.help_outline, 'Help Center', 'FAQs & guides'),
          _menuItem(Icons.chat_bubble_outline, 'Contact Support', 'Chat or email us'),
          _menuItem(Icons.description_outlined, 'Terms & Privacy', 'Legal documents'),
          _menuItem(Icons.info_outline, 'About YEstateHub', 'Version 1.0.0'),

          const SizedBox(height: 24),

          // ── Sign Out ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text('Sign Out', style: AppTypography.buttonMedium.copyWith(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _quickStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Text(value, style: AppTypography.headingLarge.copyWith(color: AppColors.primary)),
            const SizedBox(height: 4),
            Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: AppTypography.headingSmall),
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        title: Text(title, style: AppTypography.labelLarge),
        subtitle: Text(subtitle, style: AppTypography.bodySmall),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
        onTap: () {},
      ),
    );
  }
}
