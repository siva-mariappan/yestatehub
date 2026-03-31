import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../config/responsive.dart';
import '../../../services/property_store.dart';

/// Profile Tab — Premium user profile with sections, settings, and account management
class ProfileTab extends StatelessWidget {
  final VoidCallback? onLogout;
  const ProfileTab({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = isMobile ? 16.0 : 28.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(hPad),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              // ── Profile Header Card ──
              _buildProfileCard(context, isMobile),
              const SizedBox(height: 20),

              // ── Quick Stats ──
              _buildQuickStats(isMobile),
              const SizedBox(height: 24),

              // ── Account Section ──
              _buildSection(context, 'Account', [
                _MenuItem(Icons.person_outline_rounded, 'Edit Profile', 'Name, photo, phone', AppColors.primary, onTap: () => _showEditProfileDialog(context)),
                _MenuItem(Icons.lock_outline_rounded, 'Change Password', 'Update your password', AppColors.info, onTap: () => _showChangePasswordDialog(context)),
                _MenuItem(Icons.verified_user_outlined, 'KYC Verification', 'Verify your identity', AppColors.primaryDark, onTap: () => _showComingSoon(context, 'KYC Verification')),
                _MenuItem(Icons.location_on_outlined, 'Saved Addresses', 'Manage addresses', AppColors.amber, onTap: () => _showComingSoon(context, 'Saved Addresses')),
              ]),
              const SizedBox(height: 20),

              // ── Preferences Section ──
              _buildSection(context, 'Preferences', [
                _MenuItem(Icons.notifications_outlined, 'Notifications', 'Email, push, SMS', AppColors.primary, onTap: () => _showNotificationPrefs(context)),
                _MenuItem(Icons.language_rounded, 'Language', 'English', AppColors.info, onTap: () => _showLanguageDialog(context)),
                _MenuItem(Icons.dark_mode_outlined, 'Dark Mode', 'Coming soon', const Color(0xFF8B5CF6), onTap: () => _showComingSoon(context, 'Dark Mode')),
                _MenuItem(Icons.tune_rounded, 'Search Preferences', 'Default filters', AppColors.amber, onTap: () => _showComingSoon(context, 'Search Preferences')),
              ]),
              const SizedBox(height: 20),

              // ── Support Section ──
              _buildSection(context, 'Support', [
                _MenuItem(Icons.help_outline_rounded, 'Help Center', 'FAQs & guides', AppColors.primary, onTap: () => _showHelpCenter(context)),
                _MenuItem(Icons.chat_bubble_outline_rounded, 'Contact Support', 'Chat or email us', AppColors.info, onTap: () => _showContactSupport(context)),
                _MenuItem(Icons.description_outlined, 'Terms & Privacy', 'Legal documents', AppColors.textSecondary, onTap: () => _showTermsPrivacy(context)),
                _MenuItem(Icons.info_outline_rounded, 'About YEstateHub', 'Version 1.0.0', AppColors.primaryDark, onTap: () => _showAbout(context)),
              ]),
              const SizedBox(height: 20),

              // ── Join as Service Provider ──
              _buildJoinServiceProviderCard(context),
              const SizedBox(height: 24),

              // ── Sign Out ──
              GestureDetector(
                onTap: onLogout,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                      const SizedBox(width: 10),
                      Text(
                        'Sign Out',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.error, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PROFILE CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildProfileCard(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            FirebaseAuth.instance.currentUser?.displayName ?? 'User',
            style: AppTypography.headingLarge.copyWith(color: Colors.white, fontSize: isMobile ? 22 : 24),
          ),
          const SizedBox(height: 4),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? '',
            style: AppTypography.bodySmall.copyWith(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 14),
          // Badges row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProfileBadge(Icons.workspace_premium_rounded, 'Premium'),
              const SizedBox(width: 10),
              _buildProfileBadge(Icons.verified_rounded, 'Verified'),
            ],
          ),
          const SizedBox(height: 16),
          // Edit profile button
          GestureDetector(
            onTap: () => _showEditProfileDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // QUICK STATS
  // ═══════════════════════════════════════════════════════════════
  Widget _buildQuickStats(bool isMobile) {
    final propCount = PropertyStore.instance.properties.length;
    final stats = [
      _QuickStat('Properties', '$propCount', Icons.home_work_rounded, AppColors.primary),
      _QuickStat('Saved', '12', Icons.favorite_rounded, AppColors.error),
      _QuickStat('Enquiries', '47', Icons.mark_email_read_rounded, AppColors.amber),
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: stat == stats.last ? 0 : 12),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: stat.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(stat.icon, size: 18, color: stat.color),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stat.value,
                    style: AppTypography.headingLarge.copyWith(color: AppColors.textPrimary, fontSize: isMobile ? 22 : 24),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stat.label,
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SETTINGS SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSection(BuildContext context, String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(title, style: AppTypography.headingSmall.copyWith(fontSize: 16)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1)),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, size: 20, color: item.color),
                      ),
                      title: Text(
                        item.title,
                        style: AppTypography.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        style: AppTypography.bodySmall.copyWith(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                      onTap: item.onTap,
                    ),
                  ),
                  if (!isLast)
                    Divider(height: 1, indent: 66, endIndent: 16, color: AppColors.border.withOpacity(0.5)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // JOIN AS SERVICE PROVIDER CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildJoinServiceProviderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D5F8B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.home_repair_service_rounded, size: 28, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          // Text + button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join as Service Provider',
                  style: AppTypography.headingSmall.copyWith(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Offer your services to thousands of homeowners. Start earning today!',
                  style: AppTypography.bodySmall.copyWith(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    _showComingSoon(context, 'Service Provider Registration');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Get Started',
                          style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DIALOGS AND ACTIONS
  // ═══════════════════════════════════════════════════════════════

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nameController = TextEditingController(text: user?.displayName ?? '');
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.person_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            const Text('Edit Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Display Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Email: ${user?.email ?? 'N/A'}',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                await user?.updateDisplayName(nameController.text.trim());
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully'), behavior: SnackBarBehavior.floating),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final emailController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppColors.info),
            const SizedBox(width: 10),
            const Text('Change Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We will send a password reset link to your email address.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset email sent!'), behavior: SnackBarBehavior.floating),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Send Reset Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showNotificationPrefs(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _NotificationPrefsDialog(),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Language'),
        children: [
          for (final lang in ['English', 'Hindi', 'Telugu', 'Tamil', 'Kannada'])
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language set to $lang'), behavior: SnackBarBehavior.floating),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      lang == 'English' ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: lang == 'English' ? AppColors.primary : AppColors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(lang, style: AppTypography.labelLarge),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showHelpCenter(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.help_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            const Text('Help Center'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _helpItem('How to list a property?', 'Go to Dashboard > Add Property and fill in the details.'),
            const Divider(),
            _helpItem('How to contact a seller?', 'Open any property listing and tap the Call button.'),
            const Divider(),
            _helpItem('How to boost my listing?', 'Go to My Properties and tap the Boost button.'),
            const Divider(),
            _helpItem('How to delete my account?', 'Contact support at support@yestatehub.com.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _helpItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: AppTypography.labelLarge.copyWith(fontSize: 13)),
          const SizedBox(height: 4),
          Text(a, style: AppTypography.bodySmall.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  void _showContactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.support_agent_rounded, color: AppColors.info),
            const SizedBox(width: 10),
            const Text('Contact Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _contactRow(Icons.email_outlined, 'support@yestatehub.com'),
            const SizedBox(height: 12),
            _contactRow(Icons.phone_outlined, '+91 9876543210'),
            const SizedBox(height: 12),
            _contactRow(Icons.access_time_rounded, 'Mon-Sat, 9 AM - 6 PM'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(text, style: AppTypography.bodyMedium),
      ],
    );
  }

  void _showTermsPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Terms & Privacy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terms of Service', style: AppTypography.headingSmall.copyWith(fontSize: 15)),
              const SizedBox(height: 8),
              Text(
                'By using YEstateHub, you agree to our terms of service. '
                'All property listings must be accurate and truthful. '
                'Users are responsible for their own transactions.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 16),
              Text('Privacy Policy', style: AppTypography.headingSmall.copyWith(fontSize: 15)),
              const SizedBox(height: 8),
              Text(
                'We collect minimal personal data required for providing our services. '
                'Your data is encrypted and never shared with third parties without consent. '
                'You can request data deletion at any time.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'YEstateHub',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.home_rounded, color: Colors.white, size: 28),
      ),
      children: [
        const Text('Your one-stop real estate platform for buying, selling, and renting properties in India.'),
      ],
    );
  }
}

// ── Notification Preferences Dialog (Stateful) ──
class _NotificationPrefsDialog extends StatefulWidget {
  @override
  State<_NotificationPrefsDialog> createState() => _NotificationPrefsDialogState();
}

class _NotificationPrefsDialogState extends State<_NotificationPrefsDialog> {
  bool _emailNotif = true;
  bool _pushNotif = true;
  bool _smsNotif = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.notifications_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          const Text('Notifications'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            value: _emailNotif,
            onChanged: (v) => setState(() => _emailNotif = v),
            title: const Text('Email Notifications'),
            subtitle: const Text('Property updates, enquiries'),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            value: _pushNotif,
            onChanged: (v) => setState(() => _pushNotif = v),
            title: const Text('Push Notifications'),
            subtitle: const Text('Instant alerts'),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            value: _smsNotif,
            onChanged: (v) => setState(() => _smsNotif = v),
            title: const Text('SMS Notifications'),
            subtitle: const Text('Important updates via SMS'),
            activeColor: AppColors.primary,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification preferences saved'), behavior: SnackBarBehavior.floating),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ── Data classes ──
class _MenuItem {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback? onTap;
  const _MenuItem(this.icon, this.title, this.subtitle, this.color, {this.onTap});
}

class _QuickStat {
  final String label, value;
  final IconData icon;
  final Color color;
  const _QuickStat(this.label, this.value, this.icon, this.color);
}
