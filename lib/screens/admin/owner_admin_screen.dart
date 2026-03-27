import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../config/assets.dart';
import '../../data/mock_data.dart';

/// Owner Admin Panel — Access: Only for yestatehub@gmail.com
/// 4 Tabs: Stats, Property Management, User List, Search/Filter
class OwnerAdminScreen extends StatefulWidget {
  const OwnerAdminScreen({super.key});

  @override
  State<OwnerAdminScreen> createState() => _OwnerAdminScreenState();
}

class _OwnerAdminScreenState extends State<OwnerAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin Panel', style: AppTypography.headingMedium),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: Responsive.isMobile(context),
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.labelMedium,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart_rounded, size: 20), text: 'Stats'),
            Tab(icon: Icon(Icons.home_work_rounded, size: 20), text: 'Properties'),
            Tab(icon: Icon(Icons.people_rounded, size: 20), text: 'Users'),
            Tab(icon: Icon(Icons.search_rounded, size: 20), text: 'Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StatsTab(),
          _PropertyManagementTab(),
          _UserListTab(),
          _SearchFilterTab(),
        ],
      ),
    );
  }
}

// ─── Tab 1: Platform Stats ───────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final crossCount = Responsive.value<int>(context, mobile: 2, tablet: 3, desktop: 4);
    final hPad = Responsive.value<double>(context, mobile: 16, tablet: 24, desktop: 32);

    return SingleChildScrollView(
      padding: EdgeInsets.all(hPad),
      child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Overview', style: AppTypography.headingLarge),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.5,
            children: const [
              _AdminStat('Total Properties', '2,847', Icons.home_rounded, AppColors.primary, '+124 this month'),
              _AdminStat('Active Users', '15,230', Icons.people_rounded, AppColors.info, '+890 this month'),
              _AdminStat('Revenue', '4.2L', Icons.currency_rupee_rounded, AppColors.amber, '+18% growth'),
              _AdminStat('Enquiries', '8,456', Icons.message_rounded, AppColors.primaryDark, '+12% growth'),
            ],
          ),
          const SizedBox(height: 24),

          Text('Monthly Revenue', style: AppTypography.headingSmall),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.cardShadow,
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _BarChartPainter(),
            ),
          ),
          const SizedBox(height: 24),

          Text('Recent Activity', style: AppTypography.headingSmall),
          const SizedBox(height: 12),
          _adminActivity(Icons.add_home, 'New property listed', 'Villa in Kokapet by Sneha Iyer', '2h ago', AppColors.primary),
          _adminActivity(Icons.person_add, 'New user registered', 'Vikram Das — Buyer', '3h ago', AppColors.info),
          _adminActivity(Icons.report, 'Property reported', '2 BHK Miyapur flagged for review', '5h ago', AppColors.error),
          _adminActivity(Icons.verified, 'Property verified', '3 BHK Gachibowli — RERA approved', '1d ago', AppColors.primary),
          _adminActivity(Icons.payment, 'Payment received', 'Ad boost — Premium listing fee', '1d ago', AppColors.amber),
        ],
      ),
      ),
      ),
    );
  }

  static Widget _adminActivity(IconData icon, String title, String sub, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                Text(title, style: AppTypography.labelLarge),
                Text(sub, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Text(time, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String label, value, trend;
  final IconData icon;
  final Color color;

  const _AdminStat(this.label, this.value, this.icon, this.color, this.trend);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              Icon(Icons.trending_up, size: 14, color: AppColors.primary),
            ],
          ),
          Text(value, style: AppTypography.headingLarge),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
              Text(trend, style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final values = [0.4, 0.55, 0.65, 0.5, 0.75, 0.85];
    final barWidth = size.width / (months.length * 2);
    final maxH = size.height - 40;

    for (int i = 0; i < months.length; i++) {
      final x = (i * 2 + 0.7) * barWidth;
      final h = values[i] * maxH;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, maxH - h + 10, barWidth, h),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, Paint()..color = AppColors.primary.withOpacity(0.8));

      final tp = TextPainter(
        text: TextSpan(text: months[i], style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + barWidth / 2 - tp.width / 2, size.height - 16));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Tab 2: Property Management ─────────────────────────────────────────

class _PropertyManagementTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final props = MockData.featuredProperties;
    final hPad = Responsive.value<double>(context, mobile: 16, tablet: 24, desktop: 32);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
    child: ListView.builder(
      padding: EdgeInsets.all(hPad),
      itemCount: props.length,
      itemBuilder: (context, index) {
        final p = props[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 80,
                  height: 60,
                  color: AppColors.divider,
                  child: p.images.isNotEmpty
                      ? Image.network(p.images.first, fit: BoxFit.cover)
                      : const Icon(Icons.image, color: AppColors.textTertiary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(p.title, style: AppTypography.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: p.isVerified ? AppColors.primaryExtraLight : AppColors.amberLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.isVerified ? 'Verified' : 'Pending',
                            style: AppTypography.labelSmall.copyWith(color: p.isVerified ? AppColors.primary : AppColors.amber),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${p.locality}, ${p.city}', style: AppTypography.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _adminPropBtn('Approve', Icons.check_circle, AppColors.primary),
                        const SizedBox(width: 8),
                        _adminPropBtn('Reject', Icons.cancel, AppColors.error),
                        const SizedBox(width: 8),
                        _adminPropBtn('Flag', Icons.flag, AppColors.amber),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
      ),
    );
  }

  Widget _adminPropBtn(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─── Tab 3: User List ────────────────────────────────────────────────────

class _UserListTab extends StatelessWidget {
  final _users = const [
    _UserData('Rahul Sharma', 'rahul@gmail.com', 'Buyer', true, '2 days ago'),
    _UserData('Priya Verma', 'priya@gmail.com', 'Buyer', true, '1 day ago'),
    _UserData('Amit Reddy', 'amit@gmail.com', 'Seller', true, '3 hours ago'),
    _UserData('Sneha Iyer', 'sneha@gmail.com', 'Seller', false, '1 week ago'),
    _UserData('Vikram Das', 'vikram@gmail.com', 'Buyer', true, '5 hours ago'),
    _UserData('Meera Patel', 'meera@gmail.com', 'Agent', true, '30 min ago'),
    _UserData('Karthik R.', 'karthik@gmail.com', 'Buyer', false, '2 weeks ago'),
    _UserData('Divya S.', 'divya@gmail.com', 'Seller', true, '1 hour ago'),
  ];

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.value<double>(context, mobile: 16, tablet: 24, desktop: 32);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
    child: ListView.builder(
      padding: EdgeInsets.all(hPad),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final u = _users[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(u.name[0], style: AppTypography.headingSmall.copyWith(color: AppColors.primary)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: u.isActive ? AppColors.primary : AppColors.textTertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(u.name, style: AppTypography.labelLarge),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _roleColor(u.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(u.role, style: AppTypography.labelSmall.copyWith(color: _roleColor(u.role))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(u.email, style: AppTypography.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Last seen', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                  Text(u.lastSeen, style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        );
      },
    ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Buyer':
        return AppColors.info;
      case 'Seller':
        return AppColors.primary;
      case 'Agent':
        return AppColors.amber;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _UserData {
  final String name, email, role, lastSeen;
  final bool isActive;

  const _UserData(this.name, this.email, this.role, this.isActive, this.lastSeen);
}

// ─── Tab 4: Search & Filter ──────────────────────────────────────────────

class _SearchFilterTab extends StatefulWidget {
  @override
  State<_SearchFilterTab> createState() => _SearchFilterTabState();
}

class _SearchFilterTabState extends State<_SearchFilterTab> {
  final _searchController = TextEditingController();
  String _searchType = 'Properties';
  String _status = 'All';

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.value<double>(context, mobile: 16, tablet: 24, desktop: 32);

    return SingleChildScrollView(
      padding: EdgeInsets.all(hPad),
      child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search properties, users, transactions...',
              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
              suffixIcon: IconButton(icon: SvgPicture.asset(AppAssets.icFilter, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)), onPressed: () {}),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Type toggle
          Row(
            children: ['Properties', 'Users', 'Transactions'].map((type) {
              final active = _searchType == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _searchType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: active ? AppColors.primary : AppColors.border),
                      ),
                      child: Center(
                        child: Text(type, style: AppTypography.labelMedium.copyWith(color: active ? Colors.white : AppColors.textSecondary)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Status filter
          Row(
            children: ['All', 'Active', 'Pending', 'Flagged'].map((s) {
              final active = _status == s;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(s, style: AppTypography.labelSmall.copyWith(color: active ? Colors.white : AppColors.textSecondary)),
                  selected: active,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: active ? AppColors.primary : AppColors.border),
                  onSelected: (_) => setState(() => _status = s),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Results placeholder
          Container(
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.cardShadow,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search, size: 48, color: AppColors.textTertiary.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('Search $_searchType', style: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary)),
                  Text('Enter a keyword to find ${_searchType.toLowerCase()}', style: AppTypography.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}
