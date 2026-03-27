import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';

class SpBookingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> booking;
  const SpBookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final statusConfig = _getStatusConfig(booking['status'] as String);
    final color = statusConfig['color'] as Color;

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
        title: Text('Booking ${booking['id']}', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status banner
                _buildStatusBanner(context, color),
                const SizedBox(height: 20),

                // Service info card
                _buildInfoCard(
                  'Service Details',
                  Icons.home_repair_service_rounded,
                  color,
                  [
                    _infoRow('Service', booking['service'] as String),
                    _infoRow('Booking ID', booking['id'] as String),
                    _infoRow('Date', '${booking['date']}, 2026'),
                    _infoRow('Time', booking['time'] as String),
                    _infoRow('Duration', booking['duration'] as String),
                  ],
                ),
                const SizedBox(height: 16),

                // Client info card
                _buildInfoCard(
                  'Client Information',
                  Icons.person_rounded,
                  AppColors.info,
                  [
                    _infoRow('Name', booking['client'] as String),
                    _infoRow('Phone', booking['phone'] as String),
                    _infoRow('Address', booking['location'] as String),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment card
                _buildPaymentCard(),
                const SizedBox(height: 16),

                // Timeline
                _buildTimeline(color),
                const SizedBox(height: 16),

                // Notes
                _buildNotesCard(),
                const SizedBox(height: 28),

                // Action buttons
                _buildActionButtons(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, Color color) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: isMobile ? 48 : 56,
                height: isMobile ? 48 : 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
                ),
                child: Icon(booking['icon'] as IconData, size: isMobile ? 24 : 28, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking['service'] as String, style: isMobile ? AppTypography.labelLarge : AppTypography.headingMedium),
                    const SizedBox(height: 4),
                    Text('${booking['date']} at ${booking['time']}', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 14, vertical: isMobile ? 5 : 7),
                decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_getStatusConfig(booking['status'] as String)['icon'] as IconData, size: 14, color: color),
                const SizedBox(width: 6),
                Text(booking['status'] as String, style: AppTypography.labelSmall.copyWith(color: color, fontSize: 12)),
              ],
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, Color color, List<Widget> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      width: double.infinity,
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
                    color: AppColors.primaryExtraLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.payments_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Text('Payment', style: AppTypography.labelLarge),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _paymentRow('Service Amount', booking['amount'] as String, false),
                _paymentRow('Platform Fee (10%)', '-\u20B9${_calculateFee()}', false),
                const SizedBox(height: 8),
                Container(height: 1, color: AppColors.border.withOpacity(0.5)),
                const SizedBox(height: 8),
                _paymentRow('You\'ll Receive', '\u20B9${_calculateNet()}', true),
              ],
            ),
          ),
          // Payment status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Payment will be released after service completion', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateFee() {
    final amount = (booking['amount'] as String).replaceAll('\u20B9', '').replaceAll(',', '');
    final fee = (int.tryParse(amount) ?? 0) * 0.1;
    return fee.toInt().toString();
  }

  String _calculateNet() {
    final amount = (booking['amount'] as String).replaceAll('\u20B9', '').replaceAll(',', '');
    final net = (int.tryParse(amount) ?? 0) * 0.9;
    return net.toInt().toString();
  }

  Widget _paymentRow(String label, String value, bool isBold) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? AppTypography.labelMedium : AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: isBold
                ? AppTypography.headingSmall.copyWith(color: AppColors.primary)
                : AppTypography.labelMedium.copyWith(color: value.startsWith('-') ? AppColors.error : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(Color color) {
    final events = [
      {'title': 'Booking Created', 'time': '${booking['date']}, 8:00 AM', 'done': true},
      {'title': 'Confirmed by Client', 'time': '${booking['date']}, 8:15 AM', 'done': true},
      {'title': 'Service Started', 'time': booking['status'] == 'In Progress' || booking['status'] == 'Completed' ? '${booking['date']}, ${booking['time']}' : 'Pending', 'done': booking['status'] == 'In Progress' || booking['status'] == 'Completed'},
      {'title': 'Service Completed', 'time': booking['status'] == 'Completed' ? '${booking['date']}, ${booking['time']}' : 'Pending', 'done': booking['status'] == 'Completed'},
      {'title': 'Payment Released', 'time': booking['status'] == 'Completed' ? '${booking['date']}' : 'Pending', 'done': booking['status'] == 'Completed'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.timeline_rounded, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Text('Booking Timeline', style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: 18),
          ...events.asMap().entries.map((e) {
            final event = e.value;
            final isDone = event['done'] as bool;
            final isLast = e.key == events.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.primary : AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDone ? AppColors.primary : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: isDone ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: isDone ? AppColors.primary.withOpacity(0.3) : AppColors.border,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event['title'] as String,
                          style: AppTypography.labelMedium.copyWith(
                            color: isDone ? AppColors.textPrimary : AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event['time'] as String,
                          style: AppTypography.bodySmall.copyWith(
                            color: isDone ? AppColors.textSecondary : AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.amberLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.note_alt_rounded, size: 18, color: AppColors.amber),
              ),
              const SizedBox(width: 12),
              Text('Notes', style: AppTypography.labelLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_rounded, size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Add Note', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Client prefers eco-friendly cleaning products. Has a pet dog — be careful with chemicals. Entry code: 4521.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = booking['status'] as String;
    if (status == 'Completed' || status == 'Cancelled') {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: Material(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt_long_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Text('Download Invoice', style: AppTypography.buttonMedium.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        if (status == 'Upcoming') ...[
          Expanded(
            child: SizedBox(
              height: 52,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('Decline', style: AppTypography.buttonMedium.copyWith(color: AppColors.error)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _primaryButton('Accept', Icons.check_rounded),
          ),
        ] else if (status == 'In Progress') ...[
          Expanded(
            child: SizedBox(
              height: 52,
              child: Material(
                color: AppColors.info,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Call Client', style: AppTypography.buttonMedium.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _primaryButton('Complete', Icons.done_all_rounded),
          ),
        ],
      ],
    );
  }

  Widget _primaryButton(String label, IconData icon) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(label, style: AppTypography.buttonMedium.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'Upcoming':
        return {'color': AppColors.info, 'icon': Icons.schedule_rounded};
      case 'In Progress':
        return {'color': AppColors.amber, 'icon': Icons.play_circle_outline_rounded};
      case 'Completed':
        return {'color': AppColors.primary, 'icon': Icons.check_circle_outline_rounded};
      case 'Cancelled':
        return {'color': AppColors.error, 'icon': Icons.cancel_outlined};
      default:
        return {'color': AppColors.textSecondary, 'icon': Icons.circle_outlined};
    }
  }
}
