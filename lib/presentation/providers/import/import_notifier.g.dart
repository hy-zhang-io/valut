// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryNameByIdHash() => r'fa7f6d0c5c4e7ac20e4baae251da5939441d3837';

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

/// Provider for getting category name by ID
///
/// Copied from [categoryNameById].
@ProviderFor(categoryNameById)
const categoryNameByIdProvider = CategoryNameByIdFamily();

/// Provider for getting category name by ID
///
/// Copied from [categoryNameById].
class CategoryNameByIdFamily extends Family<String> {
  /// Provider for getting category name by ID
  ///
  /// Copied from [categoryNameById].
  const CategoryNameByIdFamily();

  /// Provider for getting category name by ID
  ///
  /// Copied from [categoryNameById].
  CategoryNameByIdProvider call(
    int? categoryId,
  ) {
    return CategoryNameByIdProvider(
      categoryId,
    );
  }

  @override
  CategoryNameByIdProvider getProviderOverride(
    covariant CategoryNameByIdProvider provider,
  ) {
    return call(
      provider.categoryId,
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
  String? get name => r'categoryNameByIdProvider';
}

/// Provider for getting category name by ID
///
/// Copied from [categoryNameById].
class CategoryNameByIdProvider extends AutoDisposeProvider<String> {
  /// Provider for getting category name by ID
  ///
  /// Copied from [categoryNameById].
  CategoryNameByIdProvider(
    int? categoryId,
  ) : this._internal(
          (ref) => categoryNameById(
            ref as CategoryNameByIdRef,
            categoryId,
          ),
          from: categoryNameByIdProvider,
          name: r'categoryNameByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryNameByIdHash,
          dependencies: CategoryNameByIdFamily._dependencies,
          allTransitiveDependencies:
              CategoryNameByIdFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CategoryNameByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.categoryId,
  }) : super.internal();

  final int? categoryId;

  @override
  Override overrideWith(
    String Function(CategoryNameByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryNameByIdProvider._internal(
        (ref) => create(ref as CategoryNameByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        categoryId: categoryId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _CategoryNameByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryNameByIdProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryNameByIdRef on AutoDisposeProviderRef<String> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;
}

class _CategoryNameByIdProviderElement
    extends AutoDisposeProviderElement<String> with CategoryNameByIdRef {
  _CategoryNameByIdProviderElement(super.provider);

  @override
  int? get categoryId => (origin as CategoryNameByIdProvider).categoryId;
}

String _$alipayImportNotifierHash() =>
    r'87e806151d57378212e9e2f14a8e565a2b7f48db';

/// Provider for Alipay import operations
///
/// Copied from [AlipayImportNotifier].
@ProviderFor(AlipayImportNotifier)
final alipayImportNotifierProvider =
    AutoDisposeNotifierProvider<AlipayImportNotifier, ImportState>.internal(
  AlipayImportNotifier.new,
  name: r'alipayImportNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$alipayImportNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AlipayImportNotifier = AutoDisposeNotifier<ImportState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
