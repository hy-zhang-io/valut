import 'package:flutter/material.dart';

/// 响应式断点定义
enum Breakpoint { xs, sm, md, lg, xl, xxl }

/// 设备类型
enum DeviceType { mobile, tablet, desktop, foldable }

/// 折叠屏状态
enum FoldableState { closed, opening, open }

/// 响应式工具类
///
/// 提供响应式断点检测、设备类型判断和折叠屏状态检测
class ResponsiveUtils {
  // 断点常量（单位：逻辑像素）
  static const double xs = 0;
  static const double sm = 600;
  static const double md = 768;
  static const double lg = 1024;
  static const double xl = 1280;
  static const double xxl = 1536;

  // 折叠屏断点
  static const double foldableClosed = 0;
  static const double foldableOpening = 900;
  static const double foldableOpen = 1000;

  /// 根据屏幕宽度获取设备类型
  static DeviceType getDeviceType(double width) {
    if (width < sm) return DeviceType.mobile;
    if (width < lg) return DeviceType.tablet;
    if (width < xl) return DeviceType.desktop;
    return DeviceType.foldable;
  }

  /// 根据屏幕宽度获取断点
  static Breakpoint getBreakpoint(double width) {
    if (width < sm) return Breakpoint.xs;
    if (width < md) return Breakpoint.sm;
    if (width < lg) return Breakpoint.md;
    if (width < xl) return Breakpoint.lg;
    if (width < xxl) return Breakpoint.xl;
    return Breakpoint.xxl;
  }

  /// 检测当前设备是否为折叠屏
  ///
  /// 通过屏幕长宽比判断，折叠屏通常有特殊的长宽比
  static bool isFoldable(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final aspectRatio = size.aspectRatio;
    // 折叠屏通常长宽比大于2.0或小于0.5
    return aspectRatio > 2.0 || aspectRatio < 0.5;
  }

  /// 获取折叠屏状态
  static FoldableState getFoldableState(double width) {
    if (width < foldableOpening) return FoldableState.closed;
    if (width < foldableOpen) return FoldableState.opening;
    return FoldableState.open;
  }

  /// 根据设备类型获取侧边导航宽度
  static double getSideNavWidth(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 0; // 移动端不显示侧边导航
      case DeviceType.tablet:
        return 80; // 平板模式使用紧凑侧边栏
      case DeviceType.desktop:
        return 256; // 桌面模式使用完整侧边栏
      case DeviceType.foldable:
        return 256; // 折叠屏展开时使用完整侧边栏
    }
  }

  /// 根据设备类型获取内容区域边距
  static EdgeInsets getContentPadding(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16);
      case DeviceType.tablet:
        return const EdgeInsets.all(24);
      case DeviceType.desktop:
        return const EdgeInsets.all(32);
      case DeviceType.foldable:
        return const EdgeInsets.all(32);
    }
  }

  /// 获取网格布局列数
  static int getGridColumns(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.foldable:
        return 4;
    }
  }
}

/// 响应式扩展方法
extension ResponsiveBuildContext on BuildContext {
  /// 获取屏幕宽度
  double get screenWidth => MediaQuery.of(this).size.width;

  /// 获取屏幕高度
  double get screenHeight => MediaQuery.of(this).size.height;

  /// 获取设备类型
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(screenWidth);

  /// 获取断点
  Breakpoint get breakpoint => ResponsiveUtils.getBreakpoint(screenWidth);

  /// 是否为移动端
  bool get isMobile => deviceType == DeviceType.mobile;

  /// 是否为平板
  bool get isTablet => deviceType == DeviceType.tablet;

  /// 是否为桌面
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// 是否为折叠屏
  bool get isFoldable => deviceType == DeviceType.foldable;

  /// 是否为小屏幕（移动端 + 平板竖屏）
  bool get isSmallScreen => screenWidth < ResponsiveUtils.md;
}
