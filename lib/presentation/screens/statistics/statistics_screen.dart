import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';

import '../../../data/models/category.dart';

/// 统计页面 - 收支分析
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  DateTime _selectedMonth = DateTime.now();

  String get _monthTitle {
    return '${_selectedMonth.year}年${_selectedMonth.month}月';
  }

  String get _monthKey {
    return '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
  }

  void _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = ref.watch(transactionsByMonthProvider(_monthKey));

    // 计算统计数据
    var income = 0.0;
    var expense = 0.0;
    final categoryStats = <int, double>{};

    for (final t in transactions) {
      if (t.type == AppConstants.transactionTypeIncome) {
        income += t.amount;
      } else if (t.type == AppConstants.transactionTypeExpense) {
        expense += t.amount;
        if (t.categoryId != null) {
          categoryStats[t.categoryId!] = (categoryStats[t.categoryId!] ?? 0) + t.amount;
        }
      }
    }

    // 排序分类统计
    final sortedCategories = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // 标题栏
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '收支统计',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: _selectMonth,
                    child: Text(_monthTitle),
                  ),
                ],
              ),
            ),
          ),

          // 总收支卡片
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: '总收入',
                      amount: income,
                      color: AppTheme.incomeColor,
                      icon: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      label: '总支出',
                      amount: expense,
                      color: AppTheme.expenseColor,
                      icon: Icons.trending_down,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 24)),

          // 支出分类标题
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Icon(Icons.pie_chart_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '支出分类',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 16)),

          // 分类统计列表
          sortedCategories.isEmpty
              ? SliverToBoxAdapter(
                  child: _buildEmptyCategoryState(theme),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: sortedCategories.length,
                    itemBuilder: (context, index) {
                      final entry = sortedCategories[index];
                      final percentage = expense > 0 ? (entry.value / expense * 100).toDouble() : 0.0;
                      return _CategoryStatItem(
                        categoryId: entry.key,
                        amount: entry.value,
                        percentage: percentage,
                        totalAmount: expense,
                      );
                    },
                  ),
                ),

          const SliverPadding(padding: EdgeInsets.only(top: 32)),

          // 收支趋势标题
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Icon(Icons.bar_chart, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '收支趋势',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 16)),

          // 趋势图表占位
          SliverToBoxAdapter(
            child: _buildTrendChart(theme),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoryState(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 48,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无支出数据',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无趋势数据',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 汇总卡片
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '¥${amount.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 分类统计项
class _CategoryStatItem extends ConsumerWidget {
  const _CategoryStatItem({
    required this.categoryId,
    required this.amount,
    required this.percentage,
    required this.totalAmount,
  });

  final int categoryId;
  final double amount;
  final double percentage;
  final double totalAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final category = ref.watch(categoryByIdProvider(categoryId));
    final categoryColor = category != null
        ? Color(Category.categoryColors[category.color])
        : AppTheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    IconData(
                      category?.icon ?? Icons.category.codePoint,
                      fontFamily: 'MaterialIcons',
                    ),
                    size: 20,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category?.name ?? '未分类',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '¥${amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: totalAmount > 0 ? amount / totalAmount : 0.0,
                backgroundColor: AppTheme.surfaceContainer,
                valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
