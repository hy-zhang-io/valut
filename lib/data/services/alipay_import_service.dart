import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fast_gbk/fast_gbk.dart';
import '../models/transaction.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/import_logger.dart';

/// Result of Alipay CSV import
class AlipayImportResult {
  final int successCount;
  final int duplicateCount;
  final int errorCount;
  final int totalCount;
  final int skippedCount;
  final List<String> errors;
  final List<AlipayTransaction> transactions;

  const AlipayImportResult({
    required this.successCount,
    this.duplicateCount = 0,
    this.errorCount = 0,
    this.totalCount = 0,
    this.skippedCount = 0,
    this.errors = const [],
    this.transactions = const [],
  });

  @override
  String toString() {
    return 'AlipayImportResult{total: $totalCount, success: $successCount, duplicate: $duplicateCount, error: $errorCount, skipped: $skippedCount}';
  }
}

/// Parsed Alipay transaction
class AlipayTransaction {
  final DateTime transactionTime;
  final String category;
  final String counterparty;
  final String? counterpartyAccount;
  final String productDescription;
  final String incomeExpense; // "收" or "支" or "不计收支"
  final double amount;
  final String paymentMethod;
  final String transactionStatus;
  final String transactionId;
  final String? merchantOrderNo;
  final String? note;
  final bool isTransfer; // 是否是转账类交易

  AlipayTransaction({
    required this.transactionTime,
    required this.category,
    required this.counterparty,
    this.counterpartyAccount,
    required this.productDescription,
    required this.incomeExpense,
    required this.amount,
    required this.paymentMethod,
    required this.transactionStatus,
    required this.transactionId,
    this.merchantOrderNo,
    this.note,
    this.isTransfer = false,
  });

  /// Get transaction type from Alipay 收/支/不计收支
  int get transactionType {
    if (incomeExpense.contains('收')) {
      return AppConstants.transactionTypeIncome;
    } else if (incomeExpense.contains('支')) {
      return AppConstants.transactionTypeExpense;
    }
    // 不计收支 - 可能是转账，根据交易分类判断
    if (isTransfer || category.contains('转账') || category.contains('提现')) {
      return AppConstants.transactionTypeTransfer;
    }
    return AppConstants.transactionTypeExpense; // Default to expense
  }

  /// Check if this transaction should be skipped
  /// 跳过不需要导入的记录
  bool get shouldSkip {
    // 跳过"不计收支"的记录（如转账、提现等非收支交易）
    if (incomeExpense == '不计收支') {
      importLogger.debug('跳过记录: 不计收支 (交易ID=$transactionId, 对方=$counterparty)');
      return true;
    }

    // 跳过明确的汇总行：无交易ID AND 无交易对方 AND 无交易状态
    if (transactionStatus.isEmpty && transactionId.isEmpty && counterparty.isEmpty) {
      importLogger.debug('跳过记录: 疑似汇总行 (无ID、无对方、无状态)');
      return true;
    }

    return false;
  }

  /// Convert to Transaction model
  Transaction toTransaction(int accountId, int? categoryId, {String dataSource = '支付宝'}) {
    final type = transactionType;

    // 记录日期信息，便于调试
    importLogger.info('toTransaction: 交易时间=$transactionTime, 交易单号=$transactionId, 对方=$counterparty');

    // 金额统一存储为正数，通过 type 字段区分收支
    final finalAmount = amount.abs();

    return Transaction.withDate(
      amount: finalAmount,
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      note: note?.isNotEmpty == true ? note : productDescription,
      date: transactionTime, // 使用交易时间
      counterparty: counterparty,
      counterpartyAccount: counterpartyAccount,
      productDescription: productDescription,
      paymentMethod: paymentMethod,
      transactionStatus: transactionStatus,
      externalTransactionId: transactionId,
      merchantOrderNo: merchantOrderNo,
      dataSource: dataSource,
    );
  }

  @override
  String toString() {
    return 'AlipayTransaction{time: $transactionTime, category: $category, counterparty: $counterparty, amount: $amount, type: $incomeExpense, status: $transactionStatus}';
  }
}

/// Progress callback for import
typedef ImportProgressCallback = void Function(int current, int total, String stage);

/// Service for importing Alipay CSV files
class AlipayImportService {
  /// Category mapping from Alipay categories to built-in categories
  static const Map<String, int> _categoryMapping = {
    // Transportation
    '交通出行': 7,
    '打车': 7,
    '出行': 7,
    '地铁': 7,
    '公交': 7,
    '哈啰单车': 7,
    '哈啰': 7,
    '共享单车': 7,
    '网络约车': 7,

    // Food / Daily
    '饿了么': 1,
    '美团': 1,
    '外卖': 1,
    '餐饮': 1,
    '美食': 1,
    '生活服务': 1,
    '日常花销': 1,

    // Entertainment / Hobbies
    '充值': 4,
    '会员服务': 4,
    '游戏': 4,
    '视频会员': 4,
    '兴趣爱好': 4,

    // Medical
    '门诊': 8,
    '药店': 8,
    '医疗': 8,
    '医院': 8,
    '医疗支出': 8,

    // Gifts / Red packets
    '红包': 10,
    '转账': 10,
    '普通红包': 10,
    '人情送礼': 10,

    // Bills
    '生活缴费': 6,
    '水费': 6,
    '电费': 6,
    '燃气费': 6,

    // Shopping
    '日用百货': 2,
    '淘宝': 2,
    '天猫': 2,
    '购物': 2,
    '淘宝天猫': 2,
    '淘宝闪购': 2,

    // Transfer (不计收支)
    '转账充值': 999, // 使用自定义分类
    '提现': 999,
  };

  /// Transfer-related categories that should be marked as transfers
  static const Set<String> _transferCategories = {
    '转账充值',
    '提现',
    '信用卡还款',
    '转账',
  };

  /// Get category ID for Alipay category
  static int? getCategoryId(String alipayCategory) {
    // Try exact match first
    if (_categoryMapping.containsKey(alipayCategory)) {
      return _categoryMapping[alipayCategory];
    }

    // Try partial match
    for (var entry in _categoryMapping.entries) {
      if (alipayCategory.contains(entry.key)) {
        return entry.value;
      }
    }

    return null; // Return null to use default mapping
  }

  /// Check if category is a transfer type
  static bool isTransferCategory(String category) {
    for (var transferCat in _transferCategories) {
      if (category.contains(transferCat)) {
        return true;
      }
    }
    return false;
  }

  /// Generate unique transaction ID if original is empty
  static String generateTransactionId(AlipayTransaction tx) {
    if (tx.transactionId.isNotEmpty) {
      return tx.transactionId;
    }
    // Generate ID from time + counterparty + amount
    final timeStr = tx.transactionTime.toIso8601String();
    final amountStr = tx.amount.toStringAsFixed(2);
    return '${timeStr}_${tx.counterparty}_$amountStr';
  }

  /// Parse Alipay CSV file with progress callback
  static Future<AlipayImportResult> parseCsvFile(
    String filePath, {
    ImportProgressCallback? onProgress,
  }) async {
    // Initialize logger
    await importLogger.initialize();
    importLogger.info('========== 开始导入支付宝账单 ==========');
    importLogger.info('文件路径: $filePath');

    final file = File(filePath);
    if (!await file.exists()) {
      importLogger.error('文件不存在: $filePath');
      throw FileNotFoundException('File not found: $filePath');
    }

    onProgress?.call(0, 100, '读取文件...');
    importLogger.info('正在读取文件...');

    // Read file as bytes to handle encoding
    final bytes = await file.readAsBytes();
    String content;

    // Try UTF-8 first, then GBK
    try {
      content = utf8.decode(bytes, allowMalformed: false);
      importLogger.info('文件编码: UTF-8');
    } catch (e) {
      try {
        content = gbk.decode(bytes);
        importLogger.info('文件编码: GBK');
      } catch (e) {
        content = utf8.decode(bytes, allowMalformed: true);
        importLogger.info('文件编码: UTF-8 (with malformed)');
      }
    }

    onProgress?.call(10, 100, '解析CSV...');

    // Remove BOM if present
    if (content.startsWith('\uFEFF')) {
      content = content.substring(1);
      importLogger.debug('移除 BOM 标记');
    }

    // Parse CSV - 不自动转换数字，保持原始字符串格式（避免交易单号被转成科学计数法）
    var rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(content);
    importLogger.info('CSV总行数: ${rows.length}');

    if (rows.isEmpty) {
      importLogger.error('CSV文件为空');
      throw InvalidCsvException('CSV文件为空');
    }

    // 检查CSV结构是否合理
    int maxCols = 0;
    for (var row in rows) {
      if (row.length > maxCols) {
        maxCols = row.length;
      }
    }
    importLogger.info('CSV最大列数: $maxCols');

    // 如果列数过多（超过50列），可能是CSV解析问题（例如所有内容被解析为一行）
    if (maxCols > 50) {
      importLogger.warning('CSV列数异常（$maxCols），可能是CSV格式问题');
      importLogger.warning('尝试按不同换行符重新解析...');

      // 尝试按不同换行符分割后重新解析
      final alternativeRows = _tryAlternativeParsing(content);
      if (alternativeRows != null && alternativeRows.length > 1) {
        // 检查替代解析是否产生更合理的列数
        int altMaxCols = 0;
        for (var row in alternativeRows) {
          if (row.length > altMaxCols) altMaxCols = row.length;
        }
        if (altMaxCols < maxCols) {
          rows = alternativeRows;
          importLogger.info('使用替代解析成功，新行数: ${rows.length}，最大列数: $altMaxCols');
        }
      }
    }

    // Debug: 打印前5行内容
    importLogger.info('========== CSV前5行内容 ==========');
    for (int i = 0; i < rows.length && i < 5; i++) {
      importLogger.info('第$i行 (${rows[i].length}列): ${rows[i]}');
    }
    importLogger.info('========================================');

    // Find the header row
    int headerRowIndex = _findHeaderRow(rows);
    if (headerRowIndex == -1) {
      importLogger.error('无法找到表头行');
      throw InvalidCsvException('无法找到表头行，请确认是支付宝账单文件');
    }
    importLogger.info('表头行索引: $headerRowIndex');

    final headers = rows[headerRowIndex];
    importLogger.info('表头列: $headers');
    
    final dataStartIndex = headerRowIndex + 1;

    // Map column indices
    final colMap = _mapColumnIndices(headers);
    importLogger.debug('列映射: $colMap');

    // Validate required columns
    final requiredCols = ['交易时间', '交易分类', '交易对方', '金额', '收/支'];
    for (var col in requiredCols) {
      if (!colMap.containsKey(col)) {
        importLogger.error('缺少必要列: $col');
        throw InvalidCsvException('缺少必要列: $col');
      }
    }

    onProgress?.call(20, 100, '分析数据...');

    // Parse data rows
    final transactions = <AlipayTransaction>[];
    final errors = <String>[];
    int skippedCount = 0;
    int totalRows = rows.length - dataStartIndex;

    importLogger.info('开始解析数据行，共 $totalRows 行');

    // 用于检测重复交易单号
    final transactionIdSet = <String>{};
    int duplicateInFile = 0;

    for (int i = dataStartIndex; i < rows.length; i++) {
      final row = rows[i];
      final rowNum = i - dataStartIndex + 1;
      
      // Update progress every 10 rows
      if ((i - dataStartIndex) % 10 == 0) {
        final progress = 20 + ((i - dataStartIndex) * 30 ~/ totalRows);
        onProgress?.call(progress, 100, '解析第 ${i - dataStartIndex + 1}/$totalRows 行...');
      }

      // Skip empty rows
      if (row.isEmpty || _isRowEmpty(row)) {
        importLogger.debug('第$rowNum行: 空行，跳过');
        continue;
      }

      try {
        final transaction = _parseRow(row, colMap);
        importLogger.debug('第$rowNum行: 解析成功 - $transaction');
        
        // Skip transactions that should be ignored
        if (transaction.shouldSkip) {
          skippedCount++;
          importLogger.debug('第$rowNum行: 被跳过 (原因见shouldSkip日志)');
          continue;
        }

        // 检查文件内重复（根据生成的交易ID）
        final uniqueId = generateTransactionId(transaction);
        if (transactionIdSet.contains(uniqueId)) {
          duplicateInFile++;
          importLogger.warning('第$rowNum行: 文件内重复，跳过 - $uniqueId');
          continue;
        }
        transactionIdSet.add(uniqueId);
        
        transactions.add(transaction);
        importLogger.info('第$rowNum行: 添加交易记录 - 时间=${transaction.transactionTime}, 对方=${transaction.counterparty}, 金额=${transaction.amount}, 分类=${transaction.category}, 交易单号=${transaction.transactionId}');
      } catch (e) {
        final error = '第$rowNum行: $e';
        errors.add(error);
        importLogger.error(error);
      }
    }

    onProgress?.call(50, 100, '找到 ${transactions.length} 条有效记录');
    
    importLogger.info('========== 解析完成 ==========');
    importLogger.info('总数据行: $totalRows');
    importLogger.info('有效记录: ${transactions.length}');
    importLogger.info('跳过记录: $skippedCount');
    importLogger.info('文件内重复: $duplicateInFile');
    importLogger.info('错误记录: ${errors.length}');

    for (var tx in transactions) {
      final uniqueId = generateTransactionId(tx);
      importLogger.info('[交易记录] ID: $uniqueId, 时间: ${tx.transactionTime}, 对方: ${tx.counterparty}, 金额: ${tx.amount}, 分类: ${tx.category}, 状态: ${tx.transactionStatus}');
    }

    return AlipayImportResult(
      successCount: transactions.length,
      totalCount: transactions.length,
      skippedCount: skippedCount + duplicateInFile,
      transactions: transactions,
      errors: errors,
    );
  }

  /// 支付宝CSV标准表头列名（用于精确匹配）
  static const Set<String> _expectedHeaderColumns = {
    '交易时间', '交易分类', '交易对方', '商品说明', '收/支',
    '金额', '收/付款方式', '交易状态', '交易单号', '商家订单号',
    '备注', '对方账号', '创建时间', '交易类型',
  };

  /// Find the header row in Alipay CSV
  /// 使用更精确的匹配方式：检查行中是否包含多个预期的表头列名
  static int _findHeaderRow(List<List<dynamic>> rows) {
    int bestMatchIndex = -1;
    int bestMatchCount = 0;

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      // 统计这一行中匹配的表头列数量
      int matchCount = 0;
      for (var cell in row) {
        final cellStr = cell?.toString().trim() ?? '';
        if (_expectedHeaderColumns.contains(cellStr)) {
          matchCount++;
        }
      }

      // 需要至少匹配3个表头列才算找到表头行（避免误匹配数据行）
      if (matchCount >= 3 && matchCount > bestMatchCount) {
        bestMatchCount = matchCount;
        bestMatchIndex = i;
        importLogger.debug('第$i行匹配到$matchCount个表头列: $row');
      }
    }

    return bestMatchIndex;
  }

  /// 尝试使用不同的换行符解析CSV（处理行尾格式问题）
  static List<List<dynamic>>? _tryAlternativeParsing(String content) {
    // 首先尝试直接按行分割后逐行解析
    importLogger.info('尝试手动逐行解析...');

    // 按各种可能的换行符分割
    final lines = content.split(RegExp(r'\r\n|\n|\r'));
    importLogger.info('按换行符分割得到 ${lines.length} 行');

    if (lines.length > 10) {
      // 逐行解析CSV
      final rows = <List<dynamic>>[];
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        try {
          // 使用CSV解析器解析单行
          final row = const CsvToListConverter(
            shouldParseNumbers: false,
            eol: '\n',
          ).convert(line + '\n');
          if (row.isNotEmpty) {
            rows.add(row.first);
          }
        } catch (e) {
          // 如果单行解析失败，尝试简单分割
          final simpleRow = line.split(',').map((s) => s.trim()).toList();
          rows.add(simpleRow);
        }
      }

      // 检查结果是否更合理
      int maxCols = 0;
      for (var row in rows) {
        if (row.length > maxCols) maxCols = row.length;
      }

      importLogger.info('手动解析结果: ${rows.length}行, 最大${maxCols}列');

      // 如果列数合理（小于30列），使用这个结果
      if (maxCols < 30 && rows.length > 1) {
        importLogger.info('手动解析成功');
        return rows;
      }
    }

    // 尝试不同的换行符组合
    final lineEndings = ['\r\n', '\n', '\r'];

    for (var eol in lineEndings) {
      // 按该换行符分割
      final lines = content.split(eol);
      if (lines.length > 1) {
        importLogger.debug('使用换行符 ${eol == '\r\n' ? 'CRLF' : eol == '\n' ? 'LF' : 'CR'} 分割得到 ${lines.length} 行');

        // 重新组合并解析
        final rejoined = lines.join('\n');
        try {
          final rows = const CsvToListConverter(
            shouldParseNumbers: false,
          ).convert(rejoined);

          // 检查结果是否更合理
          int maxCols = 0;
          for (var row in rows) {
            if (row.length > maxCols) maxCols = row.length;
          }

          // 如果列数合理（小于30列），使用这个结果
          if (maxCols < 30 && rows.length > 1) {
            importLogger.info('替代解析成功: ${rows.length}行, 最大${maxCols}列');
            return rows;
          }
        } catch (e) {
          importLogger.debug('替代解析失败: $e');
        }
      }
    }

    return null;
  }

  /// Check if row is empty
  static bool _isRowEmpty(List row) {
    for (var item in row) {
      if (item != null && item.toString().trim().isNotEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Map CSV column names to indices
  static Map<String, int> _mapColumnIndices(List<dynamic> headers) {
    final map = <String, int>{};
    for (int i = 0; i < headers.length; i++) {
      final name = headers[i]?.toString().trim() ?? '';
      if (name.isNotEmpty) {
        // Normalize column names (handle different versions)
        final normalizedName = _normalizeColumnName(name);
        map[normalizedName] = i;
      }
    }
    return map;
  }

  /// Normalize column names for different CSV versions
  static String _normalizeColumnName(String name) {
    // 先去除首尾空白
    final trimmedName = name.trim();

    final Map<String, String> nameMapping = {
      // 时间相关
      '创建时间': '交易时间',
      '时间': '交易时间',
      // 分类相关
      '类型': '交易分类',
      '交易类型': '交易分类',
      // 对方相关
      '商户名称': '交易对方',
      '对方户名': '交易对方',
      // 商品说明
      '名称': '商品说明',
      '商品': '商品说明',
      '商品名': '商品说明',
      // 付款方式
      '收/付款方式': '收/付款方式',
      '付款方式': '收/付款方式',
      '支付方式': '收/付款方式',
      // 交易状态
      '资金状态': '交易状态',
      '状态': '交易状态',
      '交易状态 ': '交易状态',  // 处理尾部空格
      // 订单号
      '订单号': '交易单号',
      '交易订单号': '交易单号',
      '交易单号 ': '交易单号',  // 处理尾部空格
      // 商家订单号
      '商家订单号 ': '商家订单号',
      // 备注
      '备注 ': '备注',
    };
    return nameMapping[trimmedName] ?? trimmedName;
  }

  /// Parse a single CSV row
  static AlipayTransaction _parseRow(
    List<dynamic> row,
    Map<String, int> colMap,
  ) {
    // Helper to get column value safely with logging
    String getCol(String key, {String defaultValue = ''}) {
      final index = colMap[key];
      if (index == null || index >= row.length) {
        importLogger.debug('  字段 "$key": 未找到列或索引越界 (index=$index, row.length=${row.length})');
        return defaultValue;
      }
      final value = row[index];
      final result = value?.toString().trim() ?? defaultValue;
      importLogger.debug('  字段 "$key": "$result"');
      return result;
    }

    importLogger.debug('=== 开始解析行 ===');
    importLogger.debug('行数据: $row');

    // Parse transaction time
    final timeStr = getCol('交易时间');
    importLogger.info('原始时间字符串: "$timeStr"');
    if (timeStr.isEmpty) {
      throw Exception('交易时间为空');
    }
    final transactionTime = _parseDateTime(timeStr);
    importLogger.info('解析后时间: $transactionTime');

    // Parse amount - handle various formats
    final amountStr = getCol('金额', defaultValue: '0');
    final amount = _parseAmount(amountStr);

    // Get category and check if it's a transfer
    final category = getCol('交易分类');
    final isTransfer = isTransferCategory(category);

    // Get income/expense type
    final incomeExpense = getCol('收/支');

    // Get transaction status
    final status = getCol('交易状态');

    // Get remaining fields
    final counterparty = getCol('交易对方');
    final counterpartyAccount = getCol('对方账号');
    final productDescription = getCol('商品说明');
    final paymentMethod = getCol('收/付款方式');
    final transactionId = getCol('交易单号');
    final merchantOrderNo = getCol('商家订单号');
    final note = getCol('备注');

    importLogger.debug('=== 解析结果 ===');
    importLogger.debug('  时间: $transactionTime, 分类: $category, 金额: $amount');
    importLogger.debug('  收/支: $incomeExpense, 状态: "$status", 交易单号: $transactionId');

    return AlipayTransaction(
      transactionTime: transactionTime,
      category: category,
      counterparty: counterparty,
      counterpartyAccount: counterpartyAccount.isEmpty ? null : counterpartyAccount,
      productDescription: productDescription,
      incomeExpense: incomeExpense.isEmpty ? '不计收支' : incomeExpense,
      amount: amount,
      paymentMethod: paymentMethod,
      transactionStatus: status,
      transactionId: transactionId,
      merchantOrderNo: merchantOrderNo.isEmpty ? null : merchantOrderNo,
      note: note.isEmpty ? null : note,
      isTransfer: isTransfer,
    );
  }

  /// Parse amount string (handle various formats)
  static double _parseAmount(String str) {
    // Remove currency symbols and whitespace
    str = str.replaceAll('¥', '').replaceAll(',', '').trim();
    return double.tryParse(str) ?? 0;
  }

  /// Parse Alipay/WeChat datetime format
  /// 支持多种时间格式：
  /// - "2026/1/31 17:05" (支付宝常见格式)
  /// - "2026/1/31 17:05:00"
  /// - "2026/1/31  17:05:00" (多空格)
  /// - "2026-01-31 17:05:00" (微信常见格式)
  /// - "2026-01-31T17:05:00" (ISO格式)
  /// - "2026-01-31T17:05:00.000" (带毫秒)
  /// - "2026年01月31日 17:05" (中文格式)
  static DateTime _parseDateTime(String str) {
    if (str.isEmpty) {
      importLogger.warning('时间字符串为空，使用当前时间');
      return DateTime.now();
    }

    final originalStr = str;
    importLogger.debug('解析时间: "$str"');

    try {
      // 预处理：移除所有类型的空白字符（包括全角空格、制表符等）
      // 统一替换为单个普通空格
      str = str.replaceAll(RegExp(r'[\s\u00A0\u3000]+'), ' ').trim();
      importLogger.debug('  预处理后: "$str"');

      // 格式1: ISO 8601 格式 (2026-01-31T17:05:00 或 2026-01-31T17:05:00.000)
      if (str.contains('T')) {
        try {
          final result = DateTime.parse(str);
          importLogger.debug('  -> ISO格式解析成功: $result');
          return result;
        } catch (e) {
          // 继续尝试其他格式
        }
      }

      // 格式2: 中文格式 (2026年01月31日 17:05)
      if (str.contains('年') && str.contains('月') && str.contains('日')) {
        final chinesePattern = RegExp(r'(\d{4})年(\d{1,2})月(\d{1,2})日\s*(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?');
        final match = chinesePattern.firstMatch(str);
        if (match != null) {
          final result = DateTime(
            int.parse(match.group(1)!),
            int.parse(match.group(2)!),
            int.parse(match.group(3)!),
            int.parse(match.group(4)!),
            int.parse(match.group(5)!),
            match.group(6) != null ? int.parse(match.group(6)!) : 0,
          );
          importLogger.debug('  -> 中文格式解析成功: $result');
          return result;
        }
      }

      // 格式3: 标准日期时间格式 (用空格分隔)
      // 统一分隔符为 /
      String normalized = str.replaceAll('-', '/');

      final parts = normalized.split(RegExp(r'\s+'));
      importLogger.debug('  分割后parts: $parts');

      if (parts.isNotEmpty) {
        final dateParts = parts[0].split('/');
        List<String>? timeParts;

        if (parts.length >= 2) {
          timeParts = parts[1].split(':');
        }

        importLogger.debug('  dateParts: $dateParts, timeParts: $timeParts');

        if (dateParts.length == 3) {
          final year = int.parse(dateParts[0]);
          final month = int.parse(dateParts[1]);
          final day = int.parse(dateParts[2]);

          int hour = 0, minute = 0, second = 0;
          if (timeParts != null && timeParts.length >= 2) {
            hour = int.parse(timeParts[0]);
            minute = int.parse(timeParts[1]);
            if (timeParts.length >= 3) {
              second = int.tryParse(timeParts[2].split('.').first) ?? 0;
            }
          }

          final result = DateTime(year, month, day, hour, minute, second);
          importLogger.info('  -> 标准格式解析成功: $result (原始: "$originalStr")');
          return result;
        }
      }

      // 格式4: 只有日期没有时间 (2026-01-31 或 2026/01/31)
      if (!str.contains(' ') && !str.contains('T')) {
        final dateOnly = str.replaceAll('-', '/').split('/');
        if (dateOnly.length == 3) {
          final result = DateTime(
            int.parse(dateOnly[0]),
            int.parse(dateOnly[1]),
            int.parse(dateOnly[2]),
          );
          importLogger.debug('  -> 纯日期格式解析成功: $result');
          return result;
        }
      }

    } catch (e) {
      importLogger.warning('时间解析失败: "$originalStr", 错误: $e');
    }

    // 最后尝试直接用 DateTime.parse
    try {
      final result = DateTime.parse(str);
      importLogger.debug('  -> DateTime.parse 解析成功: $result');
      return result;
    } catch (e) {
      importLogger.error('所有时间解析方式都失败，使用当前时间。原始值: "$originalStr"');
      return DateTime.now();
    }
  }

  /// Get suggested account name for Alipay
  static String getAlipayAccountName() {
    return '支付宝';
  }
}

/// Custom exceptions
class FileNotFoundException implements Exception {
  final String message;
  FileNotFoundException(this.message);
  @override
  String toString() => message;
}

class EncodingException implements Exception {
  final String message;
  EncodingException(this.message);
  @override
  String toString() => message;
}

class InvalidCsvException implements Exception {
  final String message;
  InvalidCsvException(this.message);
  @override
  String toString() => message;
}
