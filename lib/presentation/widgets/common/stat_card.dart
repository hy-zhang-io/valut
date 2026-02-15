import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'animated_amount.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';

/// 统计卡片类型
enum StatType {
  /// 收入
  income,

  /// 支出
  expense,

  /// 结余/余额
  balance,
}

/// 统计卡片组件
///
/// 显示收入/支出/结余的统计信息
class StatCard extends ConsumerWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.type,
    this.index = 0,
    this.animated = true,
    this.onTap,
  });

  final String title;
  final double amount;
  final StatType type;
  final int index;
  final bool animated;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 根据类型选择颜色
    final backgroundColor = _getBackgroundColor(colorScheme);
    final foregroundColor = _getForegroundColor(colorScheme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: foregroundColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),

            // 金额
            if (animated)
              AnimatedAmount(
                amount: amount,
                decimalPlaces: 2,
                prefix: type == StatType.expense ? '-' : '',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                _formatAmount(amount),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (type) {
      case StatType.income:
        return AppColors.success.withValues(alpha: 0.1);
      case StatType.expense:
        return AppColors.error.withValues(alpha: 0.1);
      case StatType.balance:
        return colorScheme.primaryContainer.withValues(alpha: 0.3);
    }
  }

  Color _getForegroundColor(ColorScheme colorScheme) {
    switch (type) {
      case StatType.income:
        return AppColors.success;
      case StatType.expense:
        return AppColors.error;
      case StatType.balance:
        return colorScheme.primary;
    }
  }

  String _formatAmount(double amount) {
    final prefix = type == StatType.expense ? '-' : '';
    return '$prefix${Formatters.formatCurrency(amount)}';
  }
}

/// 响应式统计卡片行
///
/// 根据屏幕宽度自动调整列数
class StatCardRow extends ConsumerWidget {
  const StatCardRow({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
    this.animated = true,
  });

  final double income;
  final double expense;
  final double balance;
  final bool animated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: '收入',
            amount: income,
            type: StatType.income,
            index: 0,
            animated: animated,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: '支出',
            amount: expense,
            type: StatType.expense,
            index: 1,
            animated: animated,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: '结余',
            amount: balance,
            type: StatType.balance,
            index: 2,
            animated: animated,
          ),
        ),
      ],
    );
  }
}

/// 月度统计卡片
///
/// 显示月度统计摘要
class MonthlyStatCard extends ConsumerWidget {
  const MonthlyStatCard({
    super.key,
    required this.month,
    required this.income,
    required this.expense,
    required this.balance,
    this.onTap,
  });

  final String month;
  final double income;
  final double expense;
  final double balance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 月份标签
            Text(
              month,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // 统计数据
            _StatRow(label: '收入', amount: income, type: StatType.income),
            const SizedBox(height: 12),
            _StatRow(label: '支出', amount: expense, type: StatType.expense),
            const SizedBox(height: 12),
            _StatRow(label: '结余', amount: balance, type: StatType.balance),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.amount,
    required this.type,
  });

  final String label;
  final double amount;
  final StatType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final color = switch (type) {
      StatType.income => AppColors.success,
      StatType.expense => AppColors.error,
      StatType.balance => colorScheme.primary,
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          Formatters.formatCurrency(amount),
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// 小型统计指示器
///
/// 用于在有限空间显示统计信息
class StatIndicator extends ConsumerWidget {
  const StatIndicator({
    super.key,
    required this.label,
    required this.value,
    required this.type,
    this.showIcon = true,
  });

  final String label;
  final String value;
  final StatType type;
  final bool showIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final color = switch (type) {
      StatType.income => AppColors.success,
      StatType.expense => AppColors.error,
      StatType.balance => colorScheme.primary,
    };

    final icon = switch (type) {
      StatType.income => Icons.arrow_upward,
      StatType.expense => Icons.arrow_downward,
      StatType.balance => Icons.account_balance_wallet,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
