import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import 'sp_booking_detail_screen.dart';

class SpBookingsScreen extends StatefulWidget {
  const SpBookingsScreen({super.key});

  @override
  State<SpBookingsScreen> createState() => _SpBookingsScreenState();
}

class _SpBookingsScreenState extends State<SpBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _dateController;
  String _searchQuery = '';
  int _selectedDateIndex = 0;

  final _bookings = [
    {'id': '#B1024', 'service': 'Home Cleaning', 'client': 'Rahul Sharma', 'phone': '+91 98765 43210', 'location': 'Apt 302, Green Park, Ameerpet', 'date': '27 Mar', 'time': '9:00 AM', 'duration': '2h', 'amount': '\u20B91,500', 'status': 'Upcoming', 'icon': Icons.cleaning_services_rounded},
    {'id': '#B1023', 'service': 'Deep Cleaning', 'client': 'Meera Joshi', 'phone': '+91 87654 32109', 'location': 'Lakeside Towers, Hitech City', 'date': '27 Mar', 'time': '2:00 PM', 'duration': '3h', 'amount': '\u20B92,800', 'status': 'Upcoming', 'icon': Icons.dry_cleaning_rounded},
    {'id': '#B1022', 'service': 'Wall Painting', 'client': 'Priya Patel', 'phone': '+91 76543 21098', 'location': 'Villa Park, Kondapur', 'date': '26 Mar', 'time': '11:00 AM', 'duration': '6h', 'amount': '\u20B95,200', 'status': 'In Progress', 'icon': Icons.format_paint_rounded},
    {'id': '#B1021', 'service': 'Plumbing Repair', 'client': 'Arjun Reddy', 'phone': '+91 65432 10987', 'location': 'Green Heights, Gachibowli', 'date': '26 Mar', 'time': '3:30 PM', 'duration': '1h', 'amount': '\u20B9800', 'status': 'In Progress', 'icon': Icons.plumbing_rounded},
    {'id': '#B1020', 'service': 'Home Cleaning', 'client': 'Sneha Gupta', 'phone': '+91 54321 09876', 'location': 'Serene Meadows, Madhapur', 'date': '25 Mar', 'time': '10:00 AM', 'duration': '2h', 'amount': '\u20B91,200', 'status': 'Completed', 'icon': Icons.cleaning_services_rounded},
    {'id': '#B1019', 'service': 'Electrical Repair', 'client': 'Vikram Singh', 'phone': '+91 43210 98765', 'location': 'BlueBird Enclave, Miyapur', 'date': '24 Mar', 'time': '4:00 PM', 'duration': '1.5h', 'amount': '\u20B91,800', 'status': 'Completed', 'icon': Icons.electrical_services_rounded},
    {'id': '#B1018', 'service': 'Interior Painting', 'client': 'Kavya Nair', 'phone': '+91 32109 87654', 'location': 'Palm Grove, KPHB', 'date': '23 Mar', 'time': '9:30 AM', 'duration': '8h', 'amount': '\u20B94,500', 'status': 'Completed', 'icon': Icons.format_paint_rounded},
    {'id': '#B1017', 'service': 'Home Cleaning', 'client': 'Amit Verma', 'phone': '+91 21098 76543', 'location': 'Golden Residency, Kukatpally', 'date': '22 Mar', 'time': '11:00 AM', 'duration': '2h', 'amount': '\u20B91,000', 'status': 'Cancelled', 'icon': Icons.cleaning_services_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dateController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(String status) {
    var items = status == 'All' ? _bookings : _bookings.where((b) => b['status'] == status).toList();
    if (_searchQuery.isEmpty) return items;
    return items.where((b) =>
      (b['service'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (b['client'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
      (b['id'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  int _getEarningsForTab(String status) {
    final items = _filtered(status);
    int total = 0;
    for (var item in items) {
      final amount = (item['amount'] as String).replaceAll(RegExp(r'[^\d]'), '');
      total += int.tryParse(amount) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Column(
      children: [
        // Premium header
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 20, isMobile ? 16 : 28, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bookings', style: AppTypography.headingMedium),
                        const SizedBox(height: 4),
                        Text('Friday, 28 March 2025', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
                      ],
                    ),
                  ),
                  _buildHeaderStat('4', 'Today', AppColors.primary),
                  const SizedBox(width: 12),
                  _buildHeaderStat('2', 'Pending', AppColors.amber),
                ],
              ),
              const SizedBox(height: 14),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search bookings...',
                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                    prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  style: AppTypography.bodySmall,
                ),
              ),
              const SizedBox(height: 14),
              // Calendar strip
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final dates = ['23', '24', '25', '26', '27', '28', '29'];
                    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    final isSelected = index == _selectedDateIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDateIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(left: index == 0 ? 0 : 6, right: 6),
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 0 : 1,
                          ),
                          boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2))]
                            : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(days[index], style: AppTypography.labelSmall.copyWith(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontSize: 10,
                            )),
                            const SizedBox(height: 4),
                            Text(dates[index], style: AppTypography.labelMedium.copyWith(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Tab bar with earning summary
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 28, 0, isMobile ? 16 : 28, 0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                isScrollable: isMobile,
                tabAlignment: isMobile ? TabAlignment.start : null,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textTertiary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: AppTypography.labelMedium,
                unselectedLabelStyle: AppTypography.bodySmall,
                labelPadding: isMobile ? const EdgeInsets.symmetric(horizontal: 10) : null,
                tabs: [
                  _buildTab('All', _filtered('All').length),
                  _buildTab('Upcoming', _filtered('Upcoming').length),
                  _buildTab('Active', _filtered('In Progress').length),
                  _buildTab('Done', _filtered('Completed').length),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, child) {
                    final index = _tabController.index;
                    final statuses = ['All', 'Upcoming', 'In Progress', 'Completed'];
                    final earnings = _getEarningsForTab(statuses[index]);
                    return Row(
                      children: [
                        Icon(Icons.trending_up_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text('Earnings: ', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary), overflow: TextOverflow.ellipsis),
                        ),
                        Flexible(
                          child: Text('₹$earnings', style: AppTypography.labelMedium.copyWith(color: AppColors.primary), overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBookingList('All', isMobile),
              _buildBookingList('Upcoming', isMobile),
              _buildBookingList('In Progress', isMobile),
              _buildBookingList('Completed', isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderStat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTypography.labelLarge.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall.copyWith(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count', style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(String status, bool isMobile) {
    final items = _filtered(status);
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.event_busy_rounded, size: 36, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 14),
            Text('No Bookings Yet', style: AppTypography.headingSmall.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(_searchQuery.isNotEmpty ? 'No matches found' : '$status bookings will appear here',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildBookingCard(items[index]),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final statusConfig = _getStatusConfig(booking['status'] as String);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SpBookingDetailScreen(booking: booking))),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // Header with left accent border
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              decoration: BoxDecoration(
                color: (statusConfig['color'] as Color).withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                border: Border(
                  left: BorderSide(color: statusConfig['color'] as Color, width: 4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (statusConfig['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(booking['icon'] as IconData, size: 20, color: statusConfig['color'] as Color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking['service'] as String, style: AppTypography.labelLarge, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(booking['id'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (statusConfig['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusConfig['icon'] as IconData, size: 12, color: statusConfig['color'] as Color),
                        const SizedBox(width: 4),
                        Text(booking['status'] as String, style: AppTypography.labelSmall.copyWith(color: statusConfig['color'] as Color, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: Column(
                children: [
                  _buildDetailRow(Icons.person_outline_rounded, booking['client'] as String, booking['phone'] as String),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.location_on_outlined, booking['location'] as String, null),
                  const SizedBox(height: 8),
                  _buildDetailRow(Icons.calendar_today_rounded, '${booking['date']} at ${booking['time']}', 'Duration: ${booking['duration']}'),
                  const SizedBox(height: 14),
                  // Footer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 10,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Amount', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
                            const SizedBox(width: 8),
                            Text(booking['amount'] as String, style: AppTypography.headingSmall.copyWith(color: AppColors.primary)),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (booking['status'] == 'Upcoming') ...[
                              _buildActionBtn('Accept', AppColors.primary, Icons.check_rounded),
                              const SizedBox(width: 8),
                              _buildActionBtn('Decline', AppColors.error, Icons.close_rounded),
                            ] else if (booking['status'] == 'In Progress') ...[
                              _buildActionBtn('Complete', AppColors.primary, Icons.done_all_rounded),
                              const SizedBox(width: 8),
                              _buildActionBtn('Call', AppColors.info, Icons.phone_rounded),
                            ] else if (booking['status'] == 'Completed') ...[
                              _buildActionBtn('Invoice', AppColors.navy, Icons.receipt_long_rounded),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  Widget _buildDetailRow(IconData icon, String primary, String? secondary) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textTertiary),
        const SizedBox(width: 10),
        Expanded(child: Text(primary, style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary), overflow: TextOverflow.ellipsis, maxLines: 1)),
        if (secondary != null) ...[
          const SizedBox(width: 6),
          Flexible(
            flex: 0,
            child: Text(secondary, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11), overflow: TextOverflow.ellipsis),
          ),
        ],
      ],
    );
  }

  Widget _buildActionBtn(String label, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 5),
            Text(label, style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
