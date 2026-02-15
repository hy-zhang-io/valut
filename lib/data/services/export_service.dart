import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/export_record.dart';
import '../models/transaction.dart';
import '../repositories/database_service.dart';
import '../../core/utils/import_logger.dart';

/// 导出结果
class ExportResult {
  final bool success;
  final List<int>? bytes;  // ZIP文件字节数据
  final String? fileName;  // 建议的文件名
  final String? password;
  final int recordCount;
  final String? error;

  ExportResult({
    required this.success,
    this.bytes,
    this.fileName,
    this.password,
    this.recordCount = 0,
    this.error,
  });
}

/// 导出服务
class ExportService {
  static final ExportService _instance = ExportService._internal();
  factory ExportService() => _instance;
  ExportService._internal();

  /// 生成6位随机数字密码
  String _generatePassword() {
    final random = Random.secure();
    final password = List.generate(6, (_) => random.nextInt(10)).join();
    return password;
  }

  /// 获取临时目录用于生成中间文件
  Future<Directory> _getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory('${tempDir.path}/export_temp');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }
    return exportDir;
  }

  /// 查询指定时间范围内的交易记录
  Future<List<Transaction>> _getTransactions(DateTime startDate, DateTime endDate) async {
    final db = DatabaseService.instance;

    // 设置时间范围：从开始日期的00:00:00到结束日期的23:59:59
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final transactions = await db.isar.transactions
        .filter()
        .dateBetween(start, end)
        .findAll();

    // 按日期降序排序
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  /// 获取分类名称映射
  Future<Map<int, String>> _getCategoryNameMap() async {
    final db = DatabaseService.instance;
    final categories = await db.isar.categorys.where().findAll();
    return {for (var c in categories) c.id: c.name};
  }

  /// 获取账户名称映射
  Future<Map<int, String>> _getAccountNameMap() async {
    final db = DatabaseService.instance;
    final accounts = await db.isar.accounts.where().findAll();
    return {for (var a in accounts) a.id: a.name};
  }

  /// 导出为CSV格式（返回字节数据）
  Future<List<int>> _exportToCsvBytes(
    List<Transaction> transactions,
    Map<int, String> categoryMap,
    Map<int, String> accountMap,
  ) async {
    // CSV表头
    final headers = [
      '交易单号',
      '交易日期',
      '类型',
      '金额',
      '分类',
      '账户',
      '交易对方',
      '商品说明',
      '收/付款方式',
      '交易状态',
      '备注',
      '数据来源',
    ];

    // 转换交易记录为CSV行
    final rows = transactions.map((tx) {
      String typeText;
      switch (tx.type) {
        case 0:
          typeText = '支出';
          break;
        case 1:
          typeText = '收入';
          break;
        case 2:
          typeText = '转账';
          break;
        default:
          typeText = '其他';
      }

      // 金额显示：支出显示正数（绝对值）
      final displayAmount = tx.amount.abs().toStringAsFixed(2);

      // 获取分类名称
      final categoryName = tx.categoryId != null
          ? (categoryMap[tx.categoryId!] ?? '未知分类')
          : '';

      // 获取账户名称
      final accountName = accountMap[tx.accountId] ?? '未知账户';

      // 交易单号后面加2个空格，防止Excel显示为科学计数法
      final transactionId = tx.externalTransactionId ?? '';
      final transactionIdWithSpaces = transactionId.isNotEmpty ? '$transactionId  ' : '';

      return [
        transactionIdWithSpaces,  // 交易单号（带空格防止科学计数法）
        DateFormat('yyyy-MM-dd HH:mm:ss').format(tx.date),
        typeText,
        displayAmount,
        categoryName,
        accountName,
        tx.counterparty ?? '',
        tx.productDescription ?? '',
        tx.paymentMethod ?? '',
        tx.transactionStatus ?? '',
        tx.note ?? '',
        tx.dataSource ?? '手动记账',
      ];
    }).toList();

    // 构建CSV内容
    final csvData = [headers, ...rows];
    final csvContent = const ListToCsvConverter().convert(csvData);

    // 使用GBK编码（兼容Excel中文）
    return gbk.encode(csvContent);
  }

  /// 导出为JSON格式（返回字节数据）
  Future<List<int>> _exportToJsonBytes(
    List<Transaction> transactions,
    Map<int, String> categoryMap,
    Map<int, String> accountMap,
  ) async {
    final data = {
      'exportInfo': {
        'exportTime': DateTime.now().toIso8601String(),
        'recordCount': transactions.length,
        'version': '2.0',  // 升级版本号
      },
      'transactions': transactions.map((tx) {
        final map = tx.toMap();
        // 添加分类和账户名称
        map['categoryName'] = tx.categoryId != null
            ? (categoryMap[tx.categoryId!] ?? '未知分类')
            : null;
        map['accountName'] = accountMap[tx.accountId] ?? '未知账户';
        // 金额显示为绝对值
        map['displayAmount'] = tx.amount.abs();
        return map;
      }).toList(),
    };

    final jsonContent = const JsonEncoder.withIndent('  ').convert(data);
    return utf8.encode(jsonContent);
  }

  /// 压缩并加密（返回ZIP字节数据）
  List<int> _compressAndEncryptBytes(
    List<int> sourceBytes,
    String fileName,
    String password,
  ) {
    // 创建ZIP归档
    final archive = Archive();
    final archiveFile = ArchiveFile(fileName, sourceBytes.length, sourceBytes);
    archive.addFile(archiveFile);

    // 使用密码加密ZIP
    final zipEncoder = ZipEncoder(password: password);
    return zipEncoder.encode(archive);
  }

  /// 执行导出（返回ZIP字节数据，由调用者保存）
  Future<ExportResult> export({
    required ExportFormat format,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      importLogger.info('========== 开始导出数据 ==========');
      importLogger.info('格式: ${format.name}');
      importLogger.info('时间范围: $startDate 至 $endDate');

      // 1. 查询数据
      final transactions = await _getTransactions(startDate, endDate);
      importLogger.info('查询到 ${transactions.length} 条记录');

      if (transactions.isEmpty) {
        return ExportResult(
          success: false,
          error: '指定时间范围内没有交易记录',
        );
      }

      // 2. 获取分类和账户名称映射
      final categoryMap = await _getCategoryNameMap();
      final accountMap = await _getAccountNameMap();

      // 调试日志：输出分类映射表和交易ID
      importLogger.info('分类映射表: $categoryMap');
      if (transactions.isNotEmpty) {
        importLogger.info('第一笔交易 - ID: ${transactions.first.id}, categoryId: ${transactions.first.categoryId}');
      }

      // 3. 生成文件名
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final formatName = format.name.toUpperCase();
      final baseFileName = 'vault_export_${formatName}_$timestamp';
      final extension = format == ExportFormat.csv ? 'csv' : 'json';

      // 4. 导出为指定格式的字节数据
      List<int> sourceBytes;
      if (format == ExportFormat.csv) {
        sourceBytes = await _exportToCsvBytes(transactions, categoryMap, accountMap);
      } else {
        sourceBytes = await _exportToJsonBytes(transactions, categoryMap, accountMap);
      }

      importLogger.info('已生成${format.name.toUpperCase()}数据');

      // 5. 生成密码并压缩加密
      final password = _generatePassword();
      final zipBytes = _compressAndEncryptBytes(
        sourceBytes,
        '$baseFileName.$extension',
        password,
      );

      importLogger.info('已生成加密ZIP，密码: $password');

      return ExportResult(
        success: true,
        bytes: zipBytes,
        fileName: '$baseFileName.zip',
        password: password,
        recordCount: transactions.length,
      );
    } catch (e, stackTrace) {
      importLogger.error('导出失败: $e');
      importLogger.error('堆栈: $stackTrace');
      return ExportResult(
        success: false,
        error: '导出失败: $e',
      );
    }
  }

  /// 清理临时文件
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await _getTempDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        importLogger.info('已清理临时文件');
      }
    } catch (e) {
      importLogger.error('清理临时文件失败: $e');
    }
  }
}
