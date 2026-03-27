import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';

class SpNotificationsScreen extends StatefulWidget {
  const SpNotificationsScreen({super.key});

  @override
  State<SpNotificationsScreen> createState() => _SpNotificationsScreenState();
}

class _SpNotificationsScreenState extends State<SpNotificationsScreen> {
  String _filter = 'All';

  final _notifications = [
    {
      'title': 'New Booking Request',
      'message': 'Rahul Sharma has requested Home Cleaning service for tomorrow at 9:00 AM.',
      'time': '2 min ago',
      'type': 'booking',
      'icon': Icons.calendar_today_rounded,
      'color': AppColors.info,
      'read': false,
    },
    {
      'title': 'Payment Received',
      'message': 'You received \u20B92,800 for Deep Cleaning service from Meera Joshi.',
      'time': '15 min ago',
      'type': 'payment',
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.primary,
      'read': false,
    },
    {
      'title': 'New Review',
      'message': 'Priya Patel gave you a 5-star review for Wall Painting service.',
      'time': '1 hour ago',
      'type': 'review',
      'icon': Icons.star_rounded,
      'color': AppColors.amber,
      'read': false,
    },
    {
      'title': 'Booking Confirmed',
      'message': 'Your booking #B1024 for Home Cleaning has been confirmed by the client.',
      'time': '2 hours ago',
      'type': 'booking',
      'icon': Icons.check_circle_rounded,
      'color': AppColors.primary,
      'read': true,
    },
    {
      'title': 'Booking Cancelled',
      'message': 'Amit Verma has cancelled booking #B1017 for Home Cleaning.',
      'time': '5 hours ago',
      'type': 'booking',
      'icon': Icons.cancel_rounded,
      'color': AppColors.error,
      'read': true,
    },
    {
      'title': 'Weekly Summary',
      'message': 'You completed 8 jobs this week and earned \u20B912,500. Great work!',
      'time': '1 day ago',
      'type': 'system',
      'icon': Icons.insights_rounded,
      'color': const Color(0xFF8B5CF6),
      'read': true,
    },
    {
      'title': 'New Message',
      'message': 'Arjun Reddy sent you a message about the plumbing repair scheduled for tomorrow.',
      'time': '1 day ago',
      'type': 'message',
      'icon': Icons.chat_bubble_rounded,
      'color': AppColors.info,
      'read': true,
    },
    {
      'title': 'Payment Received',
      'message': 'You received \u20B95,200 for Interior Painting service from Kavya Nair.',
      'time': '2 days ago',
      'type': 'payment',
      'icon': Icons.account_balance_wallet_rounded,
      'color': AppColors.primary,
      'read': true,
    },
    {
      'title': 'Profile Boost',
      'message': 'Your profile has been boosted! You\'ll appear in top search results for the next 24 hours.',
      'time': '3 days ago',
      'type': 'system',
      'icon': Icons.rocket_launch_rounded,
      'color': const Color(0xFFEC4899),
      'read': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_filter == 'All') return _notifications;
    if (_filter == 'Unread') return _notifications.where((n) => n['read'] == false).toList();
    return _notifications.where((n) => n['type'] == _filter.toLowerCase()).toList();
  }

  int get _unreadCount => _notifications.where((n) => n['read'] == false).length;

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
        title: Row(
          children: [
            Text('Notifications', style: AppTypography.headingMedium),
            const SizedBox(width: 10),
            if (_unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$_unreadCount', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifications) {
                  n['read'] = true;
                }
              });
            },
            child: Text('Mark all read', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 28, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Unread', 'Booking', 'Payment', 'Review', 'System'].map((filter) {
                  final isSelected = _filter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = filter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          filter,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Notification list
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.all(isMobile ? 16 : 24),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) => _buildNotificationCard(_filteredNotifications[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_off_rounded, size: 40, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text('No Notifications', style: AppTypography.headingSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('You\'re all caught up!', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['read'] as bool;
    final color = notification['color'] as Color;

    return GestureDetector(
      onTap: () {
        setState(() => notification['read'] = true);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : color.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? AppColors.border.withOpacity(0.5) : color.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(notification['icon'] as IconData, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] as String,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'] as String,
                    style: AppTypography.bodySmall.copyWith(
                      color: isRead ? AppColors.textTertiary : AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification['time'] as String,
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
