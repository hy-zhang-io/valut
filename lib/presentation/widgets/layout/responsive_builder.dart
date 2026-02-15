import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive.dart';
import '../../../presentation/providers/device_provider.dart';

/// 响应式构建器
///
/// 根据设备类型自动选择对应的 Widget
class ResponsiveBuilder extends ConsumerWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.foldable,
    this.foldableOpening,
  });

  /// 移动端布局（宽度 < 600px）
  final Widget mobile;

  /// 平板布局（600px <= 宽度 < 1024px）
  final Widget? tablet;

  /// 桌面布局（1024px <= 宽度 < 1280px）
  final Widget? desktop;

  /// 折叠屏布局（宽度 >= 1280px 或检测到折叠屏）
  final Widget? foldable;

  /// 折叠屏展开中状态布局（900px <= 宽度 < 1000px）
  final Widget? foldableOpening;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);
    final deviceType = screenInfo.deviceType;
    final foldableState = screenInfo.foldableState;

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;

      case DeviceType.tablet:
        return tablet ?? mobile;

      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;

      case DeviceType.foldable:
        // 折叠屏特殊处理：根据折叠状态选择布局
        if (foldableState == FoldableState.opening && foldableOpening != null) {
          return foldableOpening!;
        }
        return foldable ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// 响应式值选择器
///
/// 根据设备类型选择不同的值
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.foldable,
  });

  final T mobile;
  final T? tablet;
  final T? desktop;
  final T? foldable;

  /// 根据设备类型获取值
  T getValue(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.foldable:
        return foldable ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// 响应式间距
///
/// 根据设备类型返回不同的间距值
class ResponsiveSpacing extends StatelessWidget {
  const ResponsiveSpacing({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  final Widget child;
  final ResponsiveValue<EdgeInsets>? padding;
  final ResponsiveValue<EdgeInsets>? margin;

  @override
  Widget build(BuildContext context) {
    final deviceType = context.deviceType;

    Widget current = child;

    if (margin != null) {
      current = Container(
        margin: margin!.getValue(deviceType),
        child: current,
      );
    }

    if (padding != null) {
      current = Padding(
        padding: padding!.getValue(deviceType),
        child: current,
      );
    }

    return current;
  }
}

/// 响应式布局助手
class LayoutHelper {
  /// 获取内容区域宽度（减去侧边栏宽度）
  static double getContentWidth(
    BuildContext context, {
    bool hasSideNav = false,
  }) {
    final screenWidth = context.screenWidth;
    final deviceType = context.deviceType;

    if (!hasSideNav) return screenWidth;

    final sideNavWidth = ResponsiveUtils.getSideNavWidth(deviceType);
    return screenWidth - sideNavWidth;
  }

  /// 获取网格列数
  static int getGridColumns(BuildContext context) {
    return ResponsiveUtils.getGridColumns(context.deviceType);
  }

  /// 计算子项宽度（网格布局）
  static double getChildWidth(
    BuildContext context, {
    required int columns,
    double spacing = 16,
    bool hasSideNav = false,
  }) {
    final contentWidth = getContentWidth(context, hasSideNav: hasSideNav);
    final totalSpacing = spacing * (columns - 1);
    return (contentWidth - totalSpacing) / columns;
  }
}

/// 响应式网格
///
/// 根据设备类型自动调整网格列数
class ResponsiveGrid extends ConsumerWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.maxColumns,
    this.hasSideNav = false,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? maxColumns;
  final bool hasSideNav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = maxColumns ?? LayoutHelper.getGridColumns(context);
    final childWidth = LayoutHelper.getChildWidth(
      context,
      columns: columns,
      spacing: spacing,
      hasSideNav: hasSideNav,
    );

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: childWidth,
          child: child,
        );
      }).toList(),
    );
  }
}

/// 响应式容器
///
/// 根据设备类型调整容器约束
class ResponsiveContainer extends ConsumerWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final ResponsiveValue<EdgeInsets>? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceType = context.deviceType;
    final effectiveMaxWidth = maxWidth ??
        (switch (deviceType) {
          DeviceType.mobile => 600.0,
          DeviceType.tablet => 900.0,
          DeviceType.desktop => 1200.0,
          DeviceType.foldable => 1400.0,
        });

    final effectivePadding = padding?.getValue(deviceType) ??
        ResponsiveUtils.getContentPadding(deviceType);

    return Container(
      constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
      padding: effectivePadding,
      child: child,
    );
  }
}

/// 隐藏/显示 Widget（基于设备类型）
class ResponsiveVisibility extends ConsumerWidget {
  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleMobile = true,
    this.visibleTablet = true,
    this.visibleDesktop = true,
    this.visibleFoldable = true,
  });

  final Widget child;
  final bool visibleMobile;
  final bool visibleTablet;
  final bool visibleDesktop;
  final bool visibleFoldable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceType = context.deviceType;

    final visible = switch (deviceType) {
      DeviceType.mobile => visibleMobile,
      DeviceType.tablet => visibleTablet,
      DeviceType.desktop => visibleDesktop,
      DeviceType.foldable => visibleFoldable,
    };

    if (!visible) return const SizedBox.shrink();
    return child;
  }
}
