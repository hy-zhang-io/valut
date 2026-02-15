import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 数字滚动动画组件
///
/// 从起始值滚动到目标值，带有平滑的动画效果
class AnimatedAmount extends StatefulWidget {
  const AnimatedAmount({
    super.key,
    required this.amount,
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 2,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutQuart,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines,
    this.semanticsLabel,
  });

  /// 目标金额
  final double amount;

  /// 前缀（如货币符号）
  final String prefix;

  /// 后缀
  final String suffix;

  /// 小数位数
  final int decimalPlaces;

  /// 动画时长
  final Duration duration;

  /// 动画曲线
  final Curve curve;

  /// 文字样式
  final TextStyle? style;

  /// 支撑样式
  final StrutStyle? strutStyle;

  /// 对齐方式
  final TextAlign? textAlign;

  /// 文字方向
  final TextDirection? textDirection;

  /// 区域设置
  final Locale? locale;

  /// 是否软换行
  final bool? softWrap;

  /// 溢出处理
  final TextOverflow? overflow;

  /// 文本缩放因子
  final double? textScaleFactor;

  /// 最大行数
  final int? maxLines;

  /// 语义标签
  final String? semanticsLabel;

  @override
  State<AnimatedAmount> createState() => _AnimatedAmountState();
}

class _AnimatedAmountState extends State<AnimatedAmount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double? _previousAmount;

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

    // 启动动画
    _controller.forward();

    _previousAmount = widget.amount;
  }

  @override
  void didUpdateWidget(AnimatedAmount oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 如果金额发生变化，重新启动动画
    if (widget.amount != oldWidget.amount) {
      _previousAmount = oldWidget.amount;
      _controller.reset();
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
      animation: _animation,
      builder: (context, child) {
        final currentAmount = _previousAmount != null
            ? _previousAmount! +
                (widget.amount - _previousAmount!) * _animation.value
            : widget.amount * _animation.value;

        return Text(
          '${widget.prefix}${_formatAmount(currentAmount)}${widget.suffix}',
          style: widget.style,
          strutStyle: widget.strutStyle,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          locale: widget.locale,
          softWrap: widget.softWrap,
          overflow: widget.overflow,
          textScaler: widget.textScaleFactor != null
              ? TextScaler.linear(widget.textScaleFactor!)
              : null,
          maxLines: widget.maxLines,
          semanticsLabel: widget.semanticsLabel,
        );
      },
    );
  }

  String _formatAmount(double amount) {
    // 处理负数
    final isNegative = amount < 0;
    final absoluteAmount = amount.abs();

    // 四舍五入到指定小数位
    final roundedAmount =
        (absoluteAmount * math.pow(10, widget.decimalPlaces)).round() /
            math.pow(10, widget.decimalPlaces);

    // 分离整数和小数部分
    final parts = roundedAmount.toStringAsFixed(widget.decimalPlaces).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // 添加千分位分隔符
    final formattedInteger = _addThousandSeparator(integerPart);

    // 组合结果
    String result = formattedInteger;
    if (widget.decimalPlaces > 0 && decimalPart.isNotEmpty) {
      result = '$formattedInteger.$decimalPart';
    }

    if (isNegative) {
      result = '-$result';
    }

    return result;
  }

  String _addThousandSeparator(String value) {
    final buffer = StringBuffer();
    final length = value.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(value[i]);
    }
    return buffer.toString();
  }
}

/// 计数动画组件
///
/// 用于整数的计数动画
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutQuart,
    this.style,
  });

  final int value;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _previousValue;

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

    _controller.forward();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _controller.reset();
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
      animation: _animation,
      builder: (context, child) {
        final currentValue = _previousValue != null
            ? (_previousValue! +
                    (widget.value - _previousValue!) * _animation.value)
                .round()
            : (widget.value * _animation.value).round();

        return Text(
          currentValue.toString(),
          style: widget.style,
        );
      },
    );
  }
}

/// 百分比动画组件
///
/// 用于显示百分比的动画
class AnimatedPercentage extends StatefulWidget {
  const AnimatedPercentage({
    super.key,
    required this.value,
    this.decimalPlaces = 1,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutQuart,
    this.style,
    this.suffix = '%',
  });

  final double value; // 0-100
  final int decimalPlaces;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final String suffix;

  @override
  State<AnimatedPercentage> createState() => _AnimatedPercentageState();
}

class _AnimatedPercentageState extends State<AnimatedPercentage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double? _previousValue;

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

    _controller.forward();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(AnimatedPercentage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _controller.reset();
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
      animation: _animation,
      builder: (context, child) {
        final currentValue = _previousValue != null
            ? _previousValue! +
                (widget.value - _previousValue!) * _animation.value
            : widget.value * _animation.value;

        return Text(
          '${currentValue.toStringAsFixed(widget.decimalPlaces)}${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

/// 动画值监听器
///
/// 用于监听动画值的变化
class AnimatedValueListener extends StatefulWidget {
  const AnimatedValueListener({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  });

  final double value;
  final Widget Function(BuildContext context, double animatedValue) builder;
  final Duration duration;
  final Curve curve;

  @override
  State<AnimatedValueListener> createState() => _AnimatedValueListenerState();
}

class _AnimatedValueListenerState extends State<AnimatedValueListener>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double? _previousValue;

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

    _controller.forward();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(AnimatedValueListener oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      _controller.reset();
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
      animation: _animation,
      builder: (context, child) {
        final currentValue = _previousValue != null
            ? _previousValue! +
                (widget.value - _previousValue!) * _animation.value
            : widget.value * _animation.value;

        return widget.builder(context, currentValue);
      },
    );
  }
}
