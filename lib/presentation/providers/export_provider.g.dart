// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentExportRecordsHash() =>
    r'd9c223188fe9c53c2a7d4f5b6a7e3ead95a0177e';

/// 获取近7天导出记录
///
/// Copied from [recentExportRecords].
@ProviderFor(recentExportRecords)
final recentExportRecordsProvider =
    AutoDisposeFutureProvider<List<ExportRecord>>.internal(
  recentExportRecords,
  name: r'recentExportRecordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentExportRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentExportRecordsRef
    = AutoDisposeFutureProviderRef<List<ExportRecord>>;
String _$exportRecordCountHash() => r'f61cbf59d5ee77ce16e14bc2deb8fe15e7842b1d';

/// 获取导出记录数量
///
/// Copied from [exportRecordCount].
@ProviderFor(exportRecordCount)
final exportRecordCountProvider = AutoDisposeFutureProvider<int>.internal(
  exportRecordCount,
  name: r'exportRecordCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exportRecordCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExportRecordCountRef = AutoDisposeFutureProviderRef<int>;
String _$exportNotifierHash() => r'bf654ad6554ba73f4476c141e9fa8b50828ac521';

/// 导出记录Provider
///
/// Copied from [ExportNotifier].
@ProviderFor(ExportNotifier)
final exportNotifierProvider =
    AutoDisposeNotifierProvider<ExportNotifier, ExportState>.internal(
  ExportNotifier.new,
  name: r'exportNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exportNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExportNotifier = AutoDisposeNotifier<ExportState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
