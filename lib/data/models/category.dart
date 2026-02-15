import 'package:isar/isar.dart';
import '../../core/constants/app_constants.dart';

part 'category.g.dart';

/// Category model for transaction categories
@collection
class Category {
  Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.sortOrder = 0,
    this.isBuiltIn = false,
  })  : id = Isar.autoIncrement,
        createdAt = DateTime.now();

  /// Private constructor for updating existing category
  Category._({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.sortOrder,
    required this.isBuiltIn,
    required this.createdAt,
  });

  /// Unique identifier
  final Id id;

  /// Category name (e.g., "餐饮", "交通")
  final String name;

  /// Icon code point (Material Icons)
  final int icon;

  /// Color index from CategoryColors
  final int color;

  /// Transaction type: 0=expense, 1=income
  final int type;

  /// Sort order for display
  final int sortOrder;

  /// Whether this is a built-in category
  final bool isBuiltIn;

  /// Creation timestamp
  final DateTime createdAt;

  /// Check if this is an expense category
  bool get isExpense => type == AppConstants.transactionTypeExpense;

  /// Check if this is an income category
  bool get isIncome => type == AppConstants.transactionTypeIncome;

  /// Convert to map for export
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
      'sortOrder': sortOrder,
      'isBuiltIn': isBuiltIn,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from map for import
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category._(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as int,
      color: map['color'] as int,
      type: map['type'] as int,
      sortOrder: map['sortOrder'] as int? ?? 0,
      isBuiltIn: map['isBuiltIn'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Copy with method for updates
  Category copyWith({
    String? name,
    int? icon,
    int? color,
    int? type,
    int? sortOrder,
    bool? isBuiltIn,
  }) {
    return Category._(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt,
    );
  }

  /// Category colors
  static const List<int> categoryColors = [
    0xFF2196F3, // blue
    0xFF4CAF50, // green
    0xFFFF9800, // orange
    0xFFE91E63, // pink
    0xFF9C27B0, // purple
    0xFF00BCD4, // cyan
    0xFFFF5722, // deep orange
    0xFF3F51B5, // indigo
  ];

  /// Built-in expense categories
  static List<Category> builtInExpenseCategories() {
    return [
      Category._(
        id: 1,
        name: '日常花销',
        icon: 0xe8cc, // shopping_cart
        color: 0,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 0,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 2,
        name: '房租/还款',
        icon: 0xe8af, // home
        color: 1,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 1,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 3,
        name: '保费缴纳',
        icon: 0xe3ac, // shield
        color: 2,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 2,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 4,
        name: '兴趣爱好',
        icon: 0xe405, // sports_esports
        color: 3,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 3,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 5,
        name: '孩子花费',
        icon: 0xe0b6, // child_care
        color: 4,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 4,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 6,
        name: '生活缴费',
        icon: 0xe7f4, // receipt_long
        color: 5,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 5,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 7,
        name: '交通通勤',
        icon: 0xe548, // directions_car
        color: 6,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 6,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 8,
        name: '医疗支出',
        icon: 0xe565, // medical_services
        color: 7,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 7,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 9,
        name: '养宠物',
        icon: 0xe8d0, // pets
        color: 0,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 8,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 10,
        name: '人情送礼',
        icon: 0xe8f0, // card_giftcard
        color: 1,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 9,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 999,
        name: '自定义',
        icon: 0xe145, // add
        color: 2,
        type: AppConstants.transactionTypeExpense,
        sortOrder: 100,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Built-in income categories
  static List<Category> builtInIncomeCategories() {
    return [
      Category._(
        id: 101,
        name: '工资',
        icon: 0xe24f, // payments
        color: 2,
        type: AppConstants.transactionTypeIncome,
        sortOrder: 0,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 102,
        name: '奖金',
        icon: 0xe8dc, // redeem
        color: 2,
        type: AppConstants.transactionTypeIncome,
        sortOrder: 1,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 104,
        name: '兼职',
        icon: 0xe23a, // work
        color: 4,
        type: AppConstants.transactionTypeIncome,
        sortOrder: 3,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 105,
        name: '礼金',
        icon: 0xe8f0, // card_giftcard
        color: 5,
        type: AppConstants.transactionTypeIncome,
        sortOrder: 4,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
      Category._(
        id: 106,
        name: '其他',
        icon: 0xe8b8, // more_horiz
        color: 6,
        type: AppConstants.transactionTypeIncome,
        sortOrder: 99,
        isBuiltIn: true,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
