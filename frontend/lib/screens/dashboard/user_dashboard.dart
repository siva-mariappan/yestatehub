import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import 'tabs/dashboard_overview_tab.dart';
import 'tabs/my_properties_tab.dart';
import 'tabs/favourites_tab.dart';
import 'tabs/messages_tab.dart';
import 'tabs/profile_tab.dart';

/// User Dashboard — 5 Tab Navigation
class UserDashboard extends StatefulWidget {
  final int initialTab;

  const UserDashboard({super.key, this.initialTab = 0});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    _TabDef(Icons.dashboard_rounded, 'Dashboard'),
    _TabDef(Icons.home_rounded, 'My Properties'),
    _TabDef(Icons.favorite_rounded, 'Favourites'),
    _TabDef(Icons.message_rounded, 'Messages'),
    _TabDef(Icons.person_rounded, 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTab,
    );
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
        title: Text('My Dashboard', style: AppTypography.headingMedium),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: !isDesktop,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.labelMedium,
          tabs: _tabs.map((t) => Tab(
            icon: Icon(t.icon, size: 20),
            text: t.label,
          )).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DashboardOverviewTab(),
          MyPropertiesTab(),
          FavouritesTab(),
          MessagesTab(),
          ProfileTab(),
        ],
      ),
    );
  }
}

class _TabDef {
  final IconData icon;
  final String label;
  const _TabDef(this.icon, this.label);
}
