import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../core/theme/app_colors.dart';

/// 折线图数据点
class LineChartDataPoint {
  const LineChartDataPoint({
    required this.x,
    required this.y,
    this.label,
  });

  final double x; // X轴位置（0-1）
  final double y; // Y轴值
  final String? label; // 数据点标签
}

/// 折线图数据系列
class LineChartSeries {
  const LineChartSeries({
    required this.name,
    required this.data,
    required this.color,
    this.lineWidth = 3.0,
    this.showPoints = true,
    this.showArea = false,
    this.pointRadius = 4.0,
  });

  final String name;
  final List<LineChartDataPoint> data;
  final Color color;
  final double lineWidth;
  final bool showPoints;
  final bool showArea;
  final double pointRadius;
}

/// 折线图组件
///
/// MD3 风格的折线图，支持多条数据系列、动画、交互
class LineChart extends StatefulWidget {
  const LineChart({
    super.key,
    required this.series,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.showGrid = true,
    this.showAxis = true,
    this.showTooltip = true,
    this.padding = const EdgeInsets.all(16),
    this.minY,
    this.maxY,
    this.xAxisLabels,
    this.onPointTapped,
    this.selectedPoint,
    this.backgroundColor,
  });

  final List<LineChartSeries> series;
  final bool animate;
  final Duration animationDuration;
  final bool showGrid;
  final bool showAxis;
  final bool showTooltip;
  final EdgeInsets padding;
  final double? minY;
  final double? maxY;
  final List<String>? xAxisLabels;
  final ValueChanged<LineChartPointInfo>? onPointTapped;
  final LineChartPointInfo? selectedPoint;
  final Color? backgroundColor;

  @override
  State<LineChart> createState() => _LineChartState();
}

class _LineChartState extends State<LineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  LineChartPointInfo? _hoveredPoint;

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
    final theme = Theme.of(context);

    if (widget.series.isEmpty) {
      return _buildEmptyState(context);
    }

    // Calculate min/max Y values
    double minY = double.infinity;
    double maxY = -double.infinity;
    for (final series in widget.series) {
      for (final point in series.data) {
        minY = math.min(minY, point.y);
        maxY = math.max(maxY, point.y);
      }
    }

    if (widget.minY != null) minY = widget.minY!;
    if (widget.maxY != null) maxY = widget.maxY!;

    // Add padding to the range
    final range = maxY - minY;
    final paddedMinY = minY - range * 0.1;
    final paddedMaxY = maxY + range * 0.1;

    return Container(
      color: widget.backgroundColor,
      padding: widget.padding,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _LineChartPainter(
              series: widget.series,
              animationValue: _animation.value,
              showGrid: widget.showGrid,
              showAxis: widget.showAxis,
              minY: paddedMinY,
              maxY: paddedMaxY,
              selectedPoint: widget.selectedPoint,
              hoveredPoint: _hoveredPoint,
              theme: theme,
            ),
            child: _buildTouchDetector(
              context,
              paddedMinY,
              paddedMaxY,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTouchDetector(
    BuildContext context,
    double minY,
    double maxY,
  ) {
    return GestureDetector(
      onTapDown: (details) {
        final position = details.localPosition;
        final renderBox = context.findRenderObject() as RenderBox?;
        final size = renderBox?.size ?? Size.zero;

        // Find the nearest point
        final point = _findNearestPoint(position, size, minY, maxY);
        if (point != null && widget.onPointTapped != null) {
          HapticFeedback.lightImpact();
          widget.onPointTapped!(point);
        }
      },
      child: MouseRegion(
        onHover: (event) {
          final position = event.position;
          final renderBox = context.findRenderObject() as RenderBox?;
          final size = renderBox?.size ?? Size.zero;

          final point = _findNearestPoint(position, size, minY, maxY);
          if (point != _hoveredPoint) {
            setState(() {
              _hoveredPoint = point;
            });
          }
        },
        onExit: (event) {
          setState(() {
            _hoveredPoint = null;
          });
        },
        child: CustomSingleChildLayout(
          delegate: _ChartLayoutDelegate(
            xAxisLabels: widget.xAxisLabels,
            minY: minY,
            maxY: maxY,
          ),
        ),
      ),
    );
  }

  LineChartPointInfo? _findNearestPoint(
    Offset position,
    Size size,
    double minY,
    double maxY,
  ) {
    const threshold = 20.0;
    LineChartPointInfo? nearestPoint;
    double minDistance = threshold;

    for (int i = 0; i < widget.series.length; i++) {
      final series = widget.series[i];
      for (int j = 0; j < series.data.length; j++) {
        final point = series.data[j];
        final x = widget.padding.left + point.x * (size.width - widget.padding.horizontal);
        final yRange = maxY - minY;
        final y =
            size.height -
            widget.padding.bottom -
            ((point.y - minY) / yRange) * (size.height - widget.padding.vertical);

        final distance = math.sqrt(
          math.pow(position.dx - x, 2) + math.pow(position.dy - y, 2),
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestPoint = LineChartPointInfo(
            seriesIndex: i,
            pointIndex: j,
            x: point.x,
            y: point.y,
            label: point.label,
            seriesName: series.name,
            color: series.color,
          );
        }
      }
    }

    return nearestPoint;
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
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

/// 折线图点信息
class LineChartPointInfo {
  const LineChartPointInfo({
    required this.seriesIndex,
    required this.pointIndex,
    required this.x,
    required this.y,
    this.label,
    this.seriesName,
    this.color,
  });

  final int seriesIndex;
  final int pointIndex;
  final double x;
  final double y;
  final String? label;
  final String? seriesName;
  final Color? color;
}

/// 折线图绘制器
class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.animationValue,
    required this.showGrid,
    required this.showAxis,
    required this.minY,
    required this.maxY,
    this.selectedPoint,
    this.hoveredPoint,
    required this.theme,
  });

  final List<LineChartSeries> series;
  final double animationValue;
  final bool showGrid;
  final bool showAxis;
  final double minY;
  final double maxY;
  final LineChartPointInfo? selectedPoint;
  final LineChartPointInfo? hoveredPoint;
  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final colorScheme = theme.colorScheme;

    // Draw grid
    if (showGrid) {
      _drawGrid(canvas, size, colorScheme);
    }

    // Draw axis
    if (showAxis) {
      _drawAxis(canvas, size, colorScheme);
    }

    // Draw each series
    for (int i = 0; i < series.length; i++) {
      _drawSeries(canvas, size, series[i], i);
    }

    // Draw tooltip
    if (selectedPoint != null || hoveredPoint != null) {
      _drawTooltip(canvas, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size, ColorScheme colorScheme) {
    final gridPaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Horizontal grid lines
    for (int i = 0; i <= 5; i++) {
      final y = size.height - (i / 5) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i <= 10; i++) {
      final x = (i / 10) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }
  }

  void _drawAxis(Canvas canvas, Size size, ColorScheme colorScheme) {
    final axisPaint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.3)
      ..strokeWidth = 2;

    // X axis
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );

    // Y axis
    canvas.drawLine(
      Offset(0, 0),
      Offset(0, size.height),
      axisPaint,
    );
  }

  void _drawSeries(Canvas canvas, Size size, LineChartSeries seriesData, int seriesIndex) {
    if (seriesData.data.isEmpty) return;

    final path = Path();
    final areaPath = Path();

    final firstPoint = seriesData.data.first;
    final startX = firstPoint.x * size.width;
    final yRange = maxY - minY;
    final startY = size.height - ((firstPoint.y - minY) / yRange) * size.height;

    path.moveTo(startX, startY);

    if (seriesData.showArea) {
      areaPath.moveTo(startX, size.height);
      areaPath.lineTo(startX, startY);
    }

    for (int i = 1; i < seriesData.data.length; i++) {
      final point = seriesData.data[i];
      final x = point.x * size.width;
      final y = size.height - ((point.y - minY) / yRange) * size.height;

      // Animate the path
      final animatedX = startX + (x - startX) * animationValue;
      final animatedY = startY + (y - startY) * animationValue;

      path.lineTo(animatedX, animatedY);

      if (seriesData.showArea) {
        areaPath.lineTo(animatedX, animatedY);
      }
    }

    if (seriesData.showArea) {
      final lastPoint = seriesData.data.last;
      final lastX = lastPoint.x * size.width;
      areaPath.lineTo(lastX, size.height);
      areaPath.close();
    }

    // Draw area
    if (seriesData.showArea) {
      final areaPaint = Paint()
        ..color = seriesData.color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawPath(areaPath, areaPaint);
    }

    // Draw line
    final linePaint = Paint()
      ..color = seriesData.color
      ..strokeWidth = seriesData.lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw points
    if (seriesData.showPoints) {
      for (int i = 0; i < seriesData.data.length; i++) {
        final point = seriesData.data[i];
        final x = point.x * size.width;
        final y = size.height - ((point.y - minY) / yRange) * size.height;

        final isSelected = selectedPoint?.seriesIndex == seriesIndex &&
            selectedPoint?.pointIndex == i;
        final isHovered = hoveredPoint?.seriesIndex == seriesIndex &&
            hoveredPoint?.pointIndex == i;

        final radius = (isSelected || isHovered)
            ? seriesData.pointRadius * 1.5
            : seriesData.pointRadius;

        final pointPaint = Paint()
          ..color = seriesData.color
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(x, y),
          radius * animationValue,
          pointPaint,
        );

        // Draw border for selected/hovered points
        if (isSelected || isHovered) {
          final borderPaint = Paint()
            ..color = seriesData.color
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(
            Offset(x, y),
            radius * 1.5 * animationValue,
            borderPaint,
          );
        }
      }
    }
  }

  void _drawTooltip(Canvas canvas, Size size) {
    final point = selectedPoint ?? hoveredPoint;
    if (point == null) return;

    final x = point.x * size.width;
    final yRange = maxY - minY;
    final y = size.height - ((point.y - minY) / yRange) * size.height;

    // Draw tooltip background
    final tooltipText = point.label ?? point.y.toStringAsFixed(2);
    final textPainter = TextPainter(
      text: TextSpan(
        text: tooltipText,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onPrimary,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    const padding = 8.0;
    final tooltipWidth = textPainter.width + padding * 2;
    final tooltipHeight = textPainter.height + padding * 2;

    final tooltipX = math.min(
      math.max(x - tooltipWidth / 2, padding),
      size.width - tooltipWidth - padding,
    );
    final tooltipY = math.max(y - tooltipHeight - padding, padding);

    final tooltipRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tooltipX, tooltipY, tooltipWidth, tooltipHeight),
      const Radius.circular(8),
    );

    final tooltipPaint = Paint()
      ..color = point.color ?? theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    canvas.drawRRect(tooltipRect, tooltipPaint);

    // Draw tooltip text
    textPainter.paint(
      canvas,
      Offset(tooltipX + padding, tooltipY + padding),
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.selectedPoint != selectedPoint ||
        oldDelegate.hoveredPoint != hoveredPoint;
  }
}

class _ChartLayoutDelegate extends SingleChildLayoutDelegate {
  _ChartLayoutDelegate({
    required this.xAxisLabels,
    required this.minY,
    required this.maxY,
  });

  final List<String>? xAxisLabels;
  final double minY;
  final double maxY;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset.zero;
  }

  @override
  bool shouldRelayout(_ChartLayoutDelegate oldDelegate) {
    return oldDelegate.xAxisLabels != xAxisLabels ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY;
  }
}

/// 简化的月度趋势折线图
///
/// 专门用于显示月度收支趋势
class MonthlyTrendChart extends StatelessWidget {
  const MonthlyTrendChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
    this.labels,
    this.animate = true,
    this.onPointTapped,
  });

  final List<double> incomeData;
  final List<double> expenseData;
  final List<String>? labels;
  final bool animate;
  final ValueChanged<LineChartPointInfo>? onPointTapped;

  @override
  Widget build(BuildContext context) {
    // Convert data to chart points
    final incomePoints = _convertToPoints(incomeData);
    final expensePoints = _convertToPoints(expenseData);

    return LineChart(
      series: [
        LineChartSeries(
          name: '收入',
          data: incomePoints,
          color: AppColors.success,
          showPoints: true,
          showArea: true,
        ),
        LineChartSeries(
          name: '支出',
          data: expensePoints,
          color: AppColors.error,
          showPoints: true,
          showArea: true,
        ),
      ],
      xAxisLabels: labels,
      animate: animate,
      onPointTapped: onPointTapped,
    );
  }

  List<LineChartDataPoint> _convertToPoints(List<double> data) {
    return List.generate(
      data.length,
      (index) => LineChartDataPoint(
        x: index / (data.length > 1 ? data.length - 1 : 1),
        y: data[index],
        label: data[index].toStringAsFixed(0),
      ),
    );
  }
}
