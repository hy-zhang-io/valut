import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 月份选择器组件
///
/// 用于选择年份和月份，支持上/下月切换
class MonthSelector extends ConsumerWidget {
  const MonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
    this.showYear = true,
    this.compact = false,
  });

  /// 当前选中的月份（格式：YYYY-MM）
  final String selectedMonth;

  /// 月份改变回调
  final ValueChanged<String> onMonthChanged;

  /// 是否显示年份
  final bool showYear;

  /// 是否使用紧凑模式
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 解析当前选中月份
    final parts = selectedMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上个月按钮
          _MonthSelectorButton(
            icon: Icons.chevron_left,
            onPressed: () => _navigateToMonth(context, year, month, -1),
          ),

          const SizedBox(width: 16),

          // 当前月份显示
          _MonthDisplay(
            year: year,
            month: month,
            showYear: showYear,
            compact: compact,
          ),

          const SizedBox(width: 16),

          // 下个月按钮
          _MonthSelectorButton(
            icon: Icons.chevron_right,
            onPressed: () => _navigateToMonth(context, year, month, 1),
          ),
        ],
      ),
    );
  }

  void _navigateToMonth(BuildContext context, int year, int month, int offset) {
    final newMonth = month + offset;

    int newYear = year;
    int newMonthValue = newMonth;

    // 处理跨年
    if (newMonth > 12) {
      newYear = year + 1;
      newMonthValue = 1;
    } else if (newMonth < 1) {
      newYear = year - 1;
      newMonthValue = 12;
    }

    // 格式化为 YYYY-MM
    final formattedMonth = '$newYear-$newMonthValue';
    onMonthChanged(formattedMonth);
  }
}

/// 月份选择器按钮
class _MonthSelectorButton extends StatelessWidget {
  const _MonthSelectorButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// 月份显示组件
class _MonthDisplay extends StatelessWidget {
  const _MonthDisplay({
    required this.year,
    required this.month,
    required this.showYear,
    required this.compact,
  });

  final int year;
  final int month;
  final bool showYear;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final monthNames = [
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];

    if (compact) {
      // 紧凑模式：只显示月
      return Text(
        monthNames[month - 1],
        style: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // 完整模式：显示年月
    return Text(
      showYear ? '$year年 ${monthNames[month - 1]}' : monthNames[month - 1],
      style: theme.textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 月份范围选择器
///
/// 用于选择开始月份和结束月份
class MonthRangeSelector extends StatefulWidget {
  const MonthRangeSelector({
    super.key,
    required this.startMonth,
    required this.endMonth,
    required this.onRangeChanged,
  });

  final String startMonth;
  final String endMonth;
  final void Function(String start, String end) onRangeChanged;

  @override
  State<MonthRangeSelector> createState() => _MonthRangeSelectorState();
}

class _MonthRangeSelectorState extends State<MonthRangeSelector> {
  late String _startMonth;
  late String _endMonth;

  @override
  void initState() {
    super.initState();
    _startMonth = widget.startMonth;
    _endMonth = widget.endMonth;
  }

  @override
  void didUpdateWidget(MonthRangeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startMonth != oldWidget.startMonth) {
      _startMonth = widget.startMonth;
    }
    if (widget.endMonth != oldWidget.endMonth) {
      _endMonth = widget.endMonth;
    }
  }

  void _onStartMonthChanged(String month) {
    setState(() {
      _startMonth = month;
    });
    widget.onRangeChanged(_startMonth, _endMonth);
  }

  void _onEndMonthChanged(String month) {
    setState(() {
      _endMonth = month;
    });
    widget.onRangeChanged(_startMonth, _endMonth);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MonthSelectorTile(
                label: '开始月份',
                selectedMonth: _startMonth,
                onMonthChanged: _onStartMonthChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MonthSelectorTile(
                label: '结束月份',
                selectedMonth: _endMonth,
                onMonthChanged: _onEndMonthChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _calculateMonthDiff(),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _calculateMonthDiff() {
    final startParts = _startMonth.split('-');
    final endParts = _endMonth.split('-');

    final startYear = int.parse(startParts[0]);
    final startMonth = int.parse(startParts[1]);
    final endYear = int.parse(endParts[0]);
    final endMonth = int.parse(endParts[1]);

    final totalMonths = (endYear - startYear) * 12 + (endMonth - startMonth);

    if (totalMonths < 0) {
      return '结束月份不能早于开始月份';
    }

    return '共 $totalMonths 个月';
  }
}

/// 月份选择器瓦片（用于范围选择）
class _MonthSelectorTile extends StatelessWidget {
  const _MonthSelectorTile({
    required this.label,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  final String label;
  final String selectedMonth;
  final ValueChanged<String> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _showMonthPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedMonth,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    // TODO: 实现月份选择器对话框
  }
}

/// 快速月份选择器
///
/// 提供常用的时间范围选项
class QuickMonthSelector extends StatelessWidget {
  const QuickMonthSelector({
    super.key,
    required this.onSelected,
    this.selectedMonth,
  });

  final ValueChanged<String> onSelected;
  final String? selectedMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final options = [
      ('本月', currentMonth),
      ('上月', _getLastMonth(now)),
      ('本年', '${now.year}-01'),
      ('去年', '${now.year - 1}-01'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedMonth == option.$2;
        return FilterChip(
          label: Text(option.$1),
          selected: isSelected,
          onSelected: (_) => onSelected(option.$2),
          selectedColor: colorScheme.primaryContainer,
          checkmarkColor: colorScheme.onPrimaryContainer,
        );
      }).toList(),
    );
  }

  String _getLastMonth(DateTime now) {
    final lastMonth = DateTime(now.year, now.month - 1);
    return '${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}';
  }
}

/// 月份格式化工具
class MonthFormatter {
  /// 将 DateTime 格式化为 YYYY-MM
  static String format(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// 将 YYYY-MM 解析为 DateTime
  static DateTime parse(String month) {
    final parts = month.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  /// 获取月份显示名称
  static String displayName(String month, {bool showYear = true}) {
    final date = parse(month);
    final monthNames = [
      '一月', '二月', '三月', '四月', '五月', '六月',
      '七月', '八月', '九月', '十月', '十一月', '十二月'
    ];

    if (showYear) {
      return '${date.year}年 ${monthNames[date.month - 1]}';
    }
    return monthNames[date.month - 1];
  }

  /// 获取上个月
  static String getPrevMonth(String month) {
    final date = parse(month);
    final prevMonth = DateTime(date.year, date.month - 1);
    return format(prevMonth);
  }

  /// 获取下个月
  static String getNextMonth(String month) {
    final date = parse(month);
    final nextMonth = DateTime(date.year, date.month + 1);
    return format(nextMonth);
  }

  /// 计算两个月份之间的月数差
  static int monthDiff(String start, String end) {
    final startDate = parse(start);
    final endDate = parse(end);
    return (endDate.year - startDate.year) * 12 + (endDate.month - startDate.month);
  }
}
