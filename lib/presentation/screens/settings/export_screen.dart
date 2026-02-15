import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/export_record.dart';
import '../../providers/export_provider.dart';

/// 数据导出页面
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  bool _exportAll = true;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final exportState = ref.watch(exportNotifierProvider);
    final recentRecordsAsync = ref.watch(recentExportRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('导出数据'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 导出格式选择
            _buildSectionTitle('导出格式'),
            const SizedBox(height: 12),
            _buildFormatSelector(),

            const SizedBox(height: 24),

            // 时间范围选择
            _buildSectionTitle('导出范围'),
            const SizedBox(height: 12),
            _buildRangeSelector(),

            if (!_exportAll) ...[
              const SizedBox(height: 16),
              _buildDateRangePicker(),
            ],

            const SizedBox(height: 32),

            // 导出按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: exportState.isExporting ? null : _handleExport,
                icon: exportState.isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(exportState.isExporting ? '导出中...' : '开始导出'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            if (exportState.error != null) ...[
              const SizedBox(height: 16),
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
                        exportState.error!,
                        style: TextStyle(color: AppTheme.expenseColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // 导出记录
            _buildSectionTitle('近7天导出记录'),
            const SizedBox(height: 12),
            _buildExportRecordsList(recentRecordsAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFormatSelector() {
    return Row(
      children: [
        Expanded(
          child: _FormatCard(
            title: 'CSV',
            subtitle: 'Excel兼容',
            icon: Icons.table_chart,
            isSelected: _selectedFormat == ExportFormat.csv,
            onTap: () => setState(() => _selectedFormat = ExportFormat.csv),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _FormatCard(
            title: 'JSON',
            subtitle: '数据备份',
            icon: Icons.code,
            isSelected: _selectedFormat == ExportFormat.json,
            onTap: () => setState(() => _selectedFormat = ExportFormat.json),
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSelector() {
    return Column(
      children: [
        RadioListTile<bool>(
          title: const Text('导出全部数据'),
          subtitle: const Text('导出所有历史交易记录'),
          value: true,
          groupValue: _exportAll,
          onChanged: (value) => setState(() => _exportAll = value!),
          contentPadding: EdgeInsets.zero,
        ),
        RadioListTile<bool>(
          title: const Text('选择时间范围'),
          subtitle: const Text('导出指定日期范围内的记录'),
          value: false,
          groupValue: _exportAll,
          onChanged: (value) => setState(() => _exportAll = value!),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  label: '开始日期',
                  date: _startDate,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.arrow_forward, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDatePicker(
                  label: '结束日期',
                  date: _endDate,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
          if (_startDate.isAfter(_endDate)) ...[
            const SizedBox(height: 8),
            Text(
              '开始日期不能晚于结束日期',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.expenseColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _handleExport() async {
    if (!_exportAll && _startDate.isAfter(_endDate)) {
      return;
    }

    // 确定导出范围
    final startDate = _exportAll
        ? DateTime(2000, 1, 1) // 导出全部时从很早的日期开始
        : _startDate;
    final endDate = _exportAll ? DateTime.now() : _endDate;

    final record = await ref.read(exportNotifierProvider.notifier).export(
      format: _selectedFormat,
      startDate: startDate,
      endDate: endDate,
    );

    if (record != null && mounted) {
      // 显示导出成功对话框
      _showExportSuccessDialog(record);
    }
  }

  void _showExportSuccessDialog(ExportRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('导出成功'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('成功导出 ${record.recordCount} 条记录'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        'ZIP文件密码',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.password,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: record.password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('密码已复制')),
                          );
                        },
                        icon: const Icon(Icons.copy),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '请妥善保管此密码，密码将在7天后自动删除。',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
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

  Widget _buildExportRecordsList(AsyncValue<List<ExportRecord>> asyncRecords) {
    return asyncRecords.when(
      data: (records) {
        if (records.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '暂无导出记录',
                    style: TextStyle(
                      color: AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: records.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) => _ExportRecordCard(
            record: records[index],
            onDelete: () => _confirmDelete(records[index]),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          '加载失败',
          style: TextStyle(color: AppTheme.onSurfaceVariant),
        ),
      ),
    );
  }

  void _confirmDelete(ExportRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除导出记录'),
        content: const Text('确定要删除这条导出记录吗？删除后将无法查看密码。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(exportNotifierProvider.notifier).deleteExportRecord(record.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.expenseColor,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 格式选择卡片
class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryColor : AppTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryColor : null,
              ),
            ),
            Text(
              subtitle,
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

/// 导出记录卡片
class _ExportRecordCard extends StatelessWidget {
  const _ExportRecordCard({
    required this.record,
    required this.onDelete,
  });

  final ExportRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = record.daysUntilExpire;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    record.format.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const Spacer(),
                if (daysLeft <= 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.expenseColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      daysLeft <= 0 ? '即将过期' : '剩1天',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.expenseColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              record.dateRangeText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${record.recordCount} 条记录 · ${record.exportTimeText}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '密码: ${record.password}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: record.password));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('密码已复制')),
                      );
                    },
                    icon: Icon(Icons.copy, size: 18, color: AppTheme.onSurfaceVariant),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                style: IconButton.styleFrom(
                  foregroundColor: AppTheme.expenseColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
