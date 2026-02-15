import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/transaction/transaction_card.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/stagger_list.dart';
import '../../widgets/dashboard/month_selector.dart';
import '../home/add_transaction_bottom_sheet.dart';

/// Dashboard 页面
///
/// 应用首页，显示总资产、月份选择器、统计卡片和最近交易
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _selectedMonth = _getCurrentMonth();

  static String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  void _showAddTransactionSheet({required bool isExpense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取月度统计数据
    final monthStats = ref.watch(monthStatsProvider(_selectedMonth));
    final transactions = ref.watch(transactionsByMonthProvider(_selectedMonth));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题栏
              _buildHeader(context),

              const SizedBox(height: 24),

              // 月份选择器
              _buildMonthSelector(context),

              const SizedBox(height: 24),

              // 统计卡片
              _buildStatCards(context, monthStats),

              const SizedBox(height: 24),

              // 快速记账按钮
              _buildQuickActions(context),

              const SizedBox(height: 24),

              // 最近交易标题
              _buildTransactionsHeader(context),

              const SizedBox(height: 12),

              // 交易列表
              _buildTransactionList(context, transactions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surfaceContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VAULT',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '极致隐私离线记账',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // TODO: 打开设置页面
          },
          icon: Icon(
            Icons.settings_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Center(
      child: MonthSelector(
        selectedMonth: _selectedMonth,
        onMonthChanged: (month) {
          setState(() {
            _selectedMonth = month;
          });
        },
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, MonthStats stats) {
    return StatCardRow(
      income: stats.income,
      expense: stats.expense,
      balance: stats.balance,
      animated: true,
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            label: '记支出',
            icon: Icons.remove_circle_outline,
            color: AppColors.error,
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            onTap: () => _showAddTransactionSheet(isExpense: true),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickActionButton(
            label: '记收入',
            icon: Icons.add_circle_outline,
            color: AppColors.success,
            backgroundColor: AppColors.success.withValues(alpha: 0.1),
            onTap: () => _showAddTransactionSheet(isExpense: false),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '最近交易',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: 跳转到完整的交易列表页面
          },
          child: Text(
            '查看全部',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(BuildContext context, List transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    return StaggerListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: transactions
          .take(10)
          .map((transaction) => TransactionCard(
                transaction: transaction,
                onTap: () {
                  // TODO: 编辑交易
                },
              ))
          .toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无交易记录',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击上方按钮开始记账',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// 快速操作按钮
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
