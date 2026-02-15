import 'package:isar/isar.dart';

part 'account.g.dart';

/// Account model for storing financial accounts
@collection
class Account {
  Account({
    required this.name,
    required this.icon,
    required this.color,
    required this.balance,
    this.isHidden = false,
    this.initialBalance = 0,
  })  : id = Isar.autoIncrement,
        createdAt = DateTime.now();

  /// Private constructor for updating existing account
  Account._({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.balance,
    required this.isHidden,
    required this.initialBalance,
    required this.createdAt,
  });

  /// Unique identifier
  final Id id;

  /// Account name (e.g., "现金", "招商银行")
  final String name;

  /// Icon code point (Material Icons)
  final int icon;

  /// Color index from CategoryColors
  final int color;

  /// Current balance
  final double balance;

  /// Initial balance for calculations
  final double initialBalance;

  /// Whether this account is hidden from statistics
  final bool isHidden;

  /// Creation timestamp
  final DateTime createdAt;

  /// Convert to map for export
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'balance': balance,
      'initialBalance': initialBalance,
      'isHidden': isHidden,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create from map for import
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account._(
      id: map['id'] as int,
      name: map['name'] as String,
      icon: map['icon'] as int,
      color: map['color'] as int,
      balance: (map['balance'] as num).toDouble(),
      initialBalance: (map['initialBalance'] as num?)?.toDouble() ?? 0,
      isHidden: map['isHidden'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Copy with method for updates
  Account copyWith({
    String? name,
    int? icon,
    int? color,
    double? balance,
    double? initialBalance,
    bool? isHidden,
  }) {
    return Account._(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      balance: balance ?? this.balance,
      initialBalance: initialBalance ?? this.initialBalance,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt,
    );
  }
}
