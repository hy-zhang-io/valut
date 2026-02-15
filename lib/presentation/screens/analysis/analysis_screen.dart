import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';

/// Analysis screen - View statistics and reports
class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final monthExpenses = ref.watch(monthExpensesProvider);
    final monthIncome = ref.watch(monthIncomeProvider);
    final monthTransactions = ref.watch(monthTransactionsProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '分析',
                  style: theme.textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '查看您的收支统计和趋势',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: monthTransactions.isEmpty
                ? _buildEmptyState(context, colorScheme)
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Month Summary Cards
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: '本月支出',
                              amount: monthExpenses,
                              isExpense: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: '本月收入',
                              amount: monthIncome,
                              isExpense: false,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Net Balance Card
                      _NetBalanceCard(
                        income: monthIncome,
                        expenses: monthExpenses,
                      ),

                      const SizedBox(height: 24),

                      // Category Breakdown
                      _CategoryBreakdownSection(
                        transactions: monthTransactions,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无本月数据',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Summary card for expenses/income
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.isExpense,
  });

  final String title;
  final double amount;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isExpense
            ? colorScheme.errorContainer.withValues(alpha: 0.3)
            : colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCompactCurrency(amount),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isExpense ? colorScheme.error : colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Net balance card
class _NetBalanceCard extends StatelessWidget {
  const _NetBalanceCard({
    required this.income,
    required this.expenses,
  });

  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final net = income - expenses;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: net >= 0
              ? [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ]
              : [
                  colorScheme.error,
                  colorScheme.error.withValues(alpha: 0.8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本月结余',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCompactCurrency(net),
            style: theme.textTheme.displayMedium?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                context,
                '收入',
                Formatters.formatCompactCurrency(income),
                colorScheme.onPrimary,
              ),
              const SizedBox(width: 24),
              Container(
                width: 1,
                height: 24,
                color: colorScheme.onPrimary.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                context,
                '支出',
                Formatters.formatCompactCurrency(expenses),
                colorScheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: 0.8),
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

/// Category breakdown section
class _CategoryBreakdownSection extends ConsumerWidget {
  const _CategoryBreakdownSection({required this.transactions});

  final List transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Group transactions by category
    final categoryTotals = <int, double>{};
    for (final transaction in transactions) {
      if (transaction.categoryId != null && transaction.isExpense) {
        categoryTotals[transaction.categoryId!] =
            (categoryTotals[transaction.categoryId!] ?? 0) +
                transaction.absoluteAmount;
      }
    }

    if (categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by amount
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = categoryTotals.values.fold<double>(0, (sum, amount) => sum + amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            '支出分类',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: sortedEntries.map((entry) {
              final percentage = total > 0 ? entry.value / total * 100 : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CategoryItem(
                  categoryId: entry.key,
                  amount: entry.value.toDouble(),
                  percentage: percentage,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Category item with progress bar
class _CategoryItem extends ConsumerWidget {
  const _CategoryItem({
    required this.categoryId,
    required this.amount,
    required this.percentage,
  });

  final int categoryId;
  final double amount;
  final double percentage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = ref.watch(expenseCategoriesProvider);
    final category = categories.where((c) => c.id == categoryId).firstOrNull;

    return Column(
      children: [
        Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.receipt_long,
                color: colorScheme.primary,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            // Name and amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category?.name ?? '未分类',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(amount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Percentage
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
