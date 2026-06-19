import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'sheets/sheets_screen.dart';
import '../users/users_screen.dart';
import '../settings/settings_screen.dart';
import '../utils/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _showBottomNav = true;
  int _previousIndex = 0;
  final GlobalKey<SheetsScreenState> _sheetsScreenKey =
      GlobalKey<SheetsScreenState>();
  final GlobalKey<UsersScreenState> _usersScreenKey =
      GlobalKey<UsersScreenState>();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onExtractionScreenShown: () {
          setState(() {
            _showBottomNav = false;
          });
        },
        onExtractionScreenHidden: () {
          setState(() {
            _showBottomNav = true;
          });
        },
      ),
      SheetsScreen(key: _sheetsScreenKey),
      UsersScreen(key: _usersScreenKey),
      SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _showBottomNav
          ? SafeArea(
              child: Container(
                color: Colors.white,
                // decoration: BoxDecoration(
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black.withOpacity(0.05),
                //       blurRadius: 10,
                //       offset: const Offset(0, -2),
                //     ),
                //   ],
                // ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    print('📱 [NAVIGATION] Tab clicked: Index $index');
                    setState(() {
                      _previousIndex = _currentIndex;
                      _currentIndex = index;
                    });
                    // Trigger API refresh when Sheets tab is clicked
                    if (index == 1 && _sheetsScreenKey.currentState != null) {
                      print('📋 [NAVIGATION] Triggering Sheets API refresh...');
                      _sheetsScreenKey.currentState!.refreshDataIfNeeded();
                    }
                    // Trigger API refresh when Users tab is clicked
                    if (index == 2 && _usersScreenKey.currentState != null) {
                      print('👥 [NAVIGATION] Triggering Users API refresh...');
                      _usersScreenKey.currentState!.refreshDataIfNeeded();
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: AppTheme.primaryBlue,
                  unselectedItemColor: AppTheme.navUnselected,
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  iconSize: 24,
                  elevation: 0,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedLabelStyle: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: TextStyle(
                    color: AppTheme.navUnselected,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  items: [
                    BottomNavigationBarItem(
                      icon: _buildSvgIcon('assets/images/bottom_nav_home.svg'),
                      activeIcon: _buildSvgIcon(
                        'assets/images/bottom_nav_active_home.svg',
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildSvgIcon(
                        'assets/images/bottom_nav_sheets.svg',
                      ),
                      activeIcon: _buildSvgIcon(
                        'assets/images/bottom_nav_active_sheets.svg',
                      ),
                      label: 'Sheets',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildSvgIcon('assets/images/bottom_nav_users.svg'),
                      activeIcon: _buildSvgIcon(
                        'assets/images/bottom_nav_active_user.svg',
                      ),
                      label: 'Users',
                    ),
                    BottomNavigationBarItem(
                      icon: _buildSvgIcon(
                        'assets/images/bottom_nav_settings.svg',
                      ),
                      activeIcon: _buildSvgIcon(
                        'assets/images/bottom_nav_active_settings.svg',
                      ),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSvgIcon(String assetPath) {
    return SvgPicture.asset(
      assetPath,
      width: 20,
      height: 20,
      // fit: BoxFit.contain,
    );
  }
}
