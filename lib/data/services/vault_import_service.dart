import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:fast_gbk/fast_gbk.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../repositories/database_service.dart';
import '../../core/utils/import_logger.dart';

/// Vault导入结果
class VaultImportResult {
  final bool success;
  final int successCount;
  final int duplicateCount;
  final int errorCount;
  final String? error;
  final List<String> errors;

  VaultImportResult({
    required this.success,
    this.successCount = 0,
    this.duplicateCount = 0,
    this.errorCount = 0,
    this.error,
    this.errors = const [],
  });
}

/// Vault数据导入服务
/// 用于导入Vault应用导出的ZIP文件
class VaultImportService {
  static final VaultImportService _instance = VaultImportService._internal();
  factory VaultImportService() => _instance;
  VaultImportService._internal();

  /// 解压ZIP文件并导入数据
  Future<VaultImportResult> importFromZip({
    required String zipPath,
    required String password,
  }) async {
    try {
      importLogger.info('========== 开始导入Vault数据 ==========');
      importLogger.info('ZIP文件: $zipPath');

      // 1. 读取ZIP文件
      final zipFile = File(zipPath);
      if (!await zipFile.exists()) {
        return VaultImportResult(
          success: false,
          error: '文件不存在',
        );
      }

      final zipBytes = await zipFile.readAsBytes();

      // 2. 解压ZIP文件
      final archive = await _decodeZip(zipBytes, password);
      if (archive == null) {
        return VaultImportResult(
          success: false,
          error: '密码错误或文件损坏',
        );
      }

      // 3. 查找CSV或JSON文件
      ArchiveFile? dataFile;
      for (final file in archive.files) {
        if (file.name.endsWith('.csv') || file.name.endsWith('.json')) {
          dataFile = file;
          break;
        }
      }

      if (dataFile == null) {
        return VaultImportResult(
          success: false,
          error: 'ZIP中没有找到CSV或JSON文件',
        );
      }

      importLogger.info('找到数据文件: ${dataFile.name}');

      // 4. 解析并导入数据
      if (dataFile.name.endsWith('.csv')) {
        return await _importFromCsv(dataFile.content);
      } else {
        return await _importFromJson(dataFile.content);
      }
    } catch (e, stackTrace) {
      importLogger.error('导入失败: $e');
      importLogger.error('堆栈: $stackTrace');
      return VaultImportResult(
        success: false,
        error: '导入失败: $e',
      );
    }
  }

  /// 解压ZIP文件
  Future<Archive?> _decodeZip(List<int> bytes, String password) async {
    try {
      final zipDecoder = ZipDecoder();
      return zipDecoder.decodeBytes(bytes, password: password);
    } catch (e) {
      importLogger.error('ZIP解压失败: $e');
      return null;
    }
  }

  /// 从CSV导入
  Future<VaultImportResult> _importFromCsv(List<int> csvBytes) async {
    try {
      // 尝试UTF-8解码，失败则使用GBK
      String csvContent;
      try {
        csvContent = utf8.decode(csvBytes);
      } catch (_) {
        csvContent = gbk.decode(csvBytes);
      }

      // 解析CSV
      final rows = const CsvToListConverter().convert(csvContent);
      if (rows.isEmpty) {
        return VaultImportResult(
          success: false,
          error: 'CSV文件为空',
        );
      }

      // 获取表头
      final headers = rows.first.cast<String>();
      final headerMap = <String, int>{};
      for (var i = 0; i < headers.length; i++) {
        headerMap[headers[i].trim()] = i;
      }

      importLogger.info('CSV表头: $headers');

      // 获取数据库和映射
      final db = DatabaseService.instance;
      final categoryMap = await _getCategoryMap(db);
      final accountMap = await _getAccountMap(db);

      int successCount = 0;
      int duplicateCount = 0;
      int errorCount = 0;
      final errors = <String>[];

      // 处理每一行数据
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        try {
          final result = _parseCsvRow(
            row,
            headerMap,
            categoryMap,
            accountMap,
          );

          if (result != null) {
            final (transaction, originalId) = result;

            // 检查是否重复（基于原始ID生成的外部ID）
            final isDuplicate = await _checkDuplicate(db, transaction);

            if (isDuplicate) {
              duplicateCount++;
              importLogger.info('跳过重复记录: 原ID=$originalId');
            } else {
              await db.isar.writeTxn(() async {
                await db.isar.transactions.put(transaction);
              });
              successCount++;
            }
          }
        } catch (e) {
          errorCount++;
          errors.add('第${i + 1}行: $e');
          importLogger.error('第${i + 1}行解析失败: $e');
        }
      }

      importLogger.info('导入完成: 成功$successCount, 重复$duplicateCount, 失败$errorCount');

      return VaultImportResult(
        success: true,
        successCount: successCount,
        duplicateCount: duplicateCount,
        errorCount: errorCount,
        errors: errors,
      );
    } catch (e) {
      return VaultImportResult(
        success: false,
        error: 'CSV解析失败: $e',
      );
    }
  }

  /// 从JSON导入
  Future<VaultImportResult> _importFromJson(List<int> jsonBytes) async {
    try {
      final jsonContent = utf8.decode(jsonBytes);
      final data = jsonDecode(jsonContent) as Map<String, dynamic>;

      final transactionsData = data['transactions'] as List<dynamic>?;
      if (transactionsData == null || transactionsData.isEmpty) {
        return VaultImportResult(
          success: false,
          error: 'JSON文件中没有交易数据',
        );
      }

      final db = DatabaseService.instance;
      final categoryMap = await _getCategoryMap(db);
      final accountMap = await _getAccountMap(db);

      int successCount = 0;
      int duplicateCount = 0;
      int errorCount = 0;
      final errors = <String>[];

      for (var i = 0; i < transactionsData.length; i++) {
        try {
          final txData = transactionsData[i] as Map<String, dynamic>;
          final result = _parseJsonTransaction(
            txData,
            categoryMap,
            accountMap,
          );

          if (result != null) {
            final (transaction, _) = result;

            final isDuplicate = await _checkDuplicate(db, transaction);

            if (isDuplicate) {
              duplicateCount++;
            } else {
              await db.isar.writeTxn(() async {
                await db.isar.transactions.put(transaction);
              });
              successCount++;
            }
          }
        } catch (e) {
          errorCount++;
          errors.add('第${i + 1}条记录: $e');
        }
      }

      return VaultImportResult(
        success: true,
        successCount: successCount,
        duplicateCount: duplicateCount,
        errorCount: errorCount,
        errors: errors,
      );
    } catch (e) {
      return VaultImportResult(
        success: false,
        error: 'JSON解析失败: $e',
      );
    }
  }

  /// 检查是否重复
  Future<bool> _checkDuplicate(DatabaseService db, Transaction transaction) async {
    // 先检查外部交易ID
    if (transaction.externalTransactionId != null) {
      final existing = await db.isar.transactions
          .filter()
          .externalTransactionIdEqualTo(transaction.externalTransactionId)
          .findFirst();
      if (existing != null) return true;
    }

    // 检查相同日期、金额、类型的记录
    final existing = await db.isar.transactions
        .filter()
        .dateEqualTo(transaction.date)
        .amountEqualTo(transaction.amount)
        .typeEqualTo(transaction.type)
        .findFirst();

    return existing != null;
  }

  /// 解析CSV行，返回交易记录和原始ID
  (Transaction, int)? _parseCsvRow(
    List<dynamic> row,
    Map<String, int> headerMap,
    Map<String, int> categoryMap,
    Map<String, int> accountMap,
  ) {
    // 获取字段值
    String getValue(String header) {
      final index = headerMap[header];
      if (index == null || index >= row.length) return '';
      return row[index]?.toString() ?? '';
    }

    final idStr = getValue('交易ID');
    final dateStr = getValue('交易日期');
    final typeStr = getValue('类型');
    final amountStr = getValue('金额');
    final categoryStr = getValue('分类');
    final accountStr = getValue('账户');
    final counterparty = getValue('交易对方');
    final productDescription = getValue('商品说明');
    final paymentMethod = getValue('收/付款方式');
    final transactionStatus = getValue('交易状态');
    final note = getValue('备注');
    final dataSource = getValue('数据来源');

    // 解析原始ID
    final originalId = int.tryParse(idStr) ?? 0;

    // 解析日期
    DateTime? date;
    try {
      date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr);
    } catch (_) {
      try {
        date = DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (_) {
        date = DateTime.now();
      }
    }

    // 解析类型
    int type;
    switch (typeStr) {
      case '支出':
        type = 0;
        break;
      case '收入':
        type = 1;
        break;
      case '转账':
        type = 2;
        break;
      default:
        type = 0;
    }

    // 解析金额（存储时支出为负数）
    var amount = double.tryParse(amountStr) ?? 0;
    if (type == 0 && amount > 0) {
      amount = -amount;  // 支出存储为负数
    }

    // 获取分类ID
    final categoryId = categoryStr.isNotEmpty
        ? (categoryMap[categoryStr] ?? categoryMap['自定义'])
        : null;

    // 获取账户ID
    final accountId = accountStr.isNotEmpty
        ? (accountMap[accountStr] ?? 1)
        : 1;

    final transaction = Transaction.withDate(
      amount: amount,
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      date: date,
      counterparty: counterparty.isEmpty ? null : counterparty,
      productDescription: productDescription.isEmpty ? null : productDescription,
      paymentMethod: paymentMethod.isEmpty ? null : paymentMethod,
      transactionStatus: transactionStatus.isEmpty ? null : transactionStatus,
      note: note.isEmpty ? null : note,
      dataSource: dataSource.isEmpty ? 'Vault导入' : dataSource,
      externalTransactionId: 'vault_$originalId',  // 用原始ID作为外部ID用于去重
    );

    return (transaction, originalId);
  }

  /// 解析JSON交易记录，返回交易记录和原始ID
  (Transaction, int)? _parseJsonTransaction(
    Map<String, dynamic> data,
    Map<String, int> categoryMap,
    Map<String, int> accountMap,
  ) {
    final originalId = data['id'] as int? ?? 0;

    final dateStr = data['date'] as String?;
    DateTime? date;
    if (dateStr != null) {
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        date = DateTime.now();
      }
    } else {
      date = DateTime.now();
    }

    final type = data['type'] as int? ?? 0;
    var amount = (data['amount'] as num?)?.toDouble() ?? 0;

    // 获取分类ID
    int? categoryId = data['categoryId'] as int?;
    final categoryName = data['categoryName'] as String?;
    if (categoryId == null && categoryName != null) {
      categoryId = categoryMap[categoryName] ?? categoryMap['自定义'];
    }

    // 获取账户ID
    int accountId = data['accountId'] as int? ?? 1;
    final accountName = data['accountName'] as String?;
    if (accountId == 0 && accountName != null) {
      accountId = accountMap[accountName] ?? 1;
    }

    final externalId = data['externalTransactionId'] as String? ?? 'vault_$originalId';

    final transaction = Transaction.withDate(
      amount: amount,
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      date: date,
      counterparty: data['counterparty'] as String?,
      productDescription: data['productDescription'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      transactionStatus: data['transactionStatus'] as String?,
      note: data['note'] as String?,
      dataSource: data['dataSource'] as String? ?? 'Vault导入',
      externalTransactionId: externalId,
    );

    return (transaction, originalId);
  }

  /// 获取分类映射（名称 -> ID）
  Future<Map<String, int>> _getCategoryMap(DatabaseService db) async {
    final categories = await db.isar.categorys.where().findAll();
    return {for (var c in categories) c.name: c.id};
  }

  /// 获取账户映射（名称 -> ID）
  Future<Map<String, int>> _getAccountMap(DatabaseService db) async {
    final accounts = await db.isar.accounts.where().findAll();
    return {for (var a in accounts) a.name: a.id};
  }
}
