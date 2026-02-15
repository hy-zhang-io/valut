import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/import_logger.dart';
import '../models/account.dart';
import '../models/category.dart';
import '../models/category_mapping.dart';
import '../models/export_record.dart';
import '../models/settings.dart';
import '../models/transaction.dart';

/// Database service for managing Isar database
class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Isar? _isar;
  bool _isInitialized = false;

  /// Get the Isar instance
  Isar get isar {
    if (_isar == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _isar!;
  }

  /// Check if database is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the database
  Future<void> initialize() async {
    if (_isInitialized) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        AccountSchema,
        CategorySchema,
        CategoryMappingSchema,
        ExportRecordSchema,
        TransactionSchema,
        SettingsSchema,
      ],
      directory: dir.path,
      inspector: true, // Enable for development
    );
    
    // Initialize category mapping service
    CategoryMappingService().initialize(_isar!);

    // Initialize built-in categories if empty
    await _initializeBuiltInCategories();

    _isInitialized = true;
  }

  /// Initialize built-in categories
  Future<void> _initializeBuiltInCategories() async {
    final expenseCount = await _isar!.categorys
        .filter()
        .typeEqualTo(0)
        .count();

    if (expenseCount == 0) {
      final expenseCategories = Category.builtInExpenseCategories();
      importLogger.info('初始化支出分类，共 ${expenseCategories.length} 个');
      await _isar!.writeTxn(() async {
        for (final category in expenseCategories) {
          importLogger.info('  添加分类: ID=${category.id}, 名称=${category.name}');
          await _isar!.categorys.put(category);
        }
      });
    }

    final incomeCount = await _isar!.categorys
        .filter()
        .typeEqualTo(1)
        .count();

    if (incomeCount == 0) {
      final incomeCategories = Category.builtInIncomeCategories();
      importLogger.info('初始化收入分类，共 ${incomeCategories.length} 个');
      await _isar!.writeTxn(() async {
        for (final category in incomeCategories) {
          importLogger.info('  添加分类: ID=${category.id}, 名称=${category.name}');
          await _isar!.categorys.put(category);
        }
      });
    }
  }

  /// Clear all data (for testing purposes)
  Future<void> clearAll() async {
    await _isar!.writeTxn(() async {
      await _isar!.clear();
    });
    await _initializeBuiltInCategories();
  }

  /// Close the database
  Future<void> close() async {
    await _isar?.close();
    _isar = null;
    _isInitialized = false;
  }
}

/// Extension for easy access to collections
extension DatabaseServiceCollections on DatabaseService {
  /// Get account collection
  IsarCollection<Account> get accounts => isar.accounts;

  /// Get category collection
  IsarCollection<Category> get categories => isar.categorys;

  /// Get transaction collection
  IsarCollection<Transaction> get transactions => isar.transactions;

  /// Get settings collection
  // NOTE: Isar auto-pluralizes "Settings" to "settingss" - use direct access or rename collection
  // IsarCollection<Settings> get settings => isar.settingss;
}

/// Extension for Alipay import operations
extension DatabaseServiceAlipayImport on DatabaseService {
  /// Find or create Alipay account
  Future<Account> getOrCreateAlipayAccount() async {
    final existing = await isar.accounts
        .filter()
        .nameEqualTo('支付宝')
        .findFirst();

    if (existing != null) {
      return existing;
    }

    // Create new Alipay account
    final account = Account(
      name: '支付宝',
      icon: 0xe539, // payment icon
      color: 0xFF2196F3, // blue
      balance: 0,
    );

    await isar.writeTxn(() async {
      await isar.accounts.put(account);
    });

    return account;
  }

  /// Find transaction by external transaction ID
  Future<Transaction?> findByExternalTransactionId(String externalId) async {
    return await isar.transactions
        .filter()
        .externalTransactionIdEqualTo(externalId)
        .findFirst();
  }

  /// Batch import Alipay transactions
  /// Returns (successCount, duplicateCount, errorCount)
  Future<(int success, int duplicate, int error)> importAlipayTransactions(
    List<Transaction> transactions,
  ) async {
    int successCount = 0;
    int duplicateCount = 0;
    int errorCount = 0;

    importLogger.info('========== 开始写入数据库 ==========');
    importLogger.info('待导入交易数: ${transactions.length}');

    // 用于检测本次导入内的重复
    final processedIds = <String>{};

    await isar.writeTxn(() async {
      for (int i = 0; i < transactions.length; i++) {
        final tx = transactions[i];
        try {
          // 生成唯一的交易ID（如果externalTransactionId为空，使用组合字段生成）
          final effectiveId = tx.externalTransactionId?.isNotEmpty == true
              ? tx.externalTransactionId!
              : '${tx.date.toIso8601String()}_${tx.counterparty}_${tx.amount}';

          importLogger.debug('[$i/${transactions.length}] 处理交易: $effectiveId');
          importLogger.debug('  - 日期: ${tx.date}');
          importLogger.debug('  - 金额: ${tx.amount}');
          importLogger.debug('  - 对方: ${tx.counterparty}');
          importLogger.debug('  - 数据来源: ${tx.dataSource}');

          // 检查本次导入内是否重复
          if (processedIds.contains(effectiveId)) {
            duplicateCount++;
            importLogger.warning('[$i] 本次导入内重复，跳过: $effectiveId');
            continue;
          }

          // Check for duplicates by external transaction ID in database
          final existing = await isar.transactions
              .filter()
              .externalTransactionIdEqualTo(effectiveId)
              .findFirst();

          if (existing != null) {
            duplicateCount++;
            importLogger.warning('[$i] 数据库中已存在，跳过: $effectiveId');
            continue;
          }

          // 设置effectiveId到transaction
          final txToSave = tx.externalTransactionId?.isNotEmpty == true
              ? tx
              : tx.copyWith(externalTransactionId: effectiveId);

          // 保存前日志
          importLogger.debug('[$i] 保存前: ID=${txToSave.id}, date=${txToSave.date}, amount=${txToSave.amount}');

          final savedId = await isar.transactions.put(txToSave);

          // 保存后立即读取验证
          final saved = await isar.transactions.get(savedId);
          importLogger.debug('[$i] 保存后: savedId=$savedId, date=${saved?.date}, amount=${saved?.amount}');

          processedIds.add(effectiveId);
          successCount++;
          importLogger.success('[$i] 成功导入: $effectiveId (数据库ID=$savedId)');
        } catch (e) {
          errorCount++;
          importLogger.error('[$i] 导入失败: ${tx.externalTransactionId}, 错误: $e');
        }
      }
    });

    importLogger.info('========== 数据库写入完成 ==========');
    importLogger.info('成功: $successCount');
    importLogger.info('重复: $duplicateCount');
    importLogger.info('失败: $errorCount');

    return (successCount, duplicateCount, errorCount);
  }

  /// Get all external transaction IDs for deduplication check
  Future<List<String>> getAllExternalTransactionIds() async {
    final transactions = await isar.transactions
        .filter()
        .externalTransactionIdIsNotNull()
        .findAll();

    return transactions
        .map((tx) => tx.externalTransactionId ?? '')
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
  }
}
