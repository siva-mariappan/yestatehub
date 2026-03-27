import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import 'sp_reviews_screen.dart';
import 'sp_add_service_screen.dart';

class SpHomeScreen extends StatelessWidget {
  const SpHomeScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = isMobile ? 16.0 : 28.0;
    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeBanner(context, isMobile),
              const SizedBox(height: 24),
              _buildStatsRow(isMobile),
              const SizedBox(height: 28),
              _buildSectionHeader('Quick Actions', 'Manage your services'),
              const SizedBox(height: 14),
              _buildQuickActions(isMobile, context),
              const SizedBox(height: 28),
              _buildSectionHeader("Today's Schedule", '4 appointments'),
              const SizedBox(height: 14),
              _buildScheduleList(isMobile),
              const SizedBox(height: 28),
              _buildSectionHeader('Recent Reviews', '4.8 avg rating', onTap: () => _navigateTo(context, const SpReviewsScreen())),
              const SizedBox(height: 14),
              _buildRecentReviews(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, {VoidCallback? onTap}) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headingSmall),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('View All', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Decorative elements
          Positioned(top: -30, right: -20, child: _decorCircle(120, 0.06)),
          Positioned(bottom: -20, left: 40, child: _decorCircle(80, 0.05)),
          Positioned(top: 20, right: 80, child: _decorCircle(40, 0.08)),
          // Content
          Padding(
            padding: EdgeInsets.all(isMobile ? 22 : 32),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Online', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text('Good Morning, JSV!', style: (isMobile ? AppTypography.headingMedium : AppTypography.headingLarge).copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        'You have 3 new bookings and 2 pending\nrequests waiting for you today.',
                        style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.85), height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _bannerButton('View Bookings', Icons.calendar_today_rounded, true),
                          _bannerButton('Go Online', Icons.wifi_tethering_rounded, false),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isMobile) ...[
                  const SizedBox(width: 32),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.business_center_rounded, size: 44, color: Colors.white),
                        const SizedBox(height: 8),
                        Text('Provider', style: AppTypography.labelSmall.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)),
    );
  }

  Widget _bannerButton(String label, IconData icon, bool filled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: filled ? Colors.white : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: filled ? null : Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: filled ? AppColors.primary : Colors.white),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.labelMedium.copyWith(color: filled ? AppColors.primary : Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(bool isMobile) {
    final stats = [
      {'label': 'Total Bookings', 'value': '156', 'change': '+12%', 'icon': Icons.calendar_today_rounded, 'color': AppColors.primary, 'bgColor': AppColors.primaryExtraLight},
      {'label': 'Active Jobs', 'value': '8', 'change': '+3', 'icon': Icons.work_rounded, 'color': AppColors.info, 'bgColor': AppColors.infoLight},
      {'label': 'Revenue', 'value': '\u20B924.5K', 'change': '+18%', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFFF59E0B), 'bgColor': const Color(0xFFFEF3C7)},
      {'label': 'Rating', 'value': '4.8', 'change': '\u2605', 'icon': Icons.star_rounded, 'color': const Color(0xFF8B5CF6), 'bgColor': const Color(0xFFF3E8FF)},
    ];

    if (isMobile) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
        children: stats.map((s) => _buildStatCard(s)).toList(),
      );
    }
    return Row(
      children: stats.asMap().entries.map((e) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: e.key < 3 ? 14 : 0),
          child: _buildStatCard(e.value),
        ),
      )).toList(),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: stat['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stat['icon'] as IconData, size: 20, color: stat['color'] as Color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(stat['change'] as String, style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(stat['value'] as String, style: AppTypography.headingLarge),
          const SizedBox(height: 2),
          Text(stat['label'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isMobile, BuildContext context) {
    final actions = [
      {'label': 'Add\nService', 'icon': Icons.add_circle_outline_rounded, 'color': AppColors.primary, 'bg': AppColors.primaryExtraLight},
      {'label': 'My\nServices', 'icon': Icons.home_repair_service_rounded, 'color': AppColors.info, 'bg': AppColors.infoLight},
      {'label': 'Earnings\nReport', 'icon': Icons.payments_rounded, 'color': const Color(0xFFF59E0B), 'bg': const Color(0xFFFEF3C7)},
      {'label': 'Customer\nReviews', 'icon': Icons.rate_review_rounded, 'color': const Color(0xFF8B5CF6), 'bg': const Color(0xFFF3E8FF)},
      {'label': 'Set\nSchedule', 'icon': Icons.schedule_rounded, 'color': const Color(0xFFEC4899), 'bg': const Color(0xFFFCE7F3)},
      {'label': 'Get\nSupport', 'icon': Icons.headset_mic_rounded, 'color': AppColors.navy, 'bg': const Color(0xFFE0E7FF)},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 3 : 6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isMobile ? 0.95 : 1.0,
      children: actions.map((a) => _buildActionTile(a, context)).toList(),
    );
  }

  Widget _buildActionTile(Map<String, dynamic> action, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if ((action['label'] as String).contains('Add')) {
          _navigateTo(context, const SpAddServiceScreen());
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: action['bg'] as Color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(action['icon'] as IconData, size: 24, color: action['color'] as Color),
          ),
          const SizedBox(height: 10),
          Text(
            action['label'] as String,
            style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary, height: 1.3),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildScheduleList(bool isMobile) {
    final schedules = [
      {'time': '9:00 AM', 'title': 'Home Cleaning', 'location': 'Apartment 302, Green Park', 'client': 'Rahul Sharma', 'status': 'Confirmed', 'color': AppColors.primary, 'icon': Icons.cleaning_services_rounded},
      {'time': '11:30 AM', 'title': 'Wall Painting', 'location': 'Villa Park, Kondapur', 'client': 'Priya Patel', 'status': 'In Progress', 'color': AppColors.info, 'icon': Icons.format_paint_rounded},
      {'time': '2:00 PM', 'title': 'Plumbing Repair', 'location': 'Green Heights, Gachibowli', 'client': 'Arjun Reddy', 'status': 'Pending', 'color': AppColors.amber, 'icon': Icons.plumbing_rounded},
      {'time': '4:30 PM', 'title': 'Deep Cleaning', 'location': 'Lakeside Towers, Hitech City', 'client': 'Meera Joshi', 'status': 'Confirmed', 'color': AppColors.primary, 'icon': Icons.dry_cleaning_rounded},
    ];

    return Column(
      children: schedules.asMap().entries.map((e) => _buildScheduleItem(e.value, e.key == schedules.length - 1)).toList(),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> schedule, bool isLast) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Service icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (schedule['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(schedule['icon'] as IconData, size: 24, color: schedule['color'] as Color),
            ),
            const SizedBox(width: 14),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(schedule['title'] as String, style: AppTypography.labelLarge)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (schedule['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(schedule['status'] as String, style: AppTypography.labelSmall.copyWith(color: schedule['color'] as Color, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 13, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(schedule['location'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded, size: 13, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(schedule['time'] as String, style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 11)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(schedule['client'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReviews() {
    final reviews = [
      {'name': 'Rahul Sharma', 'rating': 5, 'comment': 'Excellent cleaning service! Very thorough and professional work. Will book again.', 'time': '2h ago', 'service': 'Home Cleaning'},
      {'name': 'Priya Patel', 'rating': 4, 'comment': 'Great painting work. Minor touch-ups needed but overall very satisfied with the result.', 'time': '1d ago', 'service': 'Wall Painting'},
      {'name': 'Arjun Reddy', 'rating': 5, 'comment': 'Quick and efficient repair. Fixed the leak in no time. Highly recommended!', 'time': '2d ago', 'service': 'Plumbing'},
    ];

    return Column(
      children: reviews.map((r) => _buildReviewItem(r)).toList(),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    (review['name'] as String).substring(0, 1),
                    style: AppTypography.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['name'] as String, style: AppTypography.labelMedium),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            i < (review['rating'] as int) ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 14,
                            color: i < (review['rating'] as int) ? AppColors.amber : AppColors.border,
                          ),
                        )),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryExtraLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(review['service'] as String, style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(review['time'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '"${review['comment']}"',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
