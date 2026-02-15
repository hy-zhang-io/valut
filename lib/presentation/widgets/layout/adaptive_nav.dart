import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import 'responsive_builder.dart';

/// 导航项
class NavItem {
  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String id;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

/// 应用导航项定义
class AppNavItems {
  static const List<NavItem> items = [
    NavItem(
      id: 'home',
      label: '首页',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    NavItem(
      id: 'assets',
      label: '资产',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
    ),
    NavItem(
      id: 'statistics',
      label: '分析',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
    ),
    NavItem(
      id: 'settings',
      label: '设置',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];
}

/// 自适应导航组件
///
/// 移动端显示底部导航，平板/桌面显示侧边导航
class AdaptiveNav extends ConsumerWidget {
  const AdaptiveNav({
    super.key,
    required this.selectedId,
    required this.onDestinationSelected,
    this.navItems = AppNavItems.items,
  });

  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final List<NavItem> navItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveBuilder(
      mobile: _BottomNav(
        selectedId: selectedId,
        onDestinationSelected: onDestinationSelected,
        navItems: navItems,
      ),
      tablet: _SideNav(
        selectedId: selectedId,
        onDestinationSelected: onDestinationSelected,
        navItems: navItems,
        compact: true,
      ),
      desktop: _SideNav(
        selectedId: selectedId,
        onDestinationSelected: onDestinationSelected,
        navItems: navItems,
        compact: false,
      ),
      foldable: _SideNav(
        selectedId: selectedId,
        onDestinationSelected: onDestinationSelected,
        navItems: navItems,
        compact: false,
      ),
    );
  }
}

/// 底部导航（移动端）
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedId,
    required this.onDestinationSelected,
    required this.navItems,
  });

  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final List<NavItem> navItems;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = navItems.indexWhere((item) => item.id == selectedId);

    return NavigationBar(
      selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
      onDestinationSelected: (index) {
        onDestinationSelected(navItems[index].id);
      },
      destinations: navItems
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}

/// 侧边导航（平板/桌面）
class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedId,
    required this.onDestinationSelected,
    required this.navItems,
    required this.compact,
  });

  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final List<NavItem> navItems;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = ResponsiveUtils.getSideNavWidth(
      compact ? DeviceType.tablet : DeviceType.desktop,
    );

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Logo 区域
            _buildLogo(context, compact),
            const SizedBox(height: 24),

            // 导航项
            Expanded(
              child: _buildNavItems(context),
            ),

            // 底部信息
            if (!compact) _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, bool compact) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        height: compact ? 40 : 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.surfaceContainerHighest,
              colorScheme.surfaceContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: compact
              ? Text(
                  '账',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'VAULT',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildNavItems(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: navItems.length,
      itemBuilder: (context, index) {
        final item = navItems[index];
        final isSelected = item.id == selectedId;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: _SideNavItem(
            item: item,
            isSelected: isSelected,
            compact: compact,
            onTap: () => onDestinationSelected(item.id),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 8),
          Text(
            'VAULT v1.0.0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '极致隐私离线记账',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 侧边导航项
class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.item,
    required this.isSelected,
    required this.compact,
    required this.onTap,
  });

  final NavItem item;
  final bool isSelected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 0 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
            if (!compact) ...[
              const SizedBox(width: 12),
              Text(
                item.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 导航视图切换器
///
/// 用于在不同视图之间切换，支持页面切换动画
class NavViewSwitcher extends ConsumerWidget {
  const NavViewSwitcher({
    super.key,
    required this.selectedId,
    required this.views,
    required this.navItems,
  });

  final String selectedId;
  final Map<String, Widget> views;
  final List<NavItem> navItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(selectedId),
        child: views[selectedId] ?? const SizedBox.shrink(),
      ),
    );
  }
}
