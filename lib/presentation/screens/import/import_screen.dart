import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/import_logger.dart';
import '../../../data/services/vault_import_service.dart';
import '../../providers/import/import_notifier.dart';

/// 导入页面 - 导入外部账单
class ImportScreen extends ConsumerWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                    '导入账单',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '快速导入支付宝、微信账单，自动识别分类',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 支付宝导入
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ImportCard(
                title: '支付宝账单',
                subtitle: '导入支付宝CSV格式的账单文件',
                icon: Icons.grid_view,
                iconColor: const Color(0xFF1677FF),
                primaryButton: '导入账单',
                secondaryButton: '下载模板',
                onPrimaryPressed: () => _importAlipay(context, ref),
                onSecondaryPressed: () {
                  _showSnackbar(context, '模板功能开发中...');
                },
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 16)),

          // 微信导入
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ImportCard(
                title: '微信账单',
                subtitle: '导入微信CSV格式的账单文件',
                icon: Icons.chat_bubble,
                iconColor: const Color(0xFF07C160),
                primaryButton: '导入账单',
                secondaryButton: '下载模板',
                onPrimaryPressed: () {
                  _showSnackbar(context, '微信导入功能开发中...');
                },
                onSecondaryPressed: () {
                  _showSnackbar(context, '模板功能开发中...');
                },
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 16)),

          // Vault数据导入
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ImportCard(
                title: 'Vault数据迁移',
                subtitle: '导入Vault导出的加密ZIP备份文件',
                icon: Icons.folder_zip,
                iconColor: AppTheme.primaryColor,
                primaryButton: '导入ZIP',
                secondaryButton: '查看说明',
                onPrimaryPressed: () => _importVaultZip(context, ref),
                onSecondaryPressed: () {
                  _showVaultImportInfo(context);
                },
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(top: 24)),

          // 导入说明
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.help_outline,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '导入说明',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoItem(
                        icon: Icons.check_circle,
                        title: '支持格式',
                        subtitle: 'CSV格式（支付宝/微信）、加密ZIP（Vault备份）',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        icon: Icons.check_circle,
                        title: '自动分类',
                        subtitle: '系统会根据交易内容自动识别分类',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        icon: Icons.check_circle,
                        title: '数据安全',
                        subtitle: '所有数据仅在本地处理，不会上传到服务器',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoItem(
                        icon: Icons.info,
                        title: '导入提示',
                        subtitle: '支付宝账单为GBK编码，已自动适配',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// 显示Vault导入说明
  void _showVaultImportInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vault数据迁移说明'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. 在设置中导出数据为ZIP格式'),
            SizedBox(height: 8),
            Text('2. 导出时会生成6位数字密码'),
            SizedBox(height: 8),
            Text('3. 在此页面选择ZIP文件并输入密码'),
            SizedBox(height: 8),
            Text('4. 系统会自动解压并导入数据'),
            SizedBox(height: 16),
            Text(
              '注意：导入时会根据分类名称自动匹配，如果分类不存在则使用"自定义"分类。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }

  /// 导入Vault ZIP文件
  Future<void> _importVaultZip(BuildContext context, WidgetRef ref) async {
    try {
      // 1. 选择ZIP文件
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        if (context.mounted) {
          _showSnackbar(context, '无法获取文件路径');
        }
        return;
      }

      // 2. 弹出密码输入对话框
      if (!context.mounted) return;
      final password = await _showPasswordDialog(context);
      if (password == null || password.length != 6) {
        if (context.mounted) {
          _showSnackbar(context, '请输入6位密码');
        }
        return;
      }

      // 3. 显示加载对话框
      if (!context.mounted) return;
      _showLoadingDialog(context);

      // 4. 执行导入
      final importService = VaultImportService();
      final importResult = await importService.importFromZip(
        zipPath: filePath,
        password: password,
      );

      // 5. 关闭加载对话框并显示结果
      if (context.mounted) {
        Navigator.of(context).pop();
        _showVaultImportResult(context, importResult);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showSnackbar(context, '导入失败: $e');
      }
    }
  }

  /// 显示密码输入对话框
  Future<String?> _showPasswordDialog(BuildContext context) async {
    final controller = TextEditingController();
    String? password;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入ZIP密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入导出时生成的6位数字密码'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '000000',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              password = controller.text;
              Navigator.of(context).pop();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );

    return password;
  }

  /// 显示加载对话框
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('正在导入...'),
          ],
        ),
      ),
    );
  }

  /// 显示Vault导入结果
  void _showVaultImportResult(BuildContext context, VaultImportResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          result.success ? Icons.check_circle : Icons.error,
          color: result.success ? Colors.green : Colors.red,
          size: 48,
        ),
        title: Text(result.success ? '导入完成' : '导入失败'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.success) ...[
              _buildResultRow(Icons.check_circle, Colors.green,
                  '成功导入', '${result.successCount} 条'),
              if (result.duplicateCount > 0)
                _buildResultRow(Icons.content_copy, Colors.orange,
                    '重复跳过', '${result.duplicateCount} 条'),
              if (result.errorCount > 0)
                _buildResultRow(Icons.error, Colors.red,
                    '导入失败', '${result.errorCount} 条'),
            ] else ...[
              Text('错误信息: ${result.error}'),
            ],
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// Import Alipay CSV file
  Future<void> _importAlipay(BuildContext context, WidgetRef ref) async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        if (context.mounted) {
          _showSnackbar(context, '无法获取文件路径');
        }
        return;
      }

      // Show progress dialog
      if (context.mounted) {
        _showProgressDialog(context, ref);
      }

      // Start import
      await ref.read(alipayImportNotifierProvider.notifier).import(filePath);

      // Show result after import completes
      if (context.mounted) {
        final state = ref.read(alipayImportNotifierProvider);

        // Close progress dialog
        Navigator.of(context).pop();

        // Show result dialog
        _showResultDialog(context, ref, state);
      }
    } catch (e) {
      if (context.mounted) {
        // Close any open dialogs
        Navigator.of(context).pop();
        _showSnackbar(context, '导入失败: $e');
      }
    }
  }

  /// Show progress dialog with progress bar
  void _showProgressDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(alipayImportNotifierProvider);

          return WillPopScope(
            onWillPop: () async => false, // Prevent back button
            child: AlertDialog(
              title: const Text('正在导入'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: state.progress / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        state.stage == ImportStage.error
                            ? Colors.red
                            : const Color(0xFF1677FF),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Progress percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.stageMessage,
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '${state.progress}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  // Show current/total when importing
                  if (state.isImporting && state.total > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '已处理: ${state.currentRow} / ${state.total} 条',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],

                  // Error message
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Show import result dialog
  void _showResultDialog(BuildContext context, WidgetRef ref, ImportState state) {
    final isSuccess = state.errorMessage == null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? Colors.green : Colors.red,
          size: 48,
        ),
        title: Text(isSuccess ? '导入完成' : '导入失败'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isSuccess) ...[
              _buildResultRow(Icons.check_circle, Colors.green,
                  '成功导入', '${state.successCount} 条'),
              if (state.duplicateCount > 0)
                _buildResultRow(Icons.content_copy, Colors.orange,
                    '重复跳过', '${state.duplicateCount} 条'),
              if (state.errorCount > 0)
                _buildResultRow(Icons.error, Colors.red,
                    '导入失败', '${state.errorCount} 条'),
            ] else ...[
              Text('错误信息: ${state.errorMessage}'),
            ],
            const SizedBox(height: 12),
            if (state.logFilePath != null)
              Text(
                '日志文件: ${state.logFilePath}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        actions: [
          if (state.logFilePath != null)
            TextButton.icon(
              onPressed: () {
                _showLogDialog(context);
              },
              icon: const Icon(Icons.description, size: 18),
              label: const Text('查看日志'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear state after closing
              ref.read(alipayImportNotifierProvider.notifier).clearPreview();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// Show log dialog
  void _showLogDialog(BuildContext context) {
    final logs = importLogger.logsAsString;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 800),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.description),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '导入日志',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: logs.isEmpty
                    ? const Center(child: Text('暂无日志'))
                    : SingleChildScrollView(
                        child: SelectableText(
                          logs,
                          style: const TextStyle(
                            fontFamily: 'Consolas',
                            fontSize: 12,
                          ),
                        ),
                      ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Copy to clipboard
                      final data = ClipboardData(text: logs);
                      Clipboard.setData(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('日志已复制到剪贴板')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('复制'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(IconData icon, Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 导入卡片
class _ImportCard extends StatelessWidget {
  const _ImportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.primaryButton,
    required this.secondaryButton,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String primaryButton;
  final String secondaryButton;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onSecondaryPressed,
                    icon: const Icon(Icons.help_outline, size: 18),
                    label: Text(secondaryButton),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onPrimaryPressed,
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(primaryButton),
                    style: FilledButton.styleFrom(
                      backgroundColor: iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
