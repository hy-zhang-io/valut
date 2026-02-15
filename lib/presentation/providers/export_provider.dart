import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/export_record.dart';
import '../../data/services/export_service.dart';
import 'database_provider.dart';

part 'export_provider.g.dart';

/// 导出记录状态
class ExportState {
  final bool isExporting;
  final String? error;
  final ExportRecord? lastExport;

  ExportState({
    this.isExporting = false,
    this.error,
    this.lastExport,
  });

  ExportState copyWith({
    bool? isExporting,
    String? error,
    ExportRecord? lastExport,
  }) {
    return ExportState(
      isExporting: isExporting ?? this.isExporting,
      error: error,
      lastExport: lastExport ?? this.lastExport,
    );
  }
}

/// 导出记录Provider
@riverpod
class ExportNotifier extends _$ExportNotifier {
  @override
  ExportState build() {
    return ExportState();
  }

  /// 执行导出（生成数据并让用户选择保存位置）
  Future<ExportRecord?> export({
    required ExportFormat format,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    state = state.copyWith(isExporting: true, error: null);

    try {
      final exportService = ExportService();
      final db = ref.read(databaseServiceProvider);

      // 1. 生成导出数据
      final result = await exportService.export(
        format: format,
        startDate: startDate,
        endDate: endDate,
      );

      if (!result.success || result.bytes == null) {
        state = state.copyWith(
          isExporting: false,
          error: result.error ?? '导出失败',
        );
        return null;
      }

      // 2. 让用户选择保存位置
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '保存导出文件',
        fileName: result.fileName,
      );

      if (outputPath == null) {
        // 用户取消了保存
        state = state.copyWith(
          isExporting: false,
          error: null,
        );
        return null;
      }

      // 3. 手动写入文件到用户选择的路径
      final file = File(outputPath);
      await file.writeAsBytes(result.bytes!);

      // 3. 创建导出记录（不保存文件路径）
      final record = ExportRecord(
        exportTime: DateTime.now(),
        format: format.name,
        startDate: startDate,
        endDate: endDate,
        password: result.password!,
        recordCount: result.recordCount,
      );

      // 4. 保存记录到数据库
      await db.isar.writeTxn(() async {
        await db.isar.exportRecords.put(record);
      });

      // 5. 清理过期记录
      await _cleanupExpiredRecords();

      // 6. 清理临时文件
      await exportService.cleanupTempFiles();

      state = state.copyWith(
        isExporting: false,
        lastExport: record,
      );

      return record;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        error: '导出失败: $e',
      );
      return null;
    }
  }

  /// 清理过期记录
  Future<void> _cleanupExpiredRecords() async {
    try {
      final db = ref.read(databaseServiceProvider);
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      await db.isar.writeTxn(() async {
        final expiredRecords = await db.isar.exportRecords
            .filter()
            .exportTimeLessThan(sevenDaysAgo)
            .findAll();

        for (final record in expiredRecords) {
          await db.isar.exportRecords.delete(record.id);
        }
      });
    } catch (e) {
      // 忽略清理错误
    }
  }

  /// 删除单条导出记录
  Future<void> deleteExportRecord(int id) async {
    try {
      final db = ref.read(databaseServiceProvider);

      await db.isar.writeTxn(() async {
        await db.isar.exportRecords.delete(id);
      });

      // 刷新导出记录列表
      ref.invalidate(recentExportRecordsProvider);
    } catch (e) {
      state = state.copyWith(error: '删除失败: $e');
    }
  }
}

/// 获取近7天导出记录
@riverpod
Future<List<ExportRecord>> recentExportRecords(RecentExportRecordsRef ref) async {
  final db = ref.watch(databaseServiceProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  final records = await db.isar.exportRecords
      .filter()
      .exportTimeGreaterThan(sevenDaysAgo)
      .sortByExportTimeDesc()
      .findAll();

  return records;
}

/// 获取导出记录数量
@riverpod
Future<int> exportRecordCount(ExportRecordCountRef ref) async {
  final db = ref.watch(databaseServiceProvider);
  final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

  final count = await db.isar.exportRecords
      .filter()
      .exportTimeGreaterThan(sevenDaysAgo)
      .count();

  return count;
}
