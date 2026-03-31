import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';

class SpEarningsScreen extends StatefulWidget {
  const SpEarningsScreen({super.key});

  @override
  State<SpEarningsScreen> createState() => _SpEarningsScreenState();
}

class _SpEarningsScreenState extends State<SpEarningsScreen> {
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Earnings', style: AppTypography.headingMedium),
              const SizedBox(height: 4),
              Text('Track your income and payouts', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 22),
              _buildTotalEarningsCard(isMobile),
              const SizedBox(height: 22),
              _buildPendingPayoutCard(),
              const SizedBox(height: 22),
              _buildPeriodSelector(),
              const SizedBox(height: 22),
              _buildWeeklyEarningsChart(),
              const SizedBox(height: 22),
              _buildQuickStats(isMobile),
              const SizedBox(height: 28),
              _buildEarningsBreakdown(isMobile),
              const SizedBox(height: 28),
              _buildSectionHeader('Recent Transactions'),
              const SizedBox(height: 14),
              _buildTransactionsList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title, style: AppTypography.headingSmall),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryExtraLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('See All', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _buildTotalEarningsCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D5F8B), Color(0xFF1E3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: AppColors.navy.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Stack(
        children: [
          Positioned(top: -30, right: -20, child: _decorCircle(100, 0.04)),
          Positioned(bottom: -20, left: 30, child: _decorCircle(70, 0.03)),
          Padding(
            padding: EdgeInsets.all(isMobile ? 22 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.account_balance_wallet_rounded, size: 12, color: Colors.white70),
                          const SizedBox(width: 6),
                          Text('Total Earnings', style: AppTypography.labelSmall.copyWith(color: Colors.white70, fontSize: 10)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.trending_up_rounded, size: 14, color: Colors.greenAccent),
                          const SizedBox(width: 4),
                          Text('+18% this month', style: AppTypography.labelSmall.copyWith(color: Colors.greenAccent, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('₹2,45,800', style: AppTypography.displayLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800, fontSize: isMobile ? 30 : 38)),
                const SizedBox(height: 20),
                isMobile
                    ? Column(
                        children: [
                          Row(
                            children: [
                              _earningPill('This Month', '₹24,500', Icons.calendar_today_rounded, AppColors.primary),
                              const SizedBox(width: 10),
                              _earningPill('Pending', '₹4,200', Icons.schedule_rounded, AppColors.amber),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _earningPill('Withdrawn', '₹2.1L', Icons.arrow_upward_rounded, const Color(0xFF8B5CF6)),
                              const Spacer(),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          _earningPill('This Month', '₹24,500', Icons.calendar_today_rounded, AppColors.primary),
                          const SizedBox(width: 12),
                          _earningPill('Pending', '₹4,200', Icons.schedule_rounded, AppColors.amber),
                          const SizedBox(width: 12),
                          _earningPill('Withdrawn', '₹2.1L', Icons.arrow_upward_rounded, const Color(0xFF8B5CF6)),
                          const Spacer(),
                          _buildWithdrawButton(),
                        ],
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text('Withdraw', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingPayoutCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.schedule_rounded, size: 24, color: AppColors.amber),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pending Payout', style: AppTypography.labelMedium),
                const SizedBox(height: 4),
                Text('Withdraws every Friday', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹4,200', style: AppTypography.labelLarge.copyWith(color: AppColors.amber)),
              Text('Next: 31 Mar', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['This Week', 'This Month', 'All Time'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: EdgeInsets.only(right: period != periods.last ? 10 : 0),
            child: Material(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => setState(() => _selectedPeriod = period),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    period,
                    style: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyEarningsChart() {
    final data = [
      {'day': 'Mon', 'amount': 1200, 'pct': 0.38},
      {'day': 'Tue', 'amount': 1500, 'pct': 0.47},
      {'day': 'Wed', 'amount': 800, 'pct': 0.25},
      {'day': 'Thu', 'amount': 2100, 'pct': 0.66},
      {'day': 'Fri', 'amount': 1800, 'pct': 0.57},
      {'day': 'Sat', 'amount': 2400, 'pct': 0.75},
      {'day': 'Sun', 'amount': 1600, 'pct': 0.50},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Earnings', style: AppTypography.labelMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '₹${item['amount']}',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 9),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              child: FractionallySizedBox(
                                heightFactor: item['pct'] as double,
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [AppColors.primary.withOpacity(0.6), AppColors.primary],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(item['day'] as String, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                      ],
                    ),
                  ),
                );
              }).toList(),
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

  Widget _earningPill(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 6),
                Expanded(child: Text(label, style: AppTypography.labelSmall.copyWith(color: Colors.white54, fontSize: 10))),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: AppTypography.labelLarge.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(bool isMobile) {
    final stats = [
      {'label': 'Avg per Job', 'value': '₹1,580', 'icon': Icons.receipt_long_rounded, 'color': AppColors.primary},
      {'label': 'Jobs This Month', 'value': '18', 'icon': Icons.work_history_rounded, 'color': AppColors.info},
      {'label': 'Repeat Clients', 'value': '72%', 'icon': Icons.people_rounded, 'color': const Color(0xFF8B5CF6)},
    ];

    if (isMobile) {
      return Column(
        children: stats.asMap().entries.map((e) => Padding(
          padding: EdgeInsets.only(bottom: e.key < 2 ? 10 : 0),
          child: _buildStatItem(e.value),
        )).toList(),
      );
    }

    return Row(
      children: stats.asMap().entries.map((e) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: e.key < 2 ? 12 : 0),
          child: _buildStatItem(e.value),
        ),
      )).toList(),
    );
  }

  Widget _buildStatItem(Map<String, dynamic> stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(stat['icon'] as IconData, size: 18, color: stat['color'] as Color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat['value'] as String, style: AppTypography.headingSmall),
                Text(stat['label'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsBreakdown(bool isMobile) {
    final items = [
      {'service': 'Home Cleaning', 'earnings': '₹12,400', 'jobs': '12', 'pct': 0.31, 'color': AppColors.primary, 'icon': Icons.cleaning_services_rounded},
      {'service': 'Deep Cleaning', 'earnings': '₹8,600', 'jobs': '5', 'pct': 0.22, 'color': AppColors.info, 'icon': Icons.dry_cleaning_rounded},
      {'service': 'Painting', 'earnings': '₹15,200', 'jobs': '4', 'pct': 0.38, 'color': const Color(0xFFF59E0B), 'icon': Icons.format_paint_rounded},
      {'service': 'Repairs', 'earnings': '₹3,800', 'jobs': '6', 'pct': 0.09, 'color': const Color(0xFF8B5CF6), 'icon': Icons.build_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Revenue by Service'),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: items.map((item) => Expanded(
                      flex: ((item['pct'] as double) * 100).toInt(),
                      child: Container(
                        margin: EdgeInsets.only(right: item != items.last ? 2 : 0),
                        color: item['color'] as Color,
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: item != items.last ? 14 : 0),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item['icon'] as IconData, size: 18, color: item['color'] as Color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['service'] as String, style: AppTypography.labelMedium),
                          Text('${item['jobs']} jobs completed', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(item['earnings'] as String, style: AppTypography.labelLarge.copyWith(color: item['color'] as Color)),
                        Text('${((item['pct'] as double) * 100).toInt()}%', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    final transactionsByDate = {
      'Today': [
        {'title': 'Home Cleaning', 'subtitle': 'Rahul Sharma', 'amount': '+₹1,500', 'type': 'credit', 'icon': Icons.cleaning_services_rounded},
        {'title': 'Platform Fee', 'subtitle': 'Service charge', 'amount': '-₹150', 'type': 'debit', 'icon': Icons.receipt_rounded},
      ],
      'Yesterday': [
        {'title': 'Deep Cleaning', 'subtitle': 'Meera Joshi', 'amount': '+₹2,800', 'type': 'credit', 'icon': Icons.dry_cleaning_rounded},
        {'title': 'Bank Withdrawal', 'subtitle': 'HDFC ****1234', 'amount': '-₹10,000', 'type': 'debit', 'icon': Icons.account_balance_rounded},
      ],
      'Mar 25': [
        {'title': 'Painting Work', 'subtitle': 'Priya Patel', 'amount': '+₹5,200', 'type': 'credit', 'icon': Icons.format_paint_rounded},
        {'title': 'Plumbing Repair', 'subtitle': 'Arjun Reddy', 'amount': '+₹800', 'type': 'credit', 'icon': Icons.plumbing_rounded},
      ],
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: transactionsByDate.entries.toList().asMap().entries.map((dateEntry) {
          final dateLabel = dateEntry.value.key;
          final transactions = dateEntry.value.value as List<Map<String, dynamic>>;
          final isLastDate = dateEntry.key == transactionsByDate.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(dateLabel, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
                ),
              ),
              ...transactions.asMap().entries.map((tEntry) {
                final t = tEntry.value;
                final isCredit = t['type'] == 'credit';
                final isLastTrans = tEntry.key == transactions.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isCredit ? AppColors.primaryExtraLight : AppColors.errorLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(t['icon'] as IconData, size: 20, color: isCredit ? AppColors.primary : AppColors.error),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t['title'] as String, style: AppTypography.labelMedium),
                                const SizedBox(height: 2),
                                Text(t['subtitle'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 11)),
                              ],
                            ),
                          ),
                          Text(
                            t['amount'] as String,
                            style: AppTypography.labelLarge.copyWith(
                              color: isCredit ? AppColors.primary : AppColors.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLastTrans) Divider(height: 1, indent: 74, color: AppColors.border.withOpacity(0.5)),
                  ],
                );
              }).toList(),
              if (!isLastDate) Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}
