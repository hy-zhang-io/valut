import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// 柱状图数据项
class BarChartData {
  const BarChartData({
    required this.label,
    required this.value,
    this.color,
    this.icon,
  });

  final String label;
  final double value;
  final Color? color;
  final IconData? icon;
}

/// 柱状图组件
///
/// MD3 风格的柱状图，支持动画、交互和分组
class BarChart extends StatefulWidget {
  const BarChart({
    super.key,
    required this.data,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.showGrid = true,
    this.showValues = true,
    this.barWidth,
    this.barRadius = 8.0,
    this.spacing = 8.0,
    this.groupSpacing = 16.0,
    this.horizontal = false,
    this.minValue,
    this.maxValue,
    this.onBarTapped,
    this.selectedBarIndex,
    this.backgroundColor,
    this.valueFormat,
  });

  final List<BarChartData> data;
  final bool animate;
  final Duration animationDuration;
  final bool showGrid;
  final bool showValues;
  final double? barWidth;
  final double barRadius;
  final double spacing;
  final double groupSpacing;
  final bool horizontal;
  final double? minValue;
  final double? maxValue;
  final ValueChanged<int>? onBarTapped;
  final int? selectedBarIndex;
  final Color? backgroundColor;
  final String Function(double value)? valueFormat;

  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _hoveredBarIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      color: widget.backgroundColor,
      child: widget.horizontal
          ? _buildHorizontalChart(context)
          : _buildVerticalChart(context),
    );
  }

  Widget _buildVerticalChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dimensions
        final totalSpacing = widget.spacing * (widget.data.length - 1);
        final availableWidth = constraints.maxWidth -
            widget.groupSpacing * 2 - totalSpacing;
        final barWidth = widget.barWidth ??
            math.max(availableWidth / widget.data.length, 4.0);

        // Calculate value range
        double minValue = widget.minValue ??
            widget.data.map((e) => e.value).reduce(math.min) * 0.9;
        double maxValue = widget.maxValue ??
            widget.data.map((e) => e.value).reduce(math.max) * 1.1;

        if (minValue > 0) minValue = 0;

        final valueRange = maxValue - minValue;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.groupSpacing,
            vertical: widget.showValues ? 24 : 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.data.length, (index) {
              final item = widget.data[index];
              final isSelected = widget.selectedBarIndex == index;
              final isHovered = _hoveredBarIndex == index;
              final normalizedValue = (item.value - minValue) / valueRange;
              final barHeight = normalizedValue *
                  (constraints.maxHeight -
                      (widget.showValues ? 48 : 32) -
                      32) *
                  _animation.value;

              return _BarContainer(
                width: barWidth,
                height: barHeight,
                color: item.color ?? Theme.of(context).colorScheme.primary,
                radius: widget.barRadius,
                isSelected: isSelected,
                isHovered: isHovered,
                onTap: () => _handleBarTap(index),
                onHover: (hovered) {
                  setState(() {
                    _hoveredBarIndex = hovered ? index : null;
                  });
                },
                value: widget.showValues ? item.value : null,
                label: item.label,
                valueFormat: widget.valueFormat,
                horizontal: false,
                icon: item.icon,
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dimensions
        final totalSpacing = widget.spacing * (widget.data.length - 1);
        final availableHeight = constraints.maxHeight -
            widget.groupSpacing * 2 - totalSpacing;
        final barHeight = widget.barWidth ??
            math.max(availableHeight / widget.data.length, 24.0);

        // Calculate value range
        double minValue = widget.minValue ??
            widget.data.map((e) => e.value).reduce(math.min) * 0.9;
        double maxValue = widget.maxValue ??
            widget.data.map((e) => e.value).reduce(math.max) * 1.1;

        if (minValue > 0) minValue = 0;

        final valueRange = maxValue - minValue;
        final maxBarWidth = constraints.maxWidth -
            (widget.showValues ? 64 : 32) -
            80;

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: widget.groupSpacing,
            horizontal: widget.showValues ? 64 : 32,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(widget.data.length, (index) {
              final item = widget.data[index];
              final isSelected = widget.selectedBarIndex == index;
              final isHovered = _hoveredBarIndex == index;
              final normalizedValue = (item.value - minValue) / valueRange;
              final barWidth = normalizedValue * maxBarWidth * _animation.value;

              return _BarContainer(
                width: barWidth,
                height: barHeight,
                color: item.color ?? Theme.of(context).colorScheme.primary,
                radius: widget.barRadius,
                isSelected: isSelected,
                isHovered: isHovered,
                onTap: () => _handleBarTap(index),
                onHover: (hovered) {
                  setState(() {
                    _hoveredBarIndex = hovered ? index : null;
                  });
                },
                value: widget.showValues ? item.value : null,
                label: item.label,
                valueFormat: widget.valueFormat,
                horizontal: true,
                icon: item.icon,
              );
            }),
          ),
        );
      },
    );
  }

  void _handleBarTap(int index) {
    if (widget.onBarTapped != null) {
      HapticFeedback.lightImpact();
      widget.onBarTapped!(index);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无数据',
            style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// 柱状图容器组件
class _BarContainer extends StatefulWidget {
  const _BarContainer({
    required this.width,
    required this.height,
    required this.color,
    required this.radius,
    required this.isSelected,
    required this.isHovered,
    required this.onTap,
    required this.onHover,
    required this.horizontal,
    this.value,
    this.label,
    this.valueFormat,
    this.icon,
  });

  final double width;
  final double height;
  final Color color;
  final double radius;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;
  final bool horizontal;
  final double? value;
  final String? label;
  final String Function(double value)? valueFormat;
  final IconData? icon;

  @override
  State<_BarContainer> createState() => _BarContainerState();
}

class _BarContainerState extends State<_BarContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_BarContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered != oldWidget.isHovered) {
      if (widget.isHovered) {
        _scaleController.forward();
      } else {
        _scaleController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final scale = widget.isSelected ? 1.05 : _scaleAnimation.value;
    final effectiveColor = widget.isSelected
        ? widget.color.withValues(alpha: 0.8)
        : widget.color;

    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!widget.horizontal && widget.value != null)
              Text(
                _formatValue(widget.value!),
                style: theme.textTheme.bodySmall?.copyWith(
                      color: widget.isSelected
                          ? effectiveColor
                          : colorScheme.onSurfaceVariant,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            if (!widget.horizontal) const SizedBox(height: 4),
            Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.horizontal ? widget.width : null,
                height: widget.horizontal ? widget.height : widget.height,
                decoration: BoxDecoration(
                  color: effectiveColor,
                  borderRadius: BorderRadius.horizontal(
                    left: widget.horizontal
                        ? Radius.circular(widget.radius)
                        : Radius.circular(widget.radius),
                    right: widget.horizontal
                        ? Radius.circular(widget.radius)
                        : Radius.circular(widget.radius),
                  ),
                  boxShadow: widget.isSelected || widget.isHovered
                      ? [
                          BoxShadow(
                            color: effectiveColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: widget.horizontal
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (widget.icon != null)
                              Icon(
                                widget.icon,
                                size: 16,
                                color: colorScheme.onPrimary,
                              ),
                            if (widget.label != null)
                              Text(
                                widget.label!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimary,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (widget.value != null)
                              Text(
                                _formatValue(widget.value!),
                                style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                          ],
                        ),
                      )
                    : (widget.width > 40 && widget.height > 20)
                        ? Center(
                            child: widget.icon != null
                                ? Icon(
                                    widget.icon,
                                    size: 16,
                                    color: colorScheme.onPrimary,
                                  )
                                : null,
                          )
                    : null,
              ),
            ),
            if (!widget.horizontal && widget.label != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  widget.label!,
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: widget.isSelected
                            ? effectiveColor
                            : colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (widget.horizontal && widget.label != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  widget.label!,
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: widget.isSelected
                            ? effectiveColor
                            : colorScheme.onSurfaceVariant,
                        fontWeight:
                            widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (widget.valueFormat != null) {
      return widget.valueFormat!(value);
    }
    if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(1)}w';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}

/// 分组柱状图数据
class GroupedBarChartData {
  const GroupedBarChartData({
    required this.label,
    required this.groups,
  });

  final String label;
  final List<BarChartData> groups;
}

/// 分组柱状图组件
///
/// 支持多组数据对比的柱状图
class GroupedBarChart extends StatelessWidget {
  const GroupedBarChart({
    super.key,
    required this.data,
    this.groupLabels,
    this.animate = true,
    this.showLegend = true,
    this.barWidth,
    this.barRadius = 8.0,
    this.onBarTapped,
  });

  final List<GroupedBarChartData> data;
  final List<String>? groupLabels;
  final bool animate;
  final bool showLegend;
  final double? barWidth;
  final double barRadius;
  final ValueChanged<GroupedBarInfo>? onBarTapped;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        // Legend
        if (showLegend && groupLabels != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              children: groupLabels!.asMap().entries.map((entry) {
                final index = entry.key;
                final label = entry.value;
                // Get color from first group
                final color = data.isNotEmpty && data[0].groups.length > index
                    ? data[0].groups[index].color
                    : null;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color ?? Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(label),
                  ],
                );
              }).toList(),
            ),
          ),

        // Chart
        Expanded(
          child: _buildGroupedChart(context),
        ),
      ],
    );
  }

  Widget _buildGroupedChart(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dimensions
        final groupCount = data.length;
        final barsPerGroup = data.isNotEmpty ? data.first.groups.length : 1;
        final totalSpacing = 8.0 * (groupCount - 1) + 4.0 * (barsPerGroup - 1);
        final availableWidth = constraints.maxWidth - 32 - totalSpacing;
        final barWidth = this.barWidth ?? availableWidth / (groupCount * barsPerGroup);

        // Calculate value range
        double maxValue = 0;
        for (final group in data) {
          for (final bar in group.groups) {
            maxValue = math.max(maxValue, bar.value);
          }
        }
        maxValue *= 1.1;

        final chartHeight = constraints.maxHeight - 60;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(groupCount, (groupIndex) {
              final group = data[groupIndex];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bars in group
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(barsPerGroup, (barIndex) {
                      final bar = group.groups[barIndex];
                      final barHeight =
                          (bar.value / maxValue) * chartHeight;

                      return Padding(
                        padding: EdgeInsets.only(right: barIndex < barsPerGroup - 1 ? 4 : 0),
                        child: GestureDetector(
                          onTap: () {
                            if (onBarTapped != null) {
                              HapticFeedback.lightImpact();
                              onBarTapped!(GroupedBarInfo(
                                groupIndex: groupIndex,
                                barIndex: barIndex,
                                value: bar.value,
                              ));
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: barWidth,
                            height: animate ? barHeight : 0,
                            decoration: BoxDecoration(
                              color: bar.color ?? Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(barRadius),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  // Group label
                  SizedBox(
                    width: barWidth * barsPerGroup + 4 * (barsPerGroup - 1),
                    child: Text(
                      group.label,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}

/// 分组柱状图信息
class GroupedBarInfo {
  const GroupedBarInfo({
    required this.groupIndex,
    required this.barIndex,
    required this.value,
  });

  final int groupIndex;
  final int barIndex;
  final double value;
}
