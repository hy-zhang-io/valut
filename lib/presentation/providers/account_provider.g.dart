// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$totalAssetsHash() => r'ccdadf8edc612c2501236fc75631aac42d6fa9cd';

/// Provider for total assets (sum of all account balances)
///
/// Copied from [totalAssets].
@ProviderFor(totalAssets)
final totalAssetsProvider = AutoDisposeProvider<double>.internal(
  totalAssets,
  name: r'totalAssetsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$totalAssetsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TotalAssetsRef = AutoDisposeProviderRef<double>;
String _$visibleAccountsHash() => r'bc325c36b4f867d3105c0f4da4b97aebdfaa8d9f';

/// Provider for visible accounts (not hidden)
///
/// Copied from [visibleAccounts].
@ProviderFor(visibleAccounts)
final visibleAccountsProvider = AutoDisposeProvider<List<Account>>.internal(
  visibleAccounts,
  name: r'visibleAccountsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$visibleAccountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef VisibleAccountsRef = AutoDisposeProviderRef<List<Account>>;
String _$accountNotifierHash() => r'8ccf198a24a3d7621f3b5d3a20183873874b7507';

/// Provider for all accounts
///
/// Copied from [AccountNotifier].
@ProviderFor(AccountNotifier)
final accountNotifierProvider =
    AutoDisposeNotifierProvider<AccountNotifier, List<Account>>.internal(
  AccountNotifier.new,
  name: r'accountNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountNotifier = AutoDisposeNotifier<List<Account>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
