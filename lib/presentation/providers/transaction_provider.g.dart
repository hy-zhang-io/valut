// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todayTransactionsHash() => r'41a1af80b605b41233d7a4c4bf3b2448912305ce';

/// Provider for today's transactions
///
/// Copied from [todayTransactions].
@ProviderFor(todayTransactions)
final todayTransactionsProvider =
    AutoDisposeProvider<List<Transaction>>.internal(
  todayTransactions,
  name: r'todayTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodayTransactionsRef = AutoDisposeProviderRef<List<Transaction>>;
String _$todayExpensesHash() => r'59baf00cfb1346ce9f061949c9a2e244f250efc1';

/// Provider for today's total expenses
///
/// Copied from [todayExpenses].
@ProviderFor(todayExpenses)
final todayExpensesProvider = AutoDisposeProvider<double>.internal(
  todayExpenses,
  name: r'todayExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todayExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodayExpensesRef = AutoDisposeProviderRef<double>;
String _$todayIncomeHash() => r'c42a0924dbc706870a84f7da8f4e0588ad987273';

/// Provider for today's total income
///
/// Copied from [todayIncome].
@ProviderFor(todayIncome)
final todayIncomeProvider = AutoDisposeProvider<double>.internal(
  todayIncome,
  name: r'todayIncomeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todayIncomeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodayIncomeRef = AutoDisposeProviderRef<double>;
String _$monthTransactionsHash() => r'c80df6319ddf5a4e8cb50bc3dca71dbb535d0e7b';

/// Provider for current month's transactions
///
/// Copied from [monthTransactions].
@ProviderFor(monthTransactions)
final monthTransactionsProvider =
    AutoDisposeProvider<List<Transaction>>.internal(
  monthTransactions,
  name: r'monthTransactionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthTransactionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthTransactionsRef = AutoDisposeProviderRef<List<Transaction>>;
String _$monthExpensesHash() => r'e4ec546b8f3f68843e1d2156e982232b6b89fb1e';

/// Provider for current month's total expenses
///
/// Copied from [monthExpenses].
@ProviderFor(monthExpenses)
final monthExpensesProvider = AutoDisposeProvider<double>.internal(
  monthExpenses,
  name: r'monthExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$monthExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthExpensesRef = AutoDisposeProviderRef<double>;
String _$monthIncomeHash() => r'87cfeda48f6d420119e12eeda2ddb54777bf7d3f';

/// Provider for current month's total income
///
/// Copied from [monthIncome].
@ProviderFor(monthIncome)
final monthIncomeProvider = AutoDisposeProvider<double>.internal(
  monthIncome,
  name: r'monthIncomeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$monthIncomeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MonthIncomeRef = AutoDisposeProviderRef<double>;
String _$transactionsByMonthHash() =>
    r'2996753f2223fdbf0abd67f5123c2810319cda12';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for month's transactions by month string (YYYY-MM)
///
/// Copied from [transactionsByMonth].
@ProviderFor(transactionsByMonth)
const transactionsByMonthProvider = TransactionsByMonthFamily();

/// Provider for month's transactions by month string (YYYY-MM)
///
/// Copied from [transactionsByMonth].
class TransactionsByMonthFamily extends Family<List<Transaction>> {
  /// Provider for month's transactions by month string (YYYY-MM)
  ///
  /// Copied from [transactionsByMonth].
  const TransactionsByMonthFamily();

  /// Provider for month's transactions by month string (YYYY-MM)
  ///
  /// Copied from [transactionsByMonth].
  TransactionsByMonthProvider call(
    String month,
  ) {
    return TransactionsByMonthProvider(
      month,
    );
  }

  @override
  TransactionsByMonthProvider getProviderOverride(
    covariant TransactionsByMonthProvider provider,
  ) {
    return call(
      provider.month,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'transactionsByMonthProvider';
}

/// Provider for month's transactions by month string (YYYY-MM)
///
/// Copied from [transactionsByMonth].
class TransactionsByMonthProvider
    extends AutoDisposeProvider<List<Transaction>> {
  /// Provider for month's transactions by month string (YYYY-MM)
  ///
  /// Copied from [transactionsByMonth].
  TransactionsByMonthProvider(
    String month,
  ) : this._internal(
          (ref) => transactionsByMonth(
            ref as TransactionsByMonthRef,
            month,
          ),
          from: transactionsByMonthProvider,
          name: r'transactionsByMonthProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$transactionsByMonthHash,
          dependencies: TransactionsByMonthFamily._dependencies,
          allTransitiveDependencies:
              TransactionsByMonthFamily._allTransitiveDependencies,
          month: month,
        );

  TransactionsByMonthProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final String month;

  @override
  Override overrideWith(
    List<Transaction> Function(TransactionsByMonthRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TransactionsByMonthProvider._internal(
        (ref) => create(ref as TransactionsByMonthRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Transaction>> createElement() {
    return _TransactionsByMonthProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsByMonthProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TransactionsByMonthRef on AutoDisposeProviderRef<List<Transaction>> {
  /// The parameter `month` of this provider.
  String get month;
}

class _TransactionsByMonthProviderElement
    extends AutoDisposeProviderElement<List<Transaction>>
    with TransactionsByMonthRef {
  _TransactionsByMonthProviderElement(super.provider);

  @override
  String get month => (origin as TransactionsByMonthProvider).month;
}

String _$monthStatsHash() => r'd453d6ab495653e1ea18559310313726f1d82515';

/// Provider for month stats by month string (YYYY-MM)
///
/// Copied from [monthStats].
@ProviderFor(monthStats)
const monthStatsProvider = MonthStatsFamily();

/// Provider for month stats by month string (YYYY-MM)
///
/// Copied from [monthStats].
class MonthStatsFamily extends Family<MonthStats> {
  /// Provider for month stats by month string (YYYY-MM)
  ///
  /// Copied from [monthStats].
  const MonthStatsFamily();

  /// Provider for month stats by month string (YYYY-MM)
  ///
  /// Copied from [monthStats].
  MonthStatsProvider call(
    String month,
  ) {
    return MonthStatsProvider(
      month,
    );
  }

  @override
  MonthStatsProvider getProviderOverride(
    covariant MonthStatsProvider provider,
  ) {
    return call(
      provider.month,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthStatsProvider';
}

/// Provider for month stats by month string (YYYY-MM)
///
/// Copied from [monthStats].
class MonthStatsProvider extends AutoDisposeProvider<MonthStats> {
  /// Provider for month stats by month string (YYYY-MM)
  ///
  /// Copied from [monthStats].
  MonthStatsProvider(
    String month,
  ) : this._internal(
          (ref) => monthStats(
            ref as MonthStatsRef,
            month,
          ),
          from: monthStatsProvider,
          name: r'monthStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$monthStatsHash,
          dependencies: MonthStatsFamily._dependencies,
          allTransitiveDependencies:
              MonthStatsFamily._allTransitiveDependencies,
          month: month,
        );

  MonthStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final String month;

  @override
  Override overrideWith(
    MonthStats Function(MonthStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthStatsProvider._internal(
        (ref) => create(ref as MonthStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<MonthStats> createElement() {
    return _MonthStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthStatsProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MonthStatsRef on AutoDisposeProviderRef<MonthStats> {
  /// The parameter `month` of this provider.
  String get month;
}

class _MonthStatsProviderElement extends AutoDisposeProviderElement<MonthStats>
    with MonthStatsRef {
  _MonthStatsProviderElement(super.provider);

  @override
  String get month => (origin as MonthStatsProvider).month;
}

String _$transactionNotifierHash() =>
    r'7b761cbbe65fdb8483f6e98840f036a1e2c48547';

/// Provider for all transactions
///
/// Copied from [TransactionNotifier].
@ProviderFor(TransactionNotifier)
final transactionNotifierProvider = AutoDisposeNotifierProvider<
    TransactionNotifier, List<Transaction>>.internal(
  TransactionNotifier.new,
  name: r'transactionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$transactionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TransactionNotifier = AutoDisposeNotifier<List<Transaction>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
