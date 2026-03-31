import 'package:flutter/material.dart';
import 'config/colors.dart';
import 'config/typography.dart';
import 'config/responsive.dart';
import 'services/auth_service.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/saved/saved_screen.dart';
import 'screens/services/services_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/service_provider/sp_app.dart';
import 'screens/add_property/add_property_wizard.dart';
import 'screens/dashboard/user_dashboard.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/admin/owner_admin_screen.dart';
import 'screens/search/property_listing_screen.dart';
import 'screens/search/search_page.dart';
import 'screens/category/category_property_screen.dart';
import 'widgets/navigation/bottom_nav.dart';
import 'widgets/header/app_header.dart';

class YEstateHubApp extends StatefulWidget {
  const YEstateHubApp({super.key});

  @override
  State<YEstateHubApp> createState() => _YEstateHubAppState();
}

class _YEstateHubAppState extends State<YEstateHubApp> {
  // Flow state: splash -> onboarding -> auth -> main / serviceProvider / admin
  _AppState _appState = _AppState.splash;
  bool _isServiceProvider = false;
  int _currentTab = 0;
  int _selectedIntent = 0;

  // Admin email — only this email gets the admin panel
  static const String _adminEmail = 'yestatehub@gmail.com';

  // Real logged-in user email from Firebase
  String _currentUserEmail = '';

  bool get _isAdmin => _currentUserEmail.toLowerCase() == _adminEmail;

  @override
  Widget build(BuildContext context) {
    switch (_appState) {
      case _AppState.splash:
        return SplashScreen(
          onComplete: () => setState(() => _appState = _AppState.onboarding),
        );
      case _AppState.onboarding:
        return OnboardingScreen(
          onComplete: () => setState(() => _appState = _AppState.auth),
        );
      case _AppState.auth:
        return LoginScreen(
          onLoginSuccess: (isServiceProvider, {String? email}) => setState(() {
            _currentUserEmail = email ?? AuthService().currentUser?.email ?? '';
            _isServiceProvider = isServiceProvider;
            // Admin and regular users both go to main app
            // Admin can access admin panel via header icon
            if (isServiceProvider && _currentUserEmail.toLowerCase() != _adminEmail) {
              _appState = _AppState.serviceProvider;
            } else {
              _appState = _AppState.main;
            }
          }),
        );
      case _AppState.serviceProvider:
        return SpApp(onLogout: () => _handleLogout());
      case _AppState.main:
        return _buildMainApp(context);
    }
  }

  Widget _buildMainApp(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final showHeader = !isMobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header — shown on tablet + desktop
          if (showHeader)
            AppHeader(
              currentUserEmail: _currentUserEmail,
              currentIndex: _currentTab,
              notificationCount: 3,
              onNavTap: (index) => _handleHeaderNav(context, index),
              onSellProperty: () => _pushScreen(context, const AddPropertyWizard()),
              onNotifications: () => _pushScreen(context, const NotificationsScreen()),
              onFilter: () => _pushScreen(context, const PropertyListingScreen()),
            ),
          // Screen content
          Expanded(
            child: IndexedStack(
              index: _currentTab,
              children: [
                HomeScreen(
                  onNavigate: (index) => setState(() => _currentTab = index),
                  selectedIntent: _selectedIntent,
                  onIntentChanged: (i) => _handleIntentTap(context, i),
                  isAdmin: _isAdmin,
                ),
                const SearchScreen(),
                const SavedScreen(),
                const ServicesScreen(),
                ProfileScreen(onLogout: _handleLogout),
              ],
            ),
          ),
        ],
      ),
      // Floating admin button — mobile only, admin only
      floatingActionButton: (isMobile && _isAdmin)
          ? FloatingActionButton(
              onPressed: () => _pushScreen(
                context,
                OwnerAdminScreen(
                  onLogout: _handleLogout,
                  onViewAsUser: () => Navigator.pop(context),
                ),
              ),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white),
            )
          : null,
      // Bottom nav — mobile only
      bottomNavigationBar: isMobile
          ? AppBottomNav(
              currentIndex: _currentTab,
              onTap: (index) => setState(() => _currentTab = index),
            )
          : null,
    );
  }

  /// Handle AppHeader nav link taps
  /// 0=Home, 1=Search/Filter, 2=Dashboard, 3=Chat, 4=Favourites, 5=Admin, 6=Analytics
  void _handleHeaderNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        setState(() => _currentTab = 0);
        break;
      case 1:
        _pushScreen(context, const SearchPage());
        break;
      case 2:
        _pushScreen(context, UserDashboard(onLogout: _handleLogout));
        break;
      case 3:
        _pushScreen(context, const ChatScreen());
        break;
      case 4:
        setState(() => _currentTab = 2);
        break;
      case 5:
        if (_isAdmin) {
          _pushScreen(
            context,
            OwnerAdminScreen(
              onLogout: _handleLogout,
              onViewAsUser: () => Navigator.pop(context),
            ),
          );
        }
        break;
      case 6:
        _pushScreen(context, const AnalyticsScreen());
        break;
    }
  }

  void _handleIntentTap(BuildContext context, int index) {
    setState(() => _selectedIntent = index);
    const categories = ['Buy', 'Rent', 'PG', 'Commercial', 'Services'];
    final category = categories[index];
    if (category == 'Services') {
      setState(() => _currentTab = 3);
    } else {
      _pushScreen(context, CategoryPropertyScreen(category: category));
    }
  }

  void _pushScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _handleLogout() async {
    await AuthService().signOut();
    // Pop all pushed routes so we return to the root widget
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
    setState(() {
      _appState = _AppState.auth;
      _isServiceProvider = false;
      _currentUserEmail = '';
      _currentTab = 0;
    });
  }

}

enum _AppState { splash, onboarding, auth, main, serviceProvider }
