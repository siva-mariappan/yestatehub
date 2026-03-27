import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = Responsive.value<double>(context, mobile: 20, tablet: 24, desktop: 40);
    final topPad = isMobile ? MediaQuery.of(context).padding.top + 16 : 24.0;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, 32),
            child: Column(
              children: [
                // Profile header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryLight,
                        child: Text(
                          'P',
                          style: AppTypography.displayMedium.copyWith(color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('JSV', style: AppTypography.headingMedium),
                      const SizedBox(height: 4),
                      Text('jsv@gmail.com', style: AppTypography.bodySmall),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statItem('3', 'Listings'),
                          Container(width: 1, height: 30, color: AppColors.border),
                          _statItem('12', 'Enquiries'),
                          Container(width: 1, height: 30, color: AppColors.border),
                          _statItem('5', 'Saved'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildMenuSection('My Property', [
                  _MenuItem(Icons.home_outlined, 'My Listings', 'Manage your properties'),
                  _MenuItem(Icons.favorite_border, 'Saved Properties', 'Your shortlisted homes'),
                  _MenuItem(Icons.history, 'Recently Viewed', 'Properties you browsed'),
                ]),
                const SizedBox(height: 16),
                _buildMenuSection('Services', [
                  _MenuItem(Icons.payment_rounded, 'Pay Rent', 'Monthly rent payments'),
                  _MenuItem(Icons.calendar_today, 'My Bookings', 'Service bookings'),
                  _MenuItem(Icons.description_outlined, 'Rent Agreement', 'Digital agreements'),
                ]),
                const SizedBox(height: 16),
                _buildMenuSection('Account', [
                  _MenuItem(Icons.person_outline, 'Edit Profile', 'Update your details'),
                  _MenuItem(Icons.notifications_none, 'Notifications', 'Manage alerts'),
                  _MenuItem(Icons.help_outline, 'Help & Support', 'FAQs and contact us'),
                  _MenuItem(Icons.info_outline, 'About', 'App version and policies'),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
                    label: Text(
                      'Sign Out',
                      style: AppTypography.buttonMedium.copyWith(color: AppColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: AppTypography.headingLarge.copyWith(color: AppColors.primary)),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              title,
              style: AppTypography.labelMedium.copyWith(color: AppColors.textTertiary),
            ),
          ),
          ...items.map((item) {
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, size: 18, color: AppColors.primary),
                  ),
                  title: Text(item.title, style: AppTypography.labelLarge),
                  subtitle: Text(item.subtitle, style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                ),
                if (item != items.last)
                  const Divider(indent: 70, height: 1),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MenuItem(this.icon, this.title, this.subtitle);
}
