import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import 'source_badge.dart';

/// Transaction card widget for displaying transaction in list
class TransactionCard extends ConsumerWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final Transaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get category based on transaction categoryId
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: Row(
          children: [
            // 分类图标
            _buildIcon(context, colorScheme, category),

            const SizedBox(width: 12),

            // 详情
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (transaction.dataSource != null) ...[
                        const SizedBox(width: 8),
                        DataSourceBadge(source: transaction.dataSource),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 显示交易对方或备注
                  Text(
                    _getSubtitle(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 日期时间
                  Text(
                    _formatDateTime(transaction.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // 金额
            Text(
              Formatters.formatCurrency(transaction.amount),
              style: theme.textTheme.titleLarge?.copyWith(
                color: _getAmountColor(colorScheme),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(
    BuildContext context,
    ColorScheme colorScheme,
    Category? category,
  ) {
    final color = category != null
        ? CategoryColors.getColor(category.color)
        : CategoryColors.getColor(0);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_getIconData(category), color: color, size: 24),
    );
  }

  IconData _getIconData(Category? category) {
    if (category == null) return Icons.receipt_long;

    // Map icon code points to Material Icons
    switch (category.icon) {
      // New categories
      case 0xe8cc:
        return Icons.shopping_cart; // 日常花销
      case 0xe8af:
        return Icons.home; // 房租/还款
      case 0xe3ac:
        return Icons.shield; // 保费缴纳
      case 0xe405:
        return Icons.sports_esports; // 兴趣爱好
      case 0xe0b6:
        return Icons.child_care; // 孩子花费
      case 0xe7f4:
        return Icons.receipt_long; // 生活缴费
      case 0xe548:
        return Icons.directions_car; // 交通通勤
      case 0xe565:
        return Icons.medical_services; // 医疗支出
      case 0xe8d0:
        return Icons.pets; // 养宠物
      case 0xe8f0:
        return Icons.card_giftcard; // 人情送礼
      case 0xe145:
        return Icons.add; // 自定义
      case 0xe8b8:
        return Icons.more_horiz; // more_horiz (custom categories)

      // Old categories (for backward compatibility)
      case 0xe567:
        return Icons.restaurant;
      case 0xe569:
        return Icons.lunch_dining;
      case 0xe54d:
        return Icons.subway;
      case 0xe564:
        return Icons.shopping_bag;
      case 0xe568:
        return Icons.shopping_cart;
      case 0xe421:
        return Icons.sports_esports;
      case 0xe544:
        return Icons.home;
      case 0xe549:
        return Icons.water_drop;
      case 0xe531:
        return Icons.school;

      // Income
      case 0xe24f:
        return Icons.payments;
      case 0xe8dc:
        return Icons.redeem;
      case 0xe563:
        return Icons.show_chart;
      case 0xe23a:
        return Icons.work;

      default:
        return Icons.receipt_long;
    }
  }

  String _getCategoryName(Category? category) {
    if (transaction.isTransfer) {
      return TransactionType.getTypeLabel(transaction.type);
    }
    return category?.name ?? '未分类';
  }

  String _getSubtitle() {
    // 优先显示交易对方，其次是商品说明，最后是备注
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

  Color _getAmountColor(ColorScheme colorScheme) {
    if (transaction.isExpense) {
      return AppColors.error;
    } else if (transaction.isIncome) {
      return AppColors.success;
    }
    return colorScheme.onSurface;
  }
}
