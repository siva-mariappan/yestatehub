import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../config/responsive.dart';
import '../../../config/assets.dart';
import '../../../services/property_store.dart';
import '../../add_property/add_property_wizard.dart';
import '../../analytics/analytics_screen.dart';
import '../../notifications/notifications_screen.dart';

/// Dashboard Overview — Premium stats, performance chart, recent activity, quick actions
class DashboardOverviewTab extends StatelessWidget {
  final VoidCallback? onNavigateToMessages;
  final VoidCallback? onNavigateToProperties;

  const DashboardOverviewTab({
    super.key,
    this.onNavigateToMessages,
    this.onNavigateToProperties,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = isMobile ? 16.0 : 28.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(hPad),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Welcome Banner ──
              _buildWelcomeBanner(context, isMobile),
              SizedBox(height: isMobile ? 20 : 24),

              // ── Stats Cards Grid ──
              _buildStatsGrid(context, isMobile),
              SizedBox(height: isMobile ? 20 : 28),

              // ── Performance Chart + Quick Actions Row ──
              isMobile
                  ? Column(
                      children: [
                        _buildPerformanceCard(isMobile),
                        const SizedBox(height: 16),
                        _buildQuickActionsCard(context, isMobile),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildPerformanceCard(isMobile)),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _buildQuickActionsCard(context, isMobile)),
                      ],
                    ),
              SizedBox(height: isMobile ? 20 : 28),

              // ── Recent Activity ──
              _buildRecentActivitySection(context, isMobile),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WELCOME BANNER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildWelcomeBanner(BuildContext context, bool isMobile) {
    final propCount = PropertyStore.instance.properties.length;
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${FirebaseAuth.instance.currentUser?.displayName?.split(' ').first ?? 'User'}!',
                  style: AppTypography.headingLarge.copyWith(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  propCount > 0
                      ? 'You have $propCount properties listed. Keep growing your portfolio!'
                      : 'Start listing your properties to reach thousands of buyers.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyWizard()));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_home_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Add New Property',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 24),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SvgPicture.asset(AppAssets.icAnalytic, width: 48, height: 48, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STATS GRID
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStatsGrid(BuildContext context, bool isMobile) {
    final propCount = PropertyStore.instance.properties.length;
    final stats = [
      _StatData(Icons.home_work_rounded, 'Active Listings', '$propCount', '+1 this month', AppColors.primary, AppColors.primaryExtraLight),
      _StatData(Icons.visibility_rounded, 'Total Views', '1,284', '+12% vs last week', AppColors.info, AppColors.infoLight),
      _StatData(Icons.mark_email_read_rounded, 'Enquiries', '47', '+5 new today', AppColors.amber, AppColors.amberLight),
      _StatData(Icons.speed_rounded, 'Response Rate', '92%', '+3% improvement', AppColors.primaryDark, const Color(0xFFD1FAE5)),
    ];

    final cols = Responsive.value<int>(context, mobile: 2, tablet: 4, desktop: 4);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: isMobile ? 12 : 16,
        crossAxisSpacing: isMobile ? 12 : 16,
        childAspectRatio: isMobile ? 1.15 : 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => _buildStatCard(stats[index], isMobile),
    );
  }

  Widget _buildStatCard(_StatData stat, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Container(
            width: isMobile ? 38 : 42,
            height: isMobile ? 38 : 42,
            decoration: BoxDecoration(
              color: stat.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, size: isMobile ? 20 : 22, color: stat.color),
          ),
          const Spacer(),
          // Value
          Text(
            stat.value,
            style: AppTypography.headingLarge.copyWith(
              fontSize: isMobile ? 22 : 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          // Label
          Text(
            stat.label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 11 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Trend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.trending_up_rounded, size: 12, color: stat.color),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    stat.trend,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: stat.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
  // PERFORMANCE CARD (Chart Placeholder)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPerformanceCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Property Views', style: AppTypography.headingSmall),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('This Week', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart placeholder with bar chart visual
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar('Mon', 0.45, AppColors.primary.withOpacity(0.3)),
                _buildChartBar('Tue', 0.65, AppColors.primary.withOpacity(0.4)),
                _buildChartBar('Wed', 0.85, AppColors.primary.withOpacity(0.6)),
                _buildChartBar('Thu', 0.55, AppColors.primary.withOpacity(0.4)),
                _buildChartBar('Fri', 0.95, AppColors.primary),
                _buildChartBar('Sat', 0.70, AppColors.primary.withOpacity(0.5)),
                _buildChartBar('Sun', 0.40, AppColors.primary.withOpacity(0.3)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Summary row
          Row(
            children: [
              _buildChartSummary('Total Views', '1,284', AppColors.primary),
              const SizedBox(width: 20),
              _buildChartSummary('Avg/Day', '183', AppColors.info),
              const SizedBox(width: 20),
              _buildChartSummary('Peak Day', 'Friday', AppColors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String label, double ratio, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 140 * ratio,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSummary(String label, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.labelLarge.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // QUICK ACTIONS CARD
  // ═══════════════════════════════════════════════════════════════
  Widget _buildQuickActionsCard(BuildContext context, bool isMobile) {
    final actions = [
      _ActionData(Icons.add_home_rounded, 'Add Property', AppColors.primary, AppColors.primaryExtraLight, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPropertyWizard()));
      }),
      _ActionData(Icons.rocket_launch_rounded, 'Boost Listing', AppColors.amber, AppColors.amberLight, onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Boost feature coming soon!'), behavior: SnackBarBehavior.floating),
        );
      }),
      _ActionData(null, 'View EstateIQ', AppColors.info, AppColors.infoLight, svgAsset: AppAssets.icAnalytic, onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
      }),
      _ActionData(Icons.support_agent_rounded, 'Get Support', AppColors.primaryDark, const Color(0xFFD1FAE5), onTap: () {
        _showSupportDialog(context);
      }),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTypography.headingSmall),
          const SizedBox(height: 16),
          ...actions.map((action) => _buildActionItem(action, isMobile)),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.support_agent_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            const Text('Get Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Reach out to us:', style: AppTypography.bodyMedium),
            const SizedBox(height: 16),
            _supportRow(Icons.email_outlined, 'support@yestatehub.com'),
            const SizedBox(height: 10),
            _supportRow(Icons.phone_outlined, '+91 9876543210'),
            const SizedBox(height: 10),
            _supportRow(Icons.access_time_rounded, 'Mon-Sat, 9 AM - 6 PM'),
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

  Widget _supportRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(text, style: AppTypography.bodySmall),
      ],
    );
  }

  Widget _buildActionItem(_ActionData action, bool isMobile) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(isMobile ? 12 : 14),
        decoration: BoxDecoration(
          color: action.bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: action.color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: action.color.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: action.svgAsset != null
                  ? SvgPicture.asset(action.svgAsset!, width: 20, height: 20, colorFilter: ColorFilter.mode(action.color, BlendMode.srcIn))
                  : Icon(action.icon, size: 20, color: action.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                action.label,
                style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: action.color),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RECENT ACTIVITY
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRecentActivitySection(BuildContext context, bool isMobile) {
    final activities = [
      _ActivityData(Icons.person_add_rounded, 'New enquiry from Rahul Sharma', 'On: 3 BHK in Gachibowli', '2 hours ago', AppColors.primary),
      _ActivityData(Icons.visibility_rounded, 'Your listing got 45 new views', '2 BHK Kondapur — trending', '5 hours ago', AppColors.info),
      _ActivityData(Icons.favorite_rounded, 'Priya saved your property', '3 BHK Gachibowli', '1 day ago', AppColors.error),
      _ActivityData(Icons.trending_up_rounded, 'Prices up 5% in Kokapet', 'Market update', '2 days ago', AppColors.primaryDark),
      _ActivityData(Icons.chat_bubble_rounded, 'New message from buyer', 'About Villa in Kokapet', '3 days ago', AppColors.amber),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: AppTypography.headingSmall),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'View All',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...activities.map((a) => _buildActivityCard(a, isMobile)),
      ],
    );
  }

  Widget _buildActivityCard(_ActivityData activity, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity.icon, size: 20, color: activity.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: AppTypography.labelLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: AppTypography.bodySmall.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.time,
                style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10),
              ),
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: activity.color.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Data models ──
class _StatData {
  final IconData icon;
  final String label, value, trend;
  final Color color, bgColor;
  const _StatData(this.icon, this.label, this.value, this.trend, this.color, this.bgColor);
}

class _ActionData {
  final IconData? icon;
  final String? svgAsset;
  final String label;
  final Color color, bgColor;
  final VoidCallback? onTap;
  const _ActionData(this.icon, this.label, this.color, this.bgColor, {this.svgAsset, this.onTap});
}

class _ActivityData {
  final IconData icon;
  final String title, subtitle, time;
  final Color color;
  const _ActivityData(this.icon, this.title, this.subtitle, this.time, this.color);
}
