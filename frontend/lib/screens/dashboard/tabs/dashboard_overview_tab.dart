import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';

/// Dashboard Overview — stats cards, recent activity
class DashboardOverviewTab extends StatelessWidget {
  const DashboardOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Overview', style: AppTypography.headingLarge),
          const SizedBox(height: 16),
          // Stats cards grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.4,
            children: const [
              _StatCard(icon: Icons.home_rounded, label: 'Active Listings', value: '3', trend: '+1', trendUp: true, color: AppColors.primary),
              _StatCard(icon: Icons.visibility_rounded, label: 'Total Views', value: '1,284', trend: '+12%', trendUp: true, color: AppColors.info),
              _StatCard(icon: Icons.message_rounded, label: 'Enquiries', value: '47', trend: '+5', trendUp: true, color: AppColors.amber),
              _StatCard(icon: Icons.speed_rounded, label: 'Response Rate', value: '92%', trend: '+3%', trendUp: true, color: AppColors.primaryDark),
            ],
          ),
          const SizedBox(height: 28),

          Text('Recent Activity', style: AppTypography.headingMedium),
          const SizedBox(height: 14),
          _activityItem(Icons.person_add, 'New enquiry from Rahul Sharma', 'On: 3 BHK in Gachibowli', '2 hours ago', AppColors.primary),
          _activityItem(Icons.visibility, 'Your listing got 45 new views', '2 BHK Kondapur — trending', '5 hours ago', AppColors.info),
          _activityItem(Icons.favorite, 'Priya saved your property', '3 BHK Gachibowli', '1 day ago', AppColors.error),
          _activityItem(Icons.trending_up, 'Prices up 5% in Kokapet', 'Market update', '2 days ago', AppColors.primaryDark),
          _activityItem(Icons.chat_bubble, 'New message from buyer', 'About Villa in Kokapet', '3 days ago', AppColors.amber),
        ],
      ),
    );
  }

  Widget _activityItem(IconData icon, String title, String subtitle, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(subtitle, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Text(time, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String trend;
  final bool trendUp;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendUp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendUp ? AppColors.primaryExtraLight : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: trendUp ? AppColors.primary : AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: trendUp ? AppColors.primary : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(value, style: AppTypography.headingLarge),
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
