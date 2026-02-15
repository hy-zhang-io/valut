import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/responsive.dart';

/// 屏幕尺寸信息
class ScreenInfo {
  const ScreenInfo({
    required this.width,
    required this.height,
    required this.deviceType,
    required this.breakpoint,
    required this.foldableState,
    required this.aspectRatio,
  });

  final double width;
  final double height;
  final DeviceType deviceType;
  final Breakpoint breakpoint;
  final FoldableState foldableState;
  final double aspectRatio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScreenInfo &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          deviceType == other.deviceType &&
          breakpoint == other.breakpoint &&
          foldableState == other.foldableState &&
          aspectRatio == other.aspectRatio;

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      deviceType.hashCode ^
      breakpoint.hashCode ^
      foldableState.hashCode ^
      aspectRatio.hashCode;

  @override
  String toString() {
    return 'ScreenInfo(width: $width, height: $height, deviceType: $deviceType, breakpoint: $breakpoint, foldableState: $foldableState, aspectRatio: $aspectRatio)';
  }

  /// 是否为移动端
  bool get isMobile => deviceType == DeviceType.mobile;

  /// 是否为平板
  bool get isTablet => deviceType == DeviceType.tablet;

  /// 是否为桌面
  bool get isDesktop => deviceType == DeviceType.desktop;

  /// 是否为折叠屏
  bool get isFoldable => deviceType == DeviceType.foldable;

  /// 是否为小屏幕
  bool get isSmallScreen => width < ResponsiveUtils.md;
}

/// 屏幕信息 Provider
///
/// 提供完整的屏幕信息，包括宽度、高度、设备类型等
final screenInfoProvider = Provider<ScreenInfo>((ref) {
  throw UnimplementedError(
    'screenInfoProvider must be overridden by ScreenInfoScope',
  );
});

/// 设备类型 Provider
///
/// 从屏幕信息中提取设备类型
final deviceTypeProvider = Provider<DeviceType>((ref) {
  final screenInfo = ref.watch(screenInfoProvider);
  return screenInfo.deviceType;
});

/// 折叠屏状态 Provider
///
/// 从屏幕信息中提取折叠屏状态
final foldableStateProvider = Provider<FoldableState>((ref) {
  final screenInfo = ref.watch(screenInfoProvider);
  return screenInfo.foldableState;
});

/// 屏幕信息 Scope
///
/// 必须包裹在应用最外层，提供屏幕信息给所有子组件
class ScreenInfoScope extends ConsumerStatefulWidget {
  const ScreenInfoScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ScreenInfoScope> createState() => _ScreenInfoScopeState();
}

class _ScreenInfoScopeState extends ConsumerState<ScreenInfoScope>
    with WidgetsBindingObserver {
  ScreenInfo? _currentScreenInfo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在 didChangeDependencies 中安全地访问 MediaQuery
    _updateScreenInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 当屏幕尺寸改变时更新设备类型
    // 例如：折叠屏展开/折叠、窗口大小改变
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateScreenInfo();
      }
    });
  }

  void _updateScreenInfo() {
    if (!mounted) return;

    final context = ref.context;

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final deviceType = ResponsiveUtils.getDeviceType(width);
    final breakpoint = ResponsiveUtils.getBreakpoint(width);
    final foldableState = ResponsiveUtils.getFoldableState(width);

    final newScreenInfo = ScreenInfo(
      width: width,
      height: height,
      deviceType: deviceType,
      breakpoint: breakpoint,
      foldableState: foldableState,
      aspectRatio: size.aspectRatio,
    );

    if (_currentScreenInfo != newScreenInfo) {
      setState(() {
        _currentScreenInfo = newScreenInfo;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 确保有屏幕信息
    _currentScreenInfo ??= _getInitialScreenInfo(context);

    return ProviderScope(
      overrides: [screenInfoProvider.overrideWithValue(_currentScreenInfo!)],
      child: widget.child,
    );
  }

  ScreenInfo _getInitialScreenInfo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final deviceType = ResponsiveUtils.getDeviceType(width);
    final breakpoint = ResponsiveUtils.getBreakpoint(width);
    final foldableState = ResponsiveUtils.getFoldableState(width);

    return ScreenInfo(
      width: width,
      height: height,
      deviceType: deviceType,
      breakpoint: breakpoint,
      foldableState: foldableState,
      aspectRatio: size.aspectRatio,
    );
  }
}

/// 用于监听屏幕尺寸变化的 Widget（简化版）
class DeviceTypeListener extends StatefulWidget {
  const DeviceTypeListener({super.key, required this.child});

  final Widget child;

  @override
  State<DeviceTypeListener> createState() => _DeviceTypeListenerState();
}

class _DeviceTypeListenerState extends State<DeviceTypeListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 当屏幕尺寸改变时更新设备类型
    // 例如：折叠屏展开/折叠、窗口大小改变
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 触发重建以更新设备类型
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
