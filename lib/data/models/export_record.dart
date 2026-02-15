import 'package:isar/isar.dart';

part 'export_record.g.dart';

/// 导出格式类型
enum ExportFormat {
  csv,
  json,
}

/// 导出记录实体
/// 保存近7天的导出信息，用于用户查看历史导出记录和密码
@collection
class ExportRecord {
  ExportRecord({
    this.id = Isar.autoIncrement,
    required this.exportTime,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.password,
    this.filePath,
    this.recordCount = 0,
  });

  /// 唯一标识
  final Id id;

  /// 导出时间
  final DateTime exportTime;

  /// 导出格式: csv 或 json
  final String format;

  /// 导出数据开始日期
  final DateTime startDate;

  /// 导出数据结束日期
  final DateTime endDate;

  /// ZIP文件密码（6位数字）
  final String password;

  /// 导出文件路径
  final String? filePath;

  /// 导出记录数量
  final int recordCount;

  /// 获取导出格式枚举（非持久化字段）
  @ignore
  ExportFormat get exportFormat {
    switch (format.toLowerCase()) {
      case 'csv':
        return ExportFormat.csv;
      case 'json':
        return ExportFormat.json;
      default:
        return ExportFormat.csv;
    }
  }

  /// 格式化时间范围显示（非持久化）
  @ignore
  String get dateRangeText {
    final start = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final end = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    if (start == end) {
      return start;
    }
    return '$start 至 $end';
  }

  /// 格式化导出时间显示（非持久化）
  @ignore
  String get exportTimeText {
    return '${exportTime.year}-${exportTime.month.toString().padLeft(2, '0')}-${exportTime.day.toString().padLeft(2, '0')} '
        '${exportTime.hour.toString().padLeft(2, '0')}:${exportTime.minute.toString().padLeft(2, '0')}';
  }

  /// 检查记录是否已过期（超过7天）（非持久化）
  @ignore
  bool get isExpired {
    final now = DateTime.now();
    final expireTime = exportTime.add(const Duration(days: 7));
    return now.isAfter(expireTime);
  }

  /// 获取距离过期还剩的天数（非持久化）
  @ignore
  int get daysUntilExpire {
    final now = DateTime.now();
    final expireTime = exportTime.add(const Duration(days: 7));
    final diff = expireTime.difference(now);
    return diff.inDays;
  }
}
