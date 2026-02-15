import 'package:flutter/material.dart';

/// Stagger 列表动画组件
///
/// 为列表中的每个子项添加延迟动画，创造流畅的交错效果
class StaggerListView extends StatefulWidget {
  const StaggerListView({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.slideOffset = const Offset(0, 20),
    this.startWithOpacity = true,
    this.shrinkWrap = false,
    this.padding,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
  });

  final List<Widget> children;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final bool startWithOpacity;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;

  @override
  State<StaggerListView> createState() => _StaggerListViewState();
}

class _StaggerListViewState extends State<StaggerListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      physics: widget.physics,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return _StaggerItem(
          index: index,
          staggerDelay: widget.staggerDelay,
          duration: widget.duration,
          curve: widget.curve,
          slideOffset: widget.slideOffset,
          startWithOpacity: widget.startWithOpacity,
          child: widget.children[index],
        );
      },
    );
  }
}

/// Stagger 网格动画组件
///
/// 为网格中的每个子项添加延迟动画
class StaggerGridView extends StatefulWidget {
  const StaggerGridView({
    super.key,
    required this.children,
    this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.slideOffset = const Offset(0, 20),
    this.startWithOpacity = true,
    this.shrinkWrap = false,
    this.padding,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
  });

  final List<Widget> children;
  final SliverGridDelegate gridDelegate;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final bool startWithOpacity;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;

  @override
  State<StaggerGridView> createState() => _StaggerGridViewState();
}

class _StaggerGridViewState extends State<StaggerGridView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: widget.gridDelegate,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      physics: widget.physics,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return _StaggerItem(
          index: index,
          staggerDelay: widget.staggerDelay,
          duration: widget.duration,
          curve: widget.curve,
          slideOffset: widget.slideOffset,
          startWithOpacity: widget.startWithOpacity,
          child: widget.children[index],
        );
      },
    );
  }
}

/// Stagger 列表组件（使用 Sliver）
///
/// 用于 CustomScrollView 中的 Stagger 列表
class StaggerSliverList extends StatelessWidget {
  const StaggerSliverList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.slideOffset = const Offset(0, 20),
    this.startWithOpacity = true,
  });

  final List<Widget> children;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final bool startWithOpacity;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _StaggerItem(
            index: index,
            staggerDelay: staggerDelay,
            duration: duration,
            curve: curve,
            slideOffset: slideOffset,
            startWithOpacity: startWithOpacity,
            child: children[index],
          );
        },
        childCount: children.length,
      ),
    );
  }
}

/// Stagger 网格组件（使用 Sliver）
///
/// 用于 CustomScrollView 中的 Stagger 网格
class StaggerSliverGrid extends StatelessWidget {
  const StaggerSliverGrid({
    super.key,
    required this.children,
    this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
    ),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.slideOffset = const Offset(0, 20),
    this.startWithOpacity = true,
  });

  final List<Widget> children;
  final SliverGridDelegate gridDelegate;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final bool startWithOpacity;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: gridDelegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _StaggerItem(
            index: index,
            staggerDelay: staggerDelay,
            duration: duration,
            curve: curve,
            slideOffset: slideOffset,
            startWithOpacity: startWithOpacity,
            child: children[index],
          );
        },
        childCount: children.length,
      ),
    );
  }
}

/// 内部使用的 Stagger 项组件
class _StaggerItem extends StatefulWidget {
  const _StaggerItem({
    required this.index,
    required this.staggerDelay,
    required this.duration,
    required this.curve,
    required this.slideOffset,
    required this.startWithOpacity,
    required this.child,
  });

  final int index;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final bool startWithOpacity;
  final Widget child;

  @override
  State<_StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<_StaggerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    // 延迟启动动画
    final delay = widget.staggerDelay * widget.index;
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            widget.slideOffset.dx * (1 - _animation.value),
            widget.slideOffset.dy * (1 - _animation.value),
          ),
          child: Opacity(
            opacity: widget.startWithOpacity ? _animation.value : 1.0,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Stagger 动画包装器
///
/// 用于任何需要 Stagger 动画的 Widget
class StaggerAnimation extends StatefulWidget {
  const StaggerAnimation({
    super.key,
    required this.index,
    required this.child,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.slideOffset = const Offset(0, 20),
    this.startWithOpacity = true,
  });

  final int index;
  final Widget child;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final bool startWithOpacity;

  @override
  State<StaggerAnimation> createState() => _StaggerAnimationState();
}

class _StaggerAnimationState extends State<StaggerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    final delay = widget.staggerDelay * widget.index;
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            widget.slideOffset.dx * (1 - _animation.value),
            widget.slideOffset.dy * (1 - _animation.value),
          ),
          child: Opacity(
            opacity: widget.startWithOpacity ? _animation.value : 1.0,
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
/// 用于快速创建 Stagger 动画
class StaggerBuilder extends StatelessWidget {
  const StaggerBuilder({
    super.key,
    required this.index,
    required this.child,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.slideOffset,
    this.scaleOffset,
    this.startWithOpacity = true,
  });

  final int index;
  final Widget child;
  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final Offset? slideOffset;
  final double? scaleOffset;
  final bool startWithOpacity;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        Widget result = child!;

        // 应用透明度
        if (startWithOpacity) {
          result = Opacity(
            opacity: value,
            child: result,
          );
        }

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
      child: child,
    );
  }
}

/// Stagger 动画配置
class StaggerConfig {
  const StaggerConfig({
    this.staggerDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.slideOffset = const Offset(0, 20),
    this.startWithOpacity = true,
  });

  final Duration staggerDelay;
  final Duration duration;
  final Curve curve;
  final Offset slideOffset;
  final bool startWithOpacity;

  /// 默认配置（从下方滑入）
  static const slideUp = StaggerConfig(
    slideOffset: Offset(0, 20),
  );

  /// 从左侧滑入配置
  static const slideLeft = StaggerConfig(
    slideOffset: Offset(-20, 0),
  );

  /// 从右侧滑入配置
  static const slideRight = StaggerConfig(
    slideOffset: Offset(20, 0),
  );

  /// 淡入配置（无滑动）
  static const fadeIn = StaggerConfig(
    slideOffset: Offset.zero,
  );

  /// 缩放淡入配置
  static const scaleIn = StaggerConfig(
    slideOffset: Offset.zero,
    startWithOpacity: true,
  );

  /// 快速配置
  static const fast = StaggerConfig(
    duration: Duration(milliseconds: 150),
    staggerDelay: Duration(milliseconds: 25),
  );

  /// 慢速配置
  static const slow = StaggerConfig(
    duration: Duration(milliseconds: 500),
    staggerDelay: Duration(milliseconds: 100),
  );
}
