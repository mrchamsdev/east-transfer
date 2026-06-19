import 'package:bank_scan/Gold/features/loans/screens/loans_screen.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../dashboard/dashboard_screen.dart';
import '../expenses/screens/expenses_screen.dart';
import '../gold/screens/gold_screen.dart';
import '../../widgets/drawer/gold_drawer.dart';
import '../../widgets/modals/quick_actions_modal.dart';
import '../../widgets/gold_app_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ExpensesScreenState> _expensesKey = GlobalKey<ExpensesScreenState>();
  final GlobalKey<GoldScreenState> _goldKey = GlobalKey<GoldScreenState>();
  final GlobalKey<LoansScreenState> _loansKey = GlobalKey<LoansScreenState>();
  late final List<Widget> _screens;
  final List<bool> _visited = [true, false, false, false, false];

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onTabSelected: _onItemTapped),
      ExpensesScreen(key: _expensesKey),
      const SizedBox.shrink(), // Placeholder for FAB
      GoldScreen(key: _goldKey),
      LoansScreen(key: _loansKey),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      QuickActionsModal.show(context);
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const GoldDrawer(),
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(5, (index) {
          if (!_visited[index] && index != _selectedIndex) {
            return const SizedBox.shrink();
          }
          _visited[index] = true;
          return _screens[index];
        }),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomAppBar(
          color: AppColors.appBarBackground,
          elevation: 0,
          padding: EdgeInsets.zero,
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'assets/gold/dashboard.png', 'assets/gold/dashboard.png', 'Home'),
              _buildNavItem(1, 'assets/gold/expenses.png', 'assets/gold/active-expenses.png', 'Expenses'),
              _buildFab(),
              _buildNavItem(3, 'assets/gold/gold.png', 'assets/gold/avtive-gold.png', 'Gold'),
              _buildNavItem(4, 'assets/gold/loans.png', 'assets/gold/active-loans.png', 'Loans'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFab() {
    return GestureDetector(
      onTap: () => QuickActionsModal.show(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF003366), // Specific dark blue from image
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: AppColors.white, size: 25),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String? title;
    bool showSearch = true;

    switch (_selectedIndex) {
      case 0:
        title = 'Home';
        showSearch = false;
        break;
      case 1:
        title = 'Expenses';
        showSearch = true;
        break;
      case 3:
        title = 'Gold Records';
        showSearch = true;
        break;
      case 4:
        title = 'Loans';
        showSearch = true;
        break;
    }

    return GoldAppBar(
      title: title,
      showSearch: showSearch,
      onSearchChanged: (query) {
        if (_selectedIndex == 1) {
          _expensesKey.currentState?.filterExpenses(query);
        } else if (_selectedIndex == 3) {
          _goldKey.currentState?.filterPurchases(query);
        } else if (_selectedIndex == 4) {
          _loansKey.currentState?.filterLoans(query);
        }
      },
    );
  }

  Widget _buildNavItem(int index, String assetPath, String activeAssetPath, String label) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppColors.primaryBlue : const Color(0xFF727271);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isSelected ? activeAssetPath : assetPath,
              width: 18,
              height: 18,
              // Tint dashboard.png since it has no separate active file
              color: index == 0 ? color : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.navLabel.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
