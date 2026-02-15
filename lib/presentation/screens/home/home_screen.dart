import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import 'add_transaction_sheet.dart';

/// 首页 - 概览统计
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _selectedMonth = DateTime.now();

  String get _monthTitle {
    return '${_selectedMonth.year}年${_selectedMonth.month}月';
  }

  String get _monthKey {
    return '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (_selectedMonth.year == DateTime.now().year &&
        _selectedMonth.month == DateTime.now().month) {
      return;
    }
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _showAddTransactionSheet({bool isExpense = true}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(
        isExpense: isExpense,
        onSaved: () {
          ref.invalidate(transactionsByMonthProvider(_monthKey));
          ref.invalidate(monthStatsProvider(_monthKey));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = ref.watch(transactionsByMonthProvider(_monthKey));

    // 计算统计数据
    // 金额统一存储为正数，通过 type 字段区分收支
    var income = 0.0;
    var expense = 0.0;
    for (final t in transactions) {
      if (t.type == AppConstants.transactionTypeIncome) {
        income += t.amount;
      } else if (t.type == AppConstants.transactionTypeExpense) {
        expense += t.amount;
      }
    }
    // 结余 = 收入 - 支出
    final balance = income - expense;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // 月份选择器
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: const Icon(Icons.chevron_left),
                      iconSize: 20,
                    ),
                    Text(
                      _monthTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(Icons.chevron_right),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 24)),

          // 统计卡片
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: '收入',
                      amount: income,
                      color: AppTheme.incomeColor,
                      icon: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: '支出',
                      amount: expense,
                      color: AppTheme.expenseColor,
                      icon: Icons.trending_down,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: '结余',
                      amount: balance,
                      color: AppTheme.primaryColor,
                      icon: Icons.account_balance_wallet,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 24)),

          // 操作按钮
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showAddTransactionSheet(isExpense: true),
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('记支出'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.expenseColor.withValues(alpha: 0.2),
                        foregroundColor: AppTheme.expenseColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showAddTransactionSheet(isExpense: false),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('记收入'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.incomeColor.withValues(alpha: 0.2),
                        foregroundColor: AppTheme.incomeColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 32)),

          // 最近交易标题
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '最近交易',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (transactions.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // 查看全部
                      },
                      child: const Text('查看全部'),
                    ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 16)),

          // 交易列表
          transactions.isEmpty
              ? SliverFillRemaining(
                  child: _buildEmptyState(theme),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList.builder(
                    itemCount: transactions.length.clamp(0, 10),
                    itemBuilder: (context, index) {
                      return _TransactionItem(
                        transaction: transactions[index],
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无交易记录',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击下方按钮开始记账',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 统计卡片
class _StatCard extends StatelessWidget {
  const _StatCard({
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
                style: theme.textTheme.titleLarge?.copyWith(
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

/// 交易项
class _TransactionItem extends ConsumerWidget {
  const _TransactionItem({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final category = ref.watch(categoryByIdProvider(transaction.categoryId));

    final isExpense = transaction.type == AppConstants.transactionTypeExpense;
    final color = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;
    final sign = isExpense ? '-' : '+';
    final categoryColor = category != null
        ? Color(Category.categoryColors[category.color])
        : AppTheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // 编辑交易
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 分类图标
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  IconData(
                    category?.icon ?? Icons.category.codePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 16),
              // 标题和备注
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
                    if (transaction.note?.isNotEmpty ?? false)
                      Text(
                        transaction.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // 金额
              Text(
                '$sign¥${transaction.amount.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
