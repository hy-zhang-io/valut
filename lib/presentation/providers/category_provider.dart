import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/category.dart';

part 'category_provider.g.dart';

/// Provider for custom category names
@riverpod
class CustomCategoryNames extends _$CustomCategoryNames {
  @override
  List<String> build() {
    return [];
  }

  void addCategory(String name) {
    if (!state.contains(name)) {
      state = [...state, name];
    }
  }

  void removeCategory(String name) {
    state = state.where((n) => n != name).toList();
  }
}

/// Provider for expense categories
@riverpod
List<Category> expenseCategories(ExpenseCategoriesRef ref) {
  final customNames = ref.watch(customCategoryNamesProvider);
  final builtIn = Category.builtInExpenseCategories();

  // Remove the "自定义" placeholder and add actual custom categories
  final withoutCustom = builtIn.where((c) => c.name != '自定义').toList();

  // Add custom categories
  final customCategories = <Category>[];
  for (int i = 0; i < customNames.length; i++) {
    customCategories.add(Category(
      name: customNames[i],
      icon: 0xe8b8, // more_horiz
      color: i % 8,
      type: 0, // expense
      sortOrder: 100 + i,
      isBuiltIn: false,
    ));
  }

  return [...withoutCustom, ...customCategories];
}

/// Provider for income categories
@riverpod
List<Category> incomeCategories(IncomeCategoriesRef ref) {
  final categories = Category.builtInIncomeCategories();
  return categories;
}

/// Provider for categories by transaction type
@riverpod
List<Category> categoriesByType(CategoriesByTypeRef ref, int transactionType) {
  if (transactionType == 0) {
    // Expense
    return ref.watch(expenseCategoriesProvider);
  } else if (transactionType == 1) {
    // Income
    return Category.builtInIncomeCategories();
  }
  // Transfer doesn't use categories
  return [];
}

/// Provider for getting category by ID
@riverpod
Category? categoryById(CategoryByIdRef ref, int? categoryId) {
  if (categoryId == null) return null;
  final allCategories = [
    ...ref.watch(expenseCategoriesProvider),
    ...ref.watch(incomeCategoriesProvider),
  ];
  try {
    return allCategories.firstWhere((c) => c.id == categoryId);
  } catch (_) {
    return null;
  }
}
