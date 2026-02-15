import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/account.dart';
import 'database_provider.dart';

part 'account_provider.g.dart';

/// Provider for all accounts
@riverpod
class AccountNotifier extends _$AccountNotifier {
  @override
  List<Account> build() {
    _loadAccounts();
    return [];
  }

  Future<void> _loadAccounts() async {
    final db = ref.watch(databaseServiceProvider);
    if (!db.isInitialized) return;

    // Get all accounts by iterating
    final accounts = <Account>[];
    int id = 1;
    while (true) {
      final account = await db.isar.accounts.get(id);
      if (account == null) break;
      accounts.add(account);
      id++;
    }
    state = accounts;
  }

  Future<void> addAccount(Account account) async {
    final db = ref.watch(databaseServiceProvider);
    await db.isar.writeTxn(() async {
      await db.isar.accounts.put(account);
    });
    await _loadAccounts();
  }

  Future<void> updateAccount(Account account) async {
    final db = ref.watch(databaseServiceProvider);
    await db.isar.writeTxn(() async {
      await db.isar.accounts.put(account);
    });
    await _loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    final db = ref.watch(databaseServiceProvider);
    await db.isar.writeTxn(() async {
      await db.isar.accounts.delete(id);
    });
    await _loadAccounts();
  }

  Future<Account?> getAccount(int id) async {
    final db = ref.watch(databaseServiceProvider);
    return await db.isar.accounts.get(id);
  }
}

/// Provider for total assets (sum of all account balances)
@riverpod
double totalAssets(TotalAssetsRef ref) {
  final accounts = ref.watch(accountNotifierProvider);
  return accounts.fold<double>(0, (sum, account) => sum + account.balance);
}

/// Provider for visible accounts (not hidden)
@riverpod
List<Account> visibleAccounts(VisibleAccountsRef ref) {
  final accounts = ref.watch(accountNotifierProvider);
  return accounts.where((account) => !account.isHidden).toList();
}
