import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/utils/import_logger.dart';
import '../../data/models/settings.dart';
import '../../data/models/transaction.dart';
import 'database_provider.dart';

part 'transaction_provider.g.dart';

/// Provider for all transactions
@riverpod
class TransactionNotifier extends _$TransactionNotifier {
  @override
  List<Transaction> build() {
    // 监听数据库初始化状态
    final db = ref.watch(databaseServiceProvider);
    if (!db.isInitialized) {
      return [];
    }

    // 同步加载初始数据 - 使用 Future 微任务确保不阻塞 build
    Future.microtask(() => _loadTransactions());
    return [];
  }

  Future<void> _loadTransactions() async {
    final db = ref.read(databaseServiceProvider);
    if (!db.isInitialized) return;

    // Get all transactions
    final transactions = await db.isar.transactions.where().findAll();

    // 调试日志：检查从数据库读取的日期
    importLogger.info('========== _loadTransactions 从数据库读取 ${transactions.length} 条交易 ==========');
    for (int i = 0; i < transactions.length && i < 5; i++) {
      final t = transactions[i];
      importLogger.info('  [$i] ID=${t.id}, date=${t.date}, externalId=${t.externalTransactionId}');
    }

    state = transactions;
  }

  /// 重新加载交易数据（导入后调用）
  Future<void> reload() async {
    await _loadTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    final db = ref.watch(databaseServiceProvider);
    await db.isar.writeTxn(() async {
      await db.isar.transactions.put(transaction);
    });
    await _loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = ref.watch(databaseServiceProvider);
    await db.isar.writeTxn(() async {
      await db.isar.transactions.put(transaction);
    });
    await _loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    final db = ref.watch(databaseServiceProvider);
    await db.isar.writeTxn(() async {
      await db.isar.transactions.delete(id);
    });
    await _loadTransactions();
  }

  Future<Transaction?> getTransaction(int id) async {
    final db = ref.watch(databaseServiceProvider);
    return await db.isar.transactions.get(id);
  }

  /// 生成手工交易的唯一ID（格式：{设备ID}-YYYYMMDD-XXXX）
  Future<String> generateManualTransactionId(DateTime date) async {
    final db = ref.read(databaseServiceProvider);

    // 获取或生成设备ID
    var settings = await db.isar.settings.get(1);
    var deviceId = settings?.deviceId ?? '';

    // 如果设备ID为空，生成并保存
    if (deviceId.isEmpty) {
      deviceId = Settings.generateDeviceId();
      settings = (settings ?? Settings()).copyWith(deviceId: deviceId);
      await db.isar.writeTxn(() async {
        await db.isar.settings.put(settings!);
      });
    }

    // 格式化日期部分
    final dateStr =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

    // 设备前缀
    final prefix = '$deviceId-$dateStr';

    // 查询当天本设备已有交易数量（通过externalTransactionId前缀匹配）
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final todayTransactions = await db.isar.transactions
        .filter()
        .dateBetween(startOfDay, endOfDay)
        .externalTransactionIdStartsWith(prefix)
        .findAll();

    // 计算下一个序号
    final nextSeq = todayTransactions.length + 1;
    final seqStr = nextSeq.toString().padLeft(4, '0');

    return '$prefix-$seqStr';
  }
}

/// Provider for today's transactions
@riverpod
List<Transaction> todayTransactions(TodayTransactionsRef ref) {
  final transactions = ref.watch(transactionNotifierProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return transactions.where((t) {
    final transactionDate = DateTime(t.date.year, t.date.month, t.date.day);
    return transactionDate.isAtSameMomentAs(today);
  }).toList();
}

/// Provider for today's total expenses
@riverpod
double todayExpenses(TodayExpensesRef ref) {
  final transactions = ref.watch(todayTransactionsProvider);
  return transactions
      .where((t) => t.isExpense)
      .fold<double>(0, (sum, t) => sum + t.absoluteAmount);
}

/// Provider for today's total income
@riverpod
double todayIncome(TodayIncomeRef ref) {
  final transactions = ref.watch(todayTransactionsProvider);
  return transactions
      .where((t) => t.isIncome)
      .fold<double>(0, (sum, t) => sum + t.absoluteAmount);
}

/// Provider for current month's transactions
@riverpod
List<Transaction> monthTransactions(MonthTransactionsRef ref) {
  final transactions = ref.watch(transactionNotifierProvider);
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

  return transactions.where((t) {
    return t.date.isAfter(monthStart) && t.date.isBefore(monthEnd);
  }).toList();
}

/// Provider for current month's total expenses
@riverpod
double monthExpenses(MonthExpensesRef ref) {
  final transactions = ref.watch(monthTransactionsProvider);
  return transactions
      .where((t) => t.isExpense)
      .fold<double>(0, (sum, t) => sum + t.absoluteAmount);
}

/// Provider for current month's total income
@riverpod
double monthIncome(MonthIncomeRef ref) {
  final transactions = ref.watch(monthTransactionsProvider);
  return transactions
      .where((t) => t.isIncome)
      .fold<double>(0, (sum, t) => sum + t.absoluteAmount);
}

/// Provider for month's transactions by month string (YYYY-MM)
@riverpod
List<Transaction> transactionsByMonth(TransactionsByMonthRef ref, String month) {
  final transactions = ref.watch(transactionNotifierProvider);

  final parts = month.split('-');
  final year = int.parse(parts[0]);
  final monthNum = int.parse(parts[1]);

  final monthStart = DateTime(year, monthNum, 1);
  final monthEnd = DateTime(year, monthNum + 1, 0, 23, 59, 59);

  return transactions.where((t) {
    return !t.date.isBefore(monthStart) && !t.date.isAfter(monthEnd);
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}

/// Provider for month stats by month string (YYYY-MM)
@riverpod
MonthStats monthStats(MonthStatsRef ref, String month) {
  final transactions = ref.watch(transactionsByMonthProvider(month));

  final income = transactions
      .where((t) => t.isIncome)
      .fold<double>(0, (sum, t) => sum + t.absoluteAmount);

  final expense = transactions
      .where((t) => t.isExpense)
      .fold<double>(0, (sum, t) => sum + t.absoluteAmount);

  final balance = income - expense;

  return MonthStats(
    income: income,
    expense: expense,
    balance: balance,
  );
}

/// 月度统计数据类
class MonthStats {
  const MonthStats({
    required this.income,
    required this.expense,
    required this.balance,
  });

  final double income;
  final double expense;
  final double balance;
}
