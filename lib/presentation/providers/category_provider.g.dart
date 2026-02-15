// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$expenseCategoriesHash() => r'c99cab52516f5c356d9b99d54a3da9d8889489d9';

/// Provider for expense categories
///
/// Copied from [expenseCategories].
@ProviderFor(expenseCategories)
final expenseCategoriesProvider = AutoDisposeProvider<List<Category>>.internal(
  expenseCategories,
  name: r'expenseCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$expenseCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ExpenseCategoriesRef = AutoDisposeProviderRef<List<Category>>;
String _$incomeCategoriesHash() => r'761b894196362e76c06e0f30f4dd7043f3e3436a';

/// Provider for income categories
///
/// Copied from [incomeCategories].
@ProviderFor(incomeCategories)
final incomeCategoriesProvider = AutoDisposeProvider<List<Category>>.internal(
  incomeCategories,
  name: r'incomeCategoriesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$incomeCategoriesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IncomeCategoriesRef = AutoDisposeProviderRef<List<Category>>;
String _$categoriesByTypeHash() => r'9d324dc02170fcf80e1b2255815fe5504b13d9fa';

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

/// Provider for categories by transaction type
///
/// Copied from [categoriesByType].
@ProviderFor(categoriesByType)
const categoriesByTypeProvider = CategoriesByTypeFamily();

/// Provider for categories by transaction type
///
/// Copied from [categoriesByType].
class CategoriesByTypeFamily extends Family<List<Category>> {
  /// Provider for categories by transaction type
  ///
  /// Copied from [categoriesByType].
  const CategoriesByTypeFamily();

  /// Provider for categories by transaction type
  ///
  /// Copied from [categoriesByType].
  CategoriesByTypeProvider call(
    int transactionType,
  ) {
    return CategoriesByTypeProvider(
      transactionType,
    );
  }

  @override
  CategoriesByTypeProvider getProviderOverride(
    covariant CategoriesByTypeProvider provider,
  ) {
    return call(
      provider.transactionType,
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
  String? get name => r'categoriesByTypeProvider';
}

/// Provider for categories by transaction type
///
/// Copied from [categoriesByType].
class CategoriesByTypeProvider extends AutoDisposeProvider<List<Category>> {
  /// Provider for categories by transaction type
  ///
  /// Copied from [categoriesByType].
  CategoriesByTypeProvider(
    int transactionType,
  ) : this._internal(
          (ref) => categoriesByType(
            ref as CategoriesByTypeRef,
            transactionType,
          ),
          from: categoriesByTypeProvider,
          name: r'categoriesByTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoriesByTypeHash,
          dependencies: CategoriesByTypeFamily._dependencies,
          allTransitiveDependencies:
              CategoriesByTypeFamily._allTransitiveDependencies,
          transactionType: transactionType,
        );

  CategoriesByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.transactionType,
  }) : super.internal();

  final int transactionType;

  @override
  Override overrideWith(
    List<Category> Function(CategoriesByTypeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoriesByTypeProvider._internal(
        (ref) => create(ref as CategoriesByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        transactionType: transactionType,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Category>> createElement() {
    return _CategoriesByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoriesByTypeProvider &&
        other.transactionType == transactionType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, transactionType.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoriesByTypeRef on AutoDisposeProviderRef<List<Category>> {
  /// The parameter `transactionType` of this provider.
  int get transactionType;
}

class _CategoriesByTypeProviderElement
    extends AutoDisposeProviderElement<List<Category>>
    with CategoriesByTypeRef {
  _CategoriesByTypeProviderElement(super.provider);

  @override
  int get transactionType =>
      (origin as CategoriesByTypeProvider).transactionType;
}

String _$categoryByIdHash() => r'19412ca8889f2af2e611538d551532a2cae29796';

/// Provider for getting category by ID
///
/// Copied from [categoryById].
@ProviderFor(categoryById)
const categoryByIdProvider = CategoryByIdFamily();

/// Provider for getting category by ID
///
/// Copied from [categoryById].
class CategoryByIdFamily extends Family<Category?> {
  /// Provider for getting category by ID
  ///
  /// Copied from [categoryById].
  const CategoryByIdFamily();

  /// Provider for getting category by ID
  ///
  /// Copied from [categoryById].
  CategoryByIdProvider call(
    int? categoryId,
  ) {
    return CategoryByIdProvider(
      categoryId,
    );
  }

  @override
  CategoryByIdProvider getProviderOverride(
    covariant CategoryByIdProvider provider,
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
  String? get name => r'categoryByIdProvider';
}

/// Provider for getting category by ID
///
/// Copied from [categoryById].
class CategoryByIdProvider extends AutoDisposeProvider<Category?> {
  /// Provider for getting category by ID
  ///
  /// Copied from [categoryById].
  CategoryByIdProvider(
    int? categoryId,
  ) : this._internal(
          (ref) => categoryById(
            ref as CategoryByIdRef,
            categoryId,
          ),
          from: categoryByIdProvider,
          name: r'categoryByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$categoryByIdHash,
          dependencies: CategoryByIdFamily._dependencies,
          allTransitiveDependencies:
              CategoryByIdFamily._allTransitiveDependencies,
          categoryId: categoryId,
        );

  CategoryByIdProvider._internal(
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
    Category? Function(CategoryByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CategoryByIdProvider._internal(
        (ref) => create(ref as CategoryByIdRef),
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
  AutoDisposeProviderElement<Category?> createElement() {
    return _CategoryByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryByIdProvider && other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, categoryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CategoryByIdRef on AutoDisposeProviderRef<Category?> {
  /// The parameter `categoryId` of this provider.
  int? get categoryId;
}

class _CategoryByIdProviderElement extends AutoDisposeProviderElement<Category?>
    with CategoryByIdRef {
  _CategoryByIdProviderElement(super.provider);

  @override
  int? get categoryId => (origin as CategoryByIdProvider).categoryId;
}

String _$customCategoryNamesHash() =>
    r'13c5971846adbefff263850e8dac379d2342718e';

/// Provider for custom category names
///
/// Copied from [CustomCategoryNames].
@ProviderFor(CustomCategoryNames)
final customCategoryNamesProvider =
    AutoDisposeNotifierProvider<CustomCategoryNames, List<String>>.internal(
  CustomCategoryNames.new,
  name: r'customCategoryNamesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$customCategoryNamesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CustomCategoryNames = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
