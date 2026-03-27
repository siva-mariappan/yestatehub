import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';

class SpSettingsScreen extends StatefulWidget {
  const SpSettingsScreen({super.key});

  @override
  State<SpSettingsScreen> createState() => _SpSettingsScreenState();
}

class _SpSettingsScreenState extends State<SpSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _bookingAlerts = true;
  bool _reviewAlerts = true;
  bool _paymentAlerts = true;
  bool _marketingEmails = false;
  bool _autoAccept = false;
  bool _onlineStatus = true;
  String _language = 'English';
  String _currency = 'INR (\u20B9)';

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: AppTypography.headingMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notifications Section
                _buildSection(
                  'Notifications',
                  Icons.notifications_outlined,
                  AppColors.primary,
                  [
                    _buildToggle('Push Notifications', 'Get notified about bookings & updates', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
                    _buildToggle('Email Notifications', 'Receive updates via email', _emailNotifications, (v) => setState(() => _emailNotifications = v)),
                    _buildToggle('SMS Notifications', 'Get SMS alerts for bookings', _smsNotifications, (v) => setState(() => _smsNotifications = v)),
                  ],
                ),
                const SizedBox(height: 16),

                // Alert Preferences
                _buildSection(
                  'Alert Preferences',
                  Icons.tune_rounded,
                  AppColors.info,
                  [
                    _buildToggle('Booking Alerts', 'New bookings, confirmations & cancellations', _bookingAlerts, (v) => setState(() => _bookingAlerts = v)),
                    _buildToggle('Review Alerts', 'New reviews and ratings', _reviewAlerts, (v) => setState(() => _reviewAlerts = v)),
                    _buildToggle('Payment Alerts', 'Payment received & withdrawal updates', _paymentAlerts, (v) => setState(() => _paymentAlerts = v)),
                    _buildToggle('Marketing Emails', 'Tips, offers & promotional content', _marketingEmails, (v) => setState(() => _marketingEmails = v)),
                  ],
                ),
                const SizedBox(height: 16),

                // Work Preferences
                _buildSection(
                  'Work Preferences',
                  Icons.work_outline_rounded,
                  const Color(0xFF8B5CF6),
                  [
                    _buildToggle('Auto-Accept Bookings', 'Automatically accept new bookings', _autoAccept, (v) => setState(() => _autoAccept = v)),
                    _buildToggle('Show Online Status', 'Let clients see when you\'re available', _onlineStatus, (v) => setState(() => _onlineStatus = v)),
                  ],
                ),
                const SizedBox(height: 16),

                // Language & Region
                _buildSection(
                  'Language & Region',
                  Icons.language_rounded,
                  const Color(0xFFF59E0B),
                  [
                    _buildDropdown('Language', _language, ['English', 'Hindi', 'Telugu', 'Tamil', 'Kannada'], (v) => setState(() => _language = v!)),
                    _buildDropdown('Currency', _currency, ['INR (\u20B9)', 'USD (\$)', 'EUR (\u20AC)'], (v) => setState(() => _currency = v!)),
                  ],
                ),
                const SizedBox(height: 16),

                // Account
                _buildSection(
                  'Account & Security',
                  Icons.shield_outlined,
                  AppColors.navy,
                  [
                    _buildNavItem('Change Password', 'Update your account password', Icons.lock_outline_rounded),
                    _buildNavItem('Two-Factor Authentication', 'Add extra layer of security', Icons.security_rounded),
                    _buildNavItem('Privacy Settings', 'Manage data and visibility', Icons.privacy_tip_outlined),
                    _buildNavItem('Connected Accounts', 'Google, Facebook linked accounts', Icons.link_rounded),
                  ],
                ),
                const SizedBox(height: 16),

                // Data & Storage
                _buildSection(
                  'Data & Storage',
                  Icons.storage_rounded,
                  const Color(0xFFEC4899),
                  [
                    _buildNavItem('Clear Cache', 'Free up storage space', Icons.cached_rounded),
                    _buildNavItem('Download My Data', 'Export your account data', Icons.download_rounded),
                    _buildNavItem('Delete Account', 'Permanently delete your account', Icons.delete_outline_rounded, isDestructive: true),
                  ],
                ),

                const SizedBox(height: 28),

                // App info
                Center(
                  child: Column(
                    children: [
                      Text('YEstateHub Provider', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                      const SizedBox(height: 4),
                      Text('Version 1.0.0', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Text(title, style: AppTypography.labelLarge),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String title, String currentValue, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.labelMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currentValue,
                items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: AppTypography.bodySmall.copyWith(fontSize: 12)))).toList(),
                onChanged: onChanged,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textTertiary),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, String subtitle, IconData icon, {bool isDestructive = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isDestructive ? AppColors.error : AppColors.textSecondary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.labelMedium.copyWith(color: isDestructive ? AppColors.error : AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 18, color: isDestructive ? AppColors.error.withOpacity(0.5) : AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
