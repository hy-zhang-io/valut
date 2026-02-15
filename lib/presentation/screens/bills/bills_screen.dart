import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/transaction_provider.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../home/add_transaction_sheet.dart';
import '../../widgets/transaction/source_badge.dart';

/// 账单页面 - 交易明细列表
class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  DateTime _selectedMonth = DateTime.now();
  final _searchController = TextEditingController();

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

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(
        isExpense: true,
        onSaved: () {
          ref.invalidate(transactionsByMonthProvider(_monthKey));
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = ref.watch(transactionsByMonthProvider(_monthKey));

    // 计算月度统计
    var income = 0.0;
    var expense = 0.0;
    for (final t in transactions) {
      if (t.type == AppConstants.transactionTypeIncome) {
        income += t.amount;
      } else if (t.type == AppConstants.transactionTypeExpense) {
        expense += t.amount;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionSheet,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
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
                      '账单明细',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 月份选择器和统计
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                _monthTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '收 ${income.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.incomeColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '支 ${expense.toStringAsFixed(2)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppTheme.expenseColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(top: 16)),

            // 搜索框
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '搜索交易记录...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
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
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        return _TransactionItem(
                          transaction: transactions[index],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.receipt,
              size: 40,
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '暂无交易记录',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮开始记账',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
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
    
    // 获取分类信息
    Category? category;
    if (transaction.categoryId != null) {
      final categories = transaction.isExpense
          ? Category.builtInExpenseCategories()
          : Category.builtInIncomeCategories();
      category = categories.cast<Category?>().firstWhere(
        (c) => c?.id == transaction.categoryId,
        orElse: () => null,
      );
    }

    final isExpense = transaction.type == AppConstants.transactionTypeExpense;
    final color = isExpense ? AppTheme.expenseColor : AppTheme.incomeColor;
    final sign = isExpense ? '-' : '+';
    
    // 获取分类颜色
    final categoryColor = category != null
        ? Color(Category.categoryColors[category.color % Category.categoryColors.length])
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
                  _getIconData(category),
                  color: categoryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 分类名称和数据来源
                    Row(
                      children: [
                        Text(
                          _getCategoryName(category),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (transaction.dataSource != null) ...[
                          const SizedBox(width: 8),
                          DataSourceBadge(source: transaction.dataSource),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 交易对方/商品说明
                    Text(
                      _getSubtitle(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // 日期时间 - 显示CSV中的交易日期时间
                    Text(
                      _formatDateTime(transaction.date),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
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

  IconData _getIconData(Category? category) {
    if (category == null) return Icons.receipt_long;

    switch (category.icon) {
      case 0xe8cc:
        return Icons.shopping_cart;
      case 0xe8af:
        return Icons.home;
      case 0xe3ac:
        return Icons.shield;
      case 0xe405:
        return Icons.sports_esports;
      case 0xe0b6:
        return Icons.child_care;
      case 0xe7f4:
        return Icons.receipt_long;
      case 0xe548:
        return Icons.directions_car;
      case 0xe565:
        return Icons.medical_services;
      case 0xe8d0:
        return Icons.pets;
      case 0xe8f0:
        return Icons.card_giftcard;
      case 0xe145:
        return Icons.add;
      case 0xe8b8:
        return Icons.more_horiz;
      case 0xe24f:
        return Icons.payments;
      case 0xe8dc:
        return Icons.redeem;
      case 0xe23a:
        return Icons.work;
      default:
        return Icons.receipt_long;
    }
  }

  String _getCategoryName(Category? category) {
    if (transaction.isTransfer) {
      return '转账';
    }
    return category?.name ?? '未分类';
  }

  /// 格式化日期时间显示
  /// - 如果是今天，显示"今天 HH:mm"
  /// - 如果是昨天，显示"昨天 HH:mm"
  /// - 如果是今年，显示"M月D日 HH:mm"
  /// - 其他情况，显示"YYYY-MM-DD HH:mm"
  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    if (dateDay == today) {
      return '今天 $timeStr';
    } else if (dateDay == yesterday) {
      return '昨天 $timeStr';
    } else if (date.year == now.year) {
      return '${date.month}月${date.day}日 $timeStr';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} $timeStr';
    }
  }

  String _getSubtitle() {
    if (transaction.counterparty != null && transaction.counterparty!.isNotEmpty) {
      return transaction.counterparty!;
    }
    if (transaction.productDescription != null && transaction.productDescription!.isNotEmpty) {
      return transaction.productDescription!;
    }
    if (transaction.note != null && transaction.note!.isNotEmpty) {
      return transaction.note!;
    }
    return '';
  }
}
