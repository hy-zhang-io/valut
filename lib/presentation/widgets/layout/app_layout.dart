import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../providers/device_provider.dart';
import 'adaptive_nav.dart';

/// 应用主布局
///
/// 包含自适应导航（底部/侧边）和内容区域
class AppLayout extends ConsumerWidget {
  const AppLayout({
    super.key,
    required this.selectedId,
    required this.onDestinationSelected,
    required this.views,
    required this.navItems,
    this.floatingActionButton,
  });

  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final Map<String, Widget> views;
  final List<NavItem> navItems;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);
    final deviceType = screenInfo.deviceType;

    return Scaffold(
      body: _buildBody(context, deviceType),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildBody(BuildContext context, DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return _MobileLayout(
          selectedId: selectedId,
          onDestinationSelected: onDestinationSelected,
          views: views,
          navItems: navItems,
          floatingActionButton: floatingActionButton,
        );
      case DeviceType.tablet:
      case DeviceType.desktop:
      case DeviceType.foldable:
        return _DesktopLayout(
          selectedId: selectedId,
          onDestinationSelected: onDestinationSelected,
          views: views,
          navItems: navItems,
          floatingActionButton: floatingActionButton,
        );
    }
  }
}

/// 移动端布局
class _MobileLayout extends ConsumerWidget {
  const _MobileLayout({
    required this.selectedId,
    required this.onDestinationSelected,
    required this.views,
    required this.navItems,
    this.floatingActionButton,
  });

  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final Map<String, Widget> views;
  final List<NavItem> navItems;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 内容区域
        Expanded(
          child: _buildContent(context),
        ),

        // 底部导航
        _BottomNav(
          selectedId: selectedId,
          onDestinationSelected: onDestinationSelected,
          navItems: navItems,
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final currentView = views[selectedId];
    if (currentView != null && floatingActionButton != null) {
      return Stack(
        children: [
          currentView,
          // FAB 会在 Scaffold 层处理
        ],
      );
    }
    return currentView ?? const SizedBox.shrink();
  }
}

/// 桌面/平板布局
class _DesktopLayout extends ConsumerWidget {
  const _DesktopLayout({
    required this.selectedId,
    required this.onDestinationSelected,
    required this.views,
    required this.navItems,
    this.floatingActionButton,
  });

  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final Map<String, Widget> views;
  final List<NavItem> navItems;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);
    final sideNavWidth = ResponsiveUtils.getSideNavWidth(screenInfo.deviceType);

    return Row(
      children: [
        // 侧边导航
        SizedBox(
          width: sideNavWidth,
          child: _SideNav(
            selectedId: selectedId,
            onDestinationSelected: onDestinationSelected,
            navItems: navItems,
            compact: screenInfo.deviceType == DeviceType.tablet,
          ),
        ),

        // 内容区域
        Expanded(
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return views[selectedId] ?? const SizedBox.shrink();
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

/// 侧边导航（桌面/平板）
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

    return Container(
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
