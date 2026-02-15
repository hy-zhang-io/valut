import 'package:flutter/material.dart';

/// 页面转场动画类型
enum PageTransitionType {
  /// 淡入淡出
  fade,

  /// 从右侧滑入
  slideRight,

  /// 从下方滑入
  slideUp,

  /// 缩放淡入
  scale,

  /// Material Design 的淡入通过效果
  fadeThrough,
}

/// 自定义页面转场
///
/// 提供多种页面切换动画效果
class CustomPageTransition<T> extends PageRouteBuilder<T> {
  CustomPageTransition({
    required this.child,
    this.type = PageTransitionType.fadeThrough,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.curve = Curves.easeInOutCubic,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration ?? duration,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            switch (type) {
              case PageTransitionType.fade:
                return FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: curve),
                  child: child,
                );

              case PageTransitionType.slideRight:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: curve),
                    child: child,
                  ),
                );

              case PageTransitionType.slideUp:
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: curve)),
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: curve),
                    child: child,
                  ),
                );

              case PageTransitionType.scale:
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: curve),
                  ),
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: animation, curve: curve),
                    child: child,
                  ),
                );

              case PageTransitionType.fadeThrough:
                // Material Design 3 的 Fade Through 转场
                final fadeInCurve = Interval(0.3, 1.0, curve: curve);

                return FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: fadeInCurve),
                  child: child,
                );
            }
          },
        );

  final Widget child;
  final PageTransitionType type;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
}

/// 共享元素转场（Hero 动画的扩展）
///
/// 用于页面间共享元素的平滑过渡
class SharedElementTransition<T> extends PageRouteBuilder<T> {
  SharedElementTransition({
    required this.child,
    this.heroTag,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
  }) : super(
          transitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (heroTag != null) {
              return Hero(
                tag: heroTag,
                child: child,
              );
            }
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: curve),
              child: child,
            );
          },
        );

  final Widget child;
  final Object? heroTag;
  final Duration duration;
  final Curve curve;
}

/// 页面转场助手类
class PageTransitionHelper {
  /// 使用淡入淡出转场导航
  static Future<T?> fadeTo<T>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      CustomPageTransition(
        child: page,
        type: PageTransitionType.fade,
        duration: duration,
      ),
    );
  }

  /// 使用右侧滑入转场导航
  static Future<T?> slideRightTo<T>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      CustomPageTransition(
        child: page,
        type: PageTransitionType.slideRight,
        duration: duration,
      ),
    );
  }

  /// 使用底部滑入转场导航
  static Future<T?> slideUpTo<T>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      CustomPageTransition(
        child: page,
        type: PageTransitionType.slideUp,
        duration: duration,
      ),
    );
  }

  /// 使用缩放淡入转场导航
  static Future<T?> scaleTo<T>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      CustomPageTransition(
        child: page,
        type: PageTransitionType.scale,
        duration: duration,
      ),
    );
  }

  /// 使用 Material Design 3 淡入通过转场导航
  static Future<T?> fadeThroughTo<T>(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Navigator.of(context).push<T>(
      CustomPageTransition(
        child: page,
        type: PageTransitionType.fadeThrough,
        duration: duration,
      ),
    );
  }
}

/// AnimatedWidget 包装器
///
/// 用于在 Widget 进入时自动播放动画
class AnimatedEntry extends StatefulWidget {
  const AnimatedEntry({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
    this.slideOffset = const Offset(0.05, 0),
    this.startWithOpacity = true,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final bool startWithOpacity;
  final Duration delay;

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: widget.startWithOpacity ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // 延迟启动动画
    if (widget.delay > Duration.zero) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// TweenAnimationBuilder 的便捷封装
///
/// 用于快速创建进入动画
class TweenEntry extends StatelessWidget {
  const TweenEntry({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOutCubic,
    this.slideOffset,
    this.scaleOffset,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset? slideOffset;
  final double? scaleOffset;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    Widget current = child;

    // 应用延迟
    if (delay > Duration.zero) {
      current = FutureBuilder(
        future: Future.delayed(delay),
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.done
              ? child
              : const SizedBox.shrink();
        },
      );
    }

    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        Widget result = child!;

        // 应用透明度
        result = Opacity(
          opacity: value,
          child: result,
        );

        // 应用滑动
        if (slideOffset != null) {
          result = Transform.translate(
            offset: Offset(
              slideOffset!.dx * (1 - value),
              slideOffset!.dy * (1 - value),
            ),
            child: result,
          );
        }

        // 应用缩放
        if (scaleOffset != null) {
          final scaleValue = scaleOffset! + (1 - scaleOffset!) * value;
          result = Transform.scale(
            scale: scaleValue,
            child: result,
          );
        }

        return result;
      },
      child: current,
    );
  }
}

/// 页面切换动画配置
class PageTransitionConfig {
  const PageTransitionConfig({
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.curve = Curves.easeInOutCubic,
    this.type = PageTransitionType.fadeThrough,
  });

  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final PageTransitionType type;

  /// 默认配置（Material Design 3）
  static const material = PageTransitionConfig(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOutCubic,
    type: PageTransitionType.fadeThrough,
  );

  /// 快速配置
  static const fast = PageTransitionConfig(
    duration: Duration(milliseconds: 150),
    curve: Curves.easeOut,
    type: PageTransitionType.fade,
  );

  /// 慢速配置
  static const slow = PageTransitionConfig(
    duration: Duration(milliseconds: 500),
    curve: Curves.easeInOutCubic,
    type: PageTransitionType.fadeThrough,
  );
}
