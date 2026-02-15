import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/database_service.dart';
import '../../providers/transaction_provider.dart';
import 'category_mapping_screen.dart';
import 'export_screen.dart';

/// 设置页面 - 应用设置
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final transactions = ref.watch(transactionNotifierProvider);

    // 计算统计数据
    final totalRecords = transactions.length;
    final months = <String>{};
    for (final t in transactions) {
      months.add('${t.date.year}-${t.date.month}');
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // 标题栏
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '设置',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '管理应用设置和数据',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 统计卡片
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: totalRecords.toString(),
                      label: '总记录数',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      value: months.length.toString(),
                      label: '记账月数',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 24)),

          // 数据管理
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '数据管理',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 8)),

          // 导出数据
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsTile(
                icon: Icons.download,
                title: '导出数据',
                subtitle: '导出CSV或JSON备份，支持ZIP加密',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ExportScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 8)),

          // 分类映射管理
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsTile(
                icon: Icons.map,
                title: '分类映射管理',
                subtitle: '管理支付宝/微信分类对应关系',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CategoryMappingScreen(),
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 8)),

          // 清空数据
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsTile(
                icon: Icons.delete_outline,
                title: '清空数据',
                subtitle: '删除所有交易记录',
                isDestructive: true,
                onTap: () {
                  _showClearDataDialog(context, ref);
                },
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 24)),

          // 关于
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '关于',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 8)),

          // 关于应用
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsTile(
                icon: Icons.info_outline,
                title: '关于应用',
                subtitle: '版本 1.0.0',
                onTap: () {
                  _showAboutDialog(context);
                },
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const _ClearDataDialog(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '智能记账本',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          color: Colors.white,
        ),
      ),
      applicationLegalese: '© 2026 智能记账本\n极致隐私离线记账应用',
    );
  }
}

/// 统计卡片
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 清空数据对话框
class _ClearDataDialog extends ConsumerStatefulWidget {
  const _ClearDataDialog();

  @override
  ConsumerState<_ClearDataDialog> createState() => _ClearDataDialogState();
}

class _ClearDataDialogState extends ConsumerState<_ClearDataDialog> {
  final _textController = TextEditingController();
  bool _isConfirmed = false;
  bool _isCountingDown = false;
  int _countdown = 10;
  Timer? _timer;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final isConfirmed = _textController.text.trim() == '我确认删除数据';
    if (isConfirmed != _isConfirmed) {
      setState(() {
        _isConfirmed = isConfirmed;
      });
    }
  }

  void _startCountdown() {
    setState(() {
      _isCountingDown = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        _performDelete();
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  void _cancelDelete() {
    _timer?.cancel();
    Navigator.of(context).pop();
  }

  void _cancelCountdown() {
    _timer?.cancel();
    setState(() {
      _isCountingDown = false;
      _countdown = 10;
    });
  }

  Future<void> _performDelete() async {
    if (_isDeleting) return;
    
    setState(() {
      _isDeleting = true;
    });

    try {
      final db = DatabaseService.instance;
      await db.clearAll();
      
      // Refresh transaction provider
      ref.invalidate(transactionNotifierProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有数据已清空')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _isCountingDown = false;
          _countdown = 10;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('清空数据失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: AppTheme.expenseColor,
        size: 48,
      ),
      title: const Text('危险操作'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.expenseColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppTheme.expenseColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '此操作将永久删除所有交易记录、账户和分类数据，无法恢复！',
                    style: TextStyle(
                      color: AppTheme.expenseColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('请输入以下文字以确认删除：'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '我确认删除数据',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            enabled: !_isDeleting,
            decoration: InputDecoration(
              hintText: '请输入确认文字',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              errorText: _textController.text.isNotEmpty && !_isConfirmed
                  ? '输入的文字不匹配'
                  : null,
            ),
          ),
          if (_isConfirmed && !_isCountingDown && !_isDeleting) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _startCountdown,
                icon: const Icon(Icons.delete_forever),
                label: const Text('确认删除'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.expenseColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
          if (_isCountingDown && !_isDeleting) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.expenseColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: _countdown / 10,
                          color: AppTheme.expenseColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '$_countdown 秒后自动删除数据...',
                          style: TextStyle(
                            color: AppTheme.expenseColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (_isDeleting) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('正在删除数据...')),
          ],
        ],
      ),
      actions: [
        if (_isCountingDown && !_isDeleting)
          TextButton(
            onPressed: _cancelCountdown,
            child: const Text('取消倒计时'),
          )
        else
          TextButton(
            onPressed: _isDeleting ? null : _cancelDelete,
            child: const Text('取消删除'),
          ),
      ],
    );
  }
}

/// 设置项
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? AppTheme.expenseColor : AppTheme.onSurface;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppTheme.expenseColor.withValues(alpha: 0.15)
                      : AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
