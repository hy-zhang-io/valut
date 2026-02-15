import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// 饼图数据项
class PieChartData {
  const PieChartData({
    required this.value,
    required this.label,
    required this.color,
    this.icon,
  });

  final double value;
  final String label;
  final Color color;
  final IconData? icon;
}

/// 饼图组件
///
/// MD3 风格的饼图，支持动画、交互和图例
class PieChart extends StatefulWidget {
  const PieChart({
    super.key,
    required this.data,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.innerRadiusRatio = 0.6,
    this.showLegend = true,
    this.showLabels = true,
    this.legendPosition = LegendPosition.right,
    this.onSegmentTapped,
    this.selectedSegmentIndex,
    this.centerWidget,
  });

  final List<PieChartData> data;
  final bool animate;
  final Duration animationDuration;
  final double innerRadiusRatio;
  final bool showLegend;
  final bool showLabels;
  final LegendPosition legendPosition;
  final ValueChanged<int>? onSegmentTapped;
  final int? selectedSegmentIndex;
  final Widget? centerWidget;

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _hoveredSegmentIndex;

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

    final totalValue = widget.data.fold<double>(0.0, (sum, item) => sum + item.value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = constraints.maxWidth < 600;

        if (isVertical || widget.legendPosition == LegendPosition.bottom) {
          // 垂直布局：图表在上，图例在下
          return Column(
            children: [
              SizedBox(
                height: constraints.maxHeight * 0.6,
                child: _buildChart(totalValue),
              ),
              if (widget.showLegend)
                Expanded(
                  child: _buildLegend(constraints.maxWidth),
                ),
            ],
          );
        } else {
          // 水平布局：图表在左，图例在右
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildChart(totalValue),
              ),
              if (widget.showLegend)
                Expanded(
                  flex: 1,
                  child: _buildLegend(constraints.maxWidth),
                ),
            ],
          );
        }
      },
    );
  }

  Widget _buildChart(double totalValue) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _PieChartPainter(
            data: widget.data,
            animationValue: _animation.value,
            innerRadiusRatio: widget.innerRadiusRatio,
            selectedSegmentIndex: widget.selectedSegmentIndex,
            hoveredSegmentIndex: _hoveredSegmentIndex,
            showLabels: widget.showLabels,
            totalValue: totalValue,
          ),
          child: widget.centerWidget != null
              ? Center(child: widget.centerWidget)
              : null,
        );
      },
    );
  }

  Widget _buildLegend(double maxWidth) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.data.length,
      itemBuilder: (context, index) {
        final item = widget.data[index];
        final isSelected = widget.selectedSegmentIndex == index;
        final isHovered = _hoveredSegmentIndex == index;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredSegmentIndex = index),
          onExit: (_) => setState(() => _hoveredSegmentIndex = null),
          child: GestureDetector(
            onTap: () {
              if (widget.onSegmentTapped != null) {
                HapticFeedback.lightImpact();
                widget.onSegmentTapped!(index);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.color.withValues(alpha: 0.2)
                    : (isHovered
                        ? item.color.withValues(alpha: 0.1)
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: item.color, width: 2)
                    : null,
              ),
              child: Row(
                children: [
                  // Color indicator
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: item.color.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Icon
                  if (item.icon != null) ...[
                    Icon(
                      item.icon,
                      size: 20,
                      color: item.color,
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Label
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected ? item.color : null,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                  ),

                  // Value
                  Text(
                    _formatValue(item.value),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
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

  String _formatValue(double value) {
    if (value >= 10000) {
      return '${(value / 10000).toStringAsFixed(1)}w';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}

/// 饼图绘制器
class _PieChartPainter extends CustomPainter {
  _PieChartPainter({
    required this.data,
    required this.animationValue,
    required this.innerRadiusRatio,
    required this.totalValue,
    this.selectedSegmentIndex,
    this.hoveredSegmentIndex,
    this.showLabels = true,
  });

  final List<PieChartData> data;
  final double animationValue;
  final double innerRadiusRatio;
  final double totalValue;
  final int? selectedSegmentIndex;
  final int? hoveredSegmentIndex;
  final bool showLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.9;
    final innerRadius = radius * innerRadiusRatio;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = (item.value / totalValue) * 2 * math.pi * animationValue;

      // Determine if this segment should be highlighted
      final isSelected = selectedSegmentIndex == i;
      final isHovered = hoveredSegmentIndex == i;
      final offset = (isSelected || isHovered) ? 8.0 : 0.0;

      // Calculate the offset direction (mid angle of the segment)
      final midAngle = startAngle + sweepAngle / 2;
      final offsetCenter = Offset(
        center.dx + math.cos(midAngle) * offset,
        center.dy + math.sin(midAngle) * offset,
      );

      // Draw segment
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.fill;

      final path = Path();
      path.addArc(
        Rect.fromCircle(center: offsetCenter, radius: radius),
        startAngle,
        sweepAngle,
      );

      // Create donut hole
      final innerPath = Path();
      innerPath.addArc(
        Rect.fromCircle(center: offsetCenter, radius: innerRadius),
        startAngle,
        sweepAngle,
      );

      // Combine paths to create the donut segment
      final combinedPath = Path.combine(
        PathOperation.difference,
        path,
        innerPath,
      );

      canvas.drawPath(combinedPath, paint);

      // Draw label if enabled
      if (showLabels && sweepAngle > 0.2) {
        _drawLabel(
          canvas,
          offsetCenter,
          innerRadius + (radius - innerRadius) / 2,
          midAngle,
          item,
        );
      }

      startAngle += sweepAngle;
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    PieChartData item,
  ) {
    final labelRadius = radius * 0.7;
    final x = center.dx + math.cos(angle) * labelRadius;
    final y = center.dy + math.sin(angle) * labelRadius;

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${((item.value / totalValue) * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          color: item.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.selectedSegmentIndex != selectedSegmentIndex ||
        oldDelegate.hoveredSegmentIndex != hoveredSegmentIndex;
  }
}

/// 图例位置
enum LegendPosition { right, bottom }

/// 分类饼图组件
///
/// 专门用于显示分类收支的饼图
class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({
    super.key,
    required this.data,
    this.totalAmount = 0.0,
    this.animate = true,
    this.onCategoryTapped,
    this.selectedCategoryId,
    this.centerWidget,
  });

  final List<CategoryPieData> data;
  final double totalAmount;
  final bool animate;
  final ValueChanged<String>? onCategoryTapped;
  final String? selectedCategoryId;
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    final pieChartData = data.map((item) {
      return PieChartData(
        value: item.amount,
        label: item.categoryName,
        color: item.color,
        icon: item.icon,
      );
    }).toList();

    int? getSelectedIndex() {
      if (selectedCategoryId == null) return null;
      final index =
          data.indexWhere((item) => item.categoryId == selectedCategoryId);
      return index >= 0 ? index : null;
    }

    return PieChart(
      data: pieChartData,
      animate: animate,
      centerWidget: centerWidget ??
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '总计',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatAmount(totalAmount),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
      onSegmentTapped: onCategoryTapped != null
          ? (index) {
              final category = data[index];
              onCategoryTapped!(category.categoryId);
            }
          : null,
      selectedSegmentIndex: getSelectedIndex(),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000) {
      return '¥${(amount / 10000).toStringAsFixed(1)}w';
    }
    return '¥${amount.toStringAsFixed(0)}';
  }
}

/// 分类饼图数据
class CategoryPieData {
  const CategoryPieData({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.color,
    this.icon,
  });

  final String categoryId;
  final String categoryName;
  final double amount;
  final Color color;
  final IconData? icon;
}

/// 饼图图例组件（独立使用）
class PieChartLegend extends StatelessWidget {
  const PieChartLegend({
    super.key,
    required this.data,
    this.selectedValue,
    this.onItemTapped,
  });

  final List<PieChartData> data;
  final String? selectedValue;
  final ValueChanged<String>? onItemTapped;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: data.map((item) {
        final isSelected = selectedValue == item.label;
        return FilterChip(
          label: Text(item.label),
          selected: isSelected,
          onSelected: (selected) {
            if (onItemTapped != null) {
              onItemTapped!(item.label);
            }
          },
          backgroundColor: item.color.withValues(alpha: 0.1),
          selectedColor: item.color.withValues(alpha: 0.3),
          checkmarkColor: item.color,
          side: BorderSide(
            color: item.color.withValues(alpha: 0.3),
          ),
        );
      }).toList(),
    );
  }
}
