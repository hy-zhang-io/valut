import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 导航项
class NavItem {
  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

/// 自适应布局 Scaffold
/// 根据屏幕宽度自动切换底部导航栏和侧边导航栏
class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.floatingActionButton,
  });

  final List<NavItem> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final Widget? floatingActionButton;

  /// 判断是否为平板/折叠屏（宽度大于 600）
  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);

    if (isLargeScreen) {
      return _buildLargeScreenLayout(context);
    } else {
      return _buildSmallScreenLayout(context);
    }
  }

  /// 大屏幕布局 - 侧边导航栏
  Widget _buildLargeScreenLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // 侧边导航栏
          Container(
            width: AppTheme.navigationRailWidth,
            color: AppTheme.surface,
            child: Column(
              children: [
                // 顶部 Logo 区域
                _buildLogoHeader(context),
                const Divider(height: 1),
                // 导航项
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: destinations.length,
                    itemBuilder: (context, index) {
                      return _buildNavRailItem(context, index);
                    },
                  ),
                ),
                // 底部版本信息
                _buildVersionFooter(context),
              ],
            ),
          ),
          // 主内容区域
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  /// 小屏幕布局 - 底部导航栏
  Widget _buildSmallScreenLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations.map((item) {
          final isSelected = destinations.indexOf(item) == selectedIndex;
          return NavigationDestination(
            icon: Icon(isSelected ? item.selectedIcon : item.icon),
            label: item.label,
            tooltip: item.label,
          );
        }).toList(),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  /// Logo 头部
  Widget _buildLogoHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '智能记账本',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Smart Ledger',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 导航项
  Widget _buildNavRailItem(BuildContext context, int index) {
    final destination = destinations[index];
    final isSelected = index == selectedIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  isSelected ? destination.selectedIcon : destination.icon,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Text(
                  destination.label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 版本信息
  Widget _buildVersionFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        '智能记账本 v1.0',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
