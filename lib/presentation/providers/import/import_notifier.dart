import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/import_logger.dart';
import '../../../data/models/transaction.dart';
import '../../../data/models/category.dart';
import '../../../data/models/category_mapping.dart';
import '../../../data/services/alipay_import_service.dart';
import '../../../data/repositories/database_service.dart';
import '../database_provider.dart';
import '../category_provider.dart';
import '../transaction_provider.dart';

part 'import_notifier.g.dart';

/// Import stage
enum ImportStage {
  idle,
  parsing,
  analyzing,
  importing,
  completed,
  error,
}

/// Import state with progress
class ImportState {
  const ImportState({
    this.isImporting = false,
    this.stage = ImportStage.idle,
    this.progress = 0,
    this.total = 0,
    this.parsedCount = 0,
    this.successCount = 0,
    this.duplicateCount = 0,
    this.errorCount = 0,
    this.currentRow = 0,
    this.stageMessage = '',
    this.previewTransactions = const [],
    this.logFilePath,
    this.errorMessage,
  });

  final bool isImporting;
  final ImportStage stage;
  final int progress; // 0-100
  final int total;
  final int parsedCount;
  final int successCount;
  final int duplicateCount;
  final int errorCount;
  final int currentRow;
  final String stageMessage;
  final List<AlipayTransaction> previewTransactions;
  final String? logFilePath;
  final String? errorMessage;

  ImportState copyWith({
    bool? isImporting,
    ImportStage? stage,
    int? progress,
    int? total,
    int? parsedCount,
    int? successCount,
    int? duplicateCount,
    int? errorCount,
    int? currentRow,
    String? stageMessage,
    List<AlipayTransaction>? previewTransactions,
    String? logFilePath,
    String? errorMessage,
  }) {
    return ImportState(
      isImporting: isImporting ?? this.isImporting,
      stage: stage ?? this.stage,
      progress: progress ?? this.progress,
      total: total ?? this.total,
      parsedCount: parsedCount ?? this.parsedCount,
      successCount: successCount ?? this.successCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      errorCount: errorCount ?? this.errorCount,
      currentRow: currentRow ?? this.currentRow,
      stageMessage: stageMessage ?? this.stageMessage,
      previewTransactions: previewTransactions ?? this.previewTransactions,
      logFilePath: logFilePath ?? this.logFilePath,
      errorMessage: errorMessage,
    );
  }

  /// Get formatted progress text
  String get progressText => '$progress%';

  /// Check if import is in progress
  bool get isInProgress => isImporting && stage != ImportStage.completed && stage != ImportStage.error;
}

/// Provider for Alipay import operations
@riverpod
class AlipayImportNotifier extends _$AlipayImportNotifier {
  @override
  ImportState build() {
    return const ImportState();
  }

  /// Parse CSV file for preview
  Future<void> parsePreview(String filePath) async {
    state = state.copyWith(
      isImporting: true,
      stage: ImportStage.parsing,
      stageMessage: '正在解析文件...',
      progress: 0,
      errorMessage: null,
    );

    try {
      final result = await AlipayImportService.parseCsvFile(
        filePath,
        onProgress: (current, total, stage) {
          state = state.copyWith(
            progress: current,
            stageMessage: stage,
          );
        },
      );

      state = state.copyWith(
        isImporting: false,
        stage: ImportStage.idle,
        previewTransactions: result.transactions,
        parsedCount: result.transactions.length,
        total: result.transactions.length,
        progress: 100,
        stageMessage: '解析完成，共 ${result.transactions.length} 条记录',
      );
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        stage: ImportStage.error,
        errorMessage: e.toString(),
        stageMessage: '解析失败',
      );
    }
  }

  /// Import transactions from CSV file
  Future<void> import(String filePath) async {
    state = state.copyWith(
      isImporting: true,
      stage: ImportStage.parsing,
      progress: 0,
      successCount: 0,
      duplicateCount: 0,
      errorCount: 0,
      currentRow: 0,
      errorMessage: null,
      stageMessage: '正在读取文件...',
    );

    try {
      // Step 1: Parse CSV
      final parseResult = await AlipayImportService.parseCsvFile(
        filePath,
        onProgress: (current, total, stageMsg) {
          state = state.copyWith(
            progress: current,
            stageMessage: stageMsg,
          );
        },
      );

      if (parseResult.transactions.isEmpty) {
        state = state.copyWith(
          isImporting: false,
          stage: ImportStage.completed,
          stageMessage: '没有找到有效交易记录',
          progress: 100,
        );
        return;
      }

      // Step 2: Get or create Alipay account
      state = state.copyWith(
        stage: ImportStage.analyzing,
        stageMessage: '准备账户信息...',
        progress: 50,
      );

      final db = ref.read(databaseServiceProvider);
      final alipayAccount = await db.getOrCreateAlipayAccount();

      // Get all categories for mapping
      final expenseCats = ref.read(expenseCategoriesProvider);
      final incomeCats = ref.read(incomeCategoriesProvider);
      final categories = [...expenseCats, ...incomeCats];

      // Step 3: Import to database
      state = state.copyWith(
        stage: ImportStage.importing,
        total: parseResult.transactions.length,
        stageMessage: '正在导入数据库...',
        progress: 60,
      );

      int successCount = 0;
      int duplicateCount = 0;
      int errorCount = 0;

      // Convert to Transaction models
      final transactions = <Transaction>[];
      for (int i = 0; i < parseResult.transactions.length; i++) {
        final alipayTx = parseResult.transactions[i];
        
        // Update progress every 5 items
        if (i % 5 == 0) {
          final importProgress = 60 + (i * 35 ~/ parseResult.transactions.length);
          state = state.copyWith(
            progress: importProgress,
            currentRow: i + 1,
            stageMessage: '导入中... (${i + 1}/${parseResult.transactions.length})',
          );
        }

        try {
          final categoryId = await _getCategoryId(alipayTx.category, categories, 'alipay');
          final tx = alipayTx.toTransaction(alipayAccount.id, categoryId, dataSource: '支付宝');
          transactions.add(tx);
        } catch (e) {
          errorCount++;
        }
      }

      // Batch import
      final (success, duplicate, error) =
          await db.importAlipayTransactions(transactions);

      successCount = success;
      duplicateCount = duplicate;
      errorCount += error;

      // 刷新交易列表，使新导入的数据立即显示
      // 直接调用reload重新加载数据，不需要invalidate
      await ref.read(transactionNotifierProvider.notifier).reload();
      // 同时invalidate以通知依赖的providers更新
      ref.invalidate(transactionNotifierProvider);

      state = state.copyWith(
        isImporting: false,
        stage: ImportStage.completed,
        successCount: successCount,
        duplicateCount: duplicateCount,
        errorCount: errorCount,
        progress: 100,
        stageMessage: '导入完成！成功 $successCount 条，跳过重复 $duplicateCount 条',
        logFilePath: importLogger.logFilePath,
      );
    } catch (e) {
      state = state.copyWith(
        isImporting: false,
        stage: ImportStage.error,
        errorMessage: e.toString(),
        stageMessage: '导入失败: $e',
        logFilePath: importLogger.logFilePath,
      );
    }
  }

  /// Get category ID for Alipay category using user-defined mappings
  Future<int?> _getCategoryId(String alipayCategory, List<Category> categories, String sourceType) async {
    // 使用 CategoryMappingService 获取用户配置的映射
    final mappingService = CategoryMappingService();
    final db = ref.read(databaseServiceProvider);
    mappingService.initialize(db.isar);
    
    // 首先尝试从用户映射中查找
    final mapping = await mappingService.findMapping(alipayCategory, sourceType);
    if (mapping != null) {
      // 检查映射的分类是否有效
      if (categories.any((c) => c.id == mapping.internalCategoryId)) {
        importLogger.debug('分类映射: "$alipayCategory" -> ${mapping.internalCategoryId} (用户映射)');
        return mapping.internalCategoryId;
      }
    }
    
    // 如果没有找到用户映射，使用默认的硬编码映射
    final mappedId = AlipayImportService.getCategoryId(alipayCategory);
    if (mappedId != null && categories.any((c) => c.id == mappedId)) {
      importLogger.debug('分类映射: "$alipayCategory" -> $mappedId (默认映射)');
      return mappedId;
    }

    // 使用自定义分类作为回退
    try {
      final custom = categories.firstWhere((c) => c.name == '自定义');
      importLogger.debug('分类映射: "$alipayCategory" -> ${custom.id} (自定义回退)');
      return custom.id;
    } catch (e) {
      // Fallback to first category if '自定义' not found
      return categories.isNotEmpty ? categories.first.id : null;
    }
  }

  /// Clear preview
  void clearPreview() {
    state = state.copyWith(
      previewTransactions: [],
      progress: 0,
      total: 0,
      parsedCount: 0,
      successCount: 0,
      duplicateCount: 0,
      errorCount: 0,
      currentRow: 0,
      stageMessage: '',
      errorMessage: null,
      logFilePath: null,
      stage: ImportStage.idle,
    );
    importLogger.clear();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for getting category name by ID
@riverpod
String categoryNameById(CategoryNameByIdRef ref, int? categoryId) {
  if (categoryId == null) return '未分类';

  final expenseCats = ref.watch(expenseCategoriesProvider);
  final incomeCats = ref.watch(incomeCategoriesProvider);
  final categories = [...expenseCats, ...incomeCats];

  try {
    final category = categories.firstWhere((c) => c.id == categoryId);
    return category.name;
  } catch (e) {
    return '未知';
  }
}
