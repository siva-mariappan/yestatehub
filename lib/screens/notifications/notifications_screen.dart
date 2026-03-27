import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

/// Notifications Screen — notification feed/list
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Unread', 'Enquiries', 'Alerts', 'System'];

  final _notifications = [
    _Notif(
      type: 'enquiry',
      title: 'New Enquiry',
      body: 'Rahul Sharma enquired about your 3 BHK in Gachibowli.',
      time: '2 minutes ago',
      icon: Icons.person_add_rounded,
      color: AppColors.primary,
      isRead: false,
    ),
    _Notif(
      type: 'alert',
      title: 'Price Drop Alert',
      body: '2 BHK in Kondapur price dropped by 5%. Check updated listing.',
      time: '1 hour ago',
      icon: Icons.trending_down_rounded,
      color: AppColors.amber,
      isRead: false,
    ),
    _Notif(
      type: 'system',
      title: 'Listing Approved',
      body: 'Your property "3 BHK Gachibowli" has been verified and is now live.',
      time: '3 hours ago',
      icon: Icons.verified_rounded,
      color: AppColors.primary,
      isRead: true,
    ),
    _Notif(
      type: 'enquiry',
      title: 'Visit Scheduled',
      body: 'Priya Verma scheduled a visit for 2 BHK Kondapur on Thursday at 5 PM.',
      time: '5 hours ago',
      icon: Icons.calendar_today_rounded,
      color: AppColors.info,
      isRead: true,
    ),
    _Notif(
      type: 'alert',
      title: 'Market Update',
      body: 'Kokapet property prices increased 8% this quarter. View analytics.',
      time: '1 day ago',
      icon: Icons.bar_chart_rounded,
      color: AppColors.primaryDark,
      isRead: true,
    ),
    _Notif(
      type: 'system',
      title: 'Profile Incomplete',
      body: 'Complete your KYC verification to unlock premium features.',
      time: '2 days ago',
      icon: Icons.warning_amber_rounded,
      color: AppColors.amber,
      isRead: true,
    ),
    _Notif(
      type: 'enquiry',
      title: 'New Message',
      body: 'Amit Reddy sent you a message about Villa Kokapet.',
      time: '3 days ago',
      icon: Icons.message_rounded,
      color: AppColors.info,
      isRead: true,
    ),
    _Notif(
      type: 'alert',
      title: 'Property Trending',
      body: 'Your 2 BHK Kondapur listing received 45 views today!',
      time: '3 days ago',
      icon: Icons.local_fire_department_rounded,
      color: AppColors.error,
      isRead: true,
    ),
  ];

  List<_Notif> get _filtered {
    if (_filter == 'All') return _notifications;
    if (_filter == 'Unread') return _notifications.where((n) => !n.isRead).toList();
    if (_filter == 'Enquiries') return _notifications.where((n) => n.type == 'enquiry').toList();
    if (_filter == 'Alerts') return _notifications.where((n) => n.type == 'alert').toList();
    if (_filter == 'System') return _notifications.where((n) => n.type == 'system').toList();
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.headingMedium),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              for (var n in _notifications) {
                n.isRead = true;
              }
            }),
            child: Text('Mark all read', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
        children: [
          // Filters
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == _filter;
                return ChoiceChip(
                  label: Text(f, style: AppTypography.labelSmall.copyWith(color: active ? Colors.white : AppColors.textSecondary)),
                  selected: active,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: active ? AppColors.primary : AppColors.border),
                  onSelected: (_) => setState(() => _filter = f),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),

          // Notification list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 56, color: AppColors.textTertiary.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text('No notifications', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final n = filtered[index];
                      return Dismissible(
                        key: ValueKey(n.title + n.time),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: AppColors.error,
                          child: const Icon(Icons.delete_outline, color: Colors.white),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: n.isRead ? AppColors.surface : AppColors.primaryExtraLight,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppColors.cardShadow,
                            border: n.isRead ? null : Border.all(color: AppColors.primaryLight),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: n.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(n.icon, size: 22, color: n.color),
                            ),
                            title: Row(
                              children: [
                                if (!n.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  ),
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(n.time, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                n.body,
                                style: AppTypography.bodySmall.copyWith(
                                  color: n.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () => setState(() => n.isRead = true),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
        ),
      ),
    );
  }
}

class _Notif {
  final String type, title, body, time;
  final IconData icon;
  final Color color;
  bool isRead;

  _Notif({
    required this.type,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.color,
    required this.isRead,
  });
}
