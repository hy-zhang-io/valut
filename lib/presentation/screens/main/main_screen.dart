import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/layout/adaptive_scaffold.dart';
import '../home/home_screen.dart';
import '../bills/bills_screen.dart';
import '../statistics/statistics_screen.dart';
import '../import/import_screen.dart';
import '../settings/settings_screen.dart';

/// 主屏幕 - 包含导航和页面切换
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  static const List<NavItem> _destinations = [
    NavItem(
      id: 'home',
      label: '首页',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    NavItem(
      id: 'bills',
      label: '账单',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    NavItem(
      id: 'statistics',
      label: '统计',
      icon: Icons.pie_chart_outline,
      selectedIcon: Icons.pie_chart,
    ),
    NavItem(
      id: 'import',
      label: '导入',
      icon: Icons.download_outlined,
      selectedIcon: Icons.download,
    ),
    NavItem(
      id: 'settings',
      label: '设置',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  final List<Widget> _pages = const [
    HomeScreen(),
    BillsScreen(),
    StatisticsScreen(),
    ImportScreen(),
    SettingsScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      destinations: _destinations,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _pages[_selectedIndex],
      ),
    );
  }
}
