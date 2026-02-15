import 'package:isar/isar.dart';
import '../../core/constants/app_constants.dart';

part 'transaction.g.dart';

/// Transaction model for financial records
@collection
class Transaction {
  Transaction({
    required this.amount,
    required this.type,
    required this.accountId,
    this.categoryId,
    this.note,
    this.toAccountId,
    this.counterparty,
    this.counterpartyAccount,
    this.productDescription,
    this.paymentMethod,
    this.transactionStatus,
    this.externalTransactionId,
    this.merchantOrderNo,
    this.dataSource,
    required this.date,
    required this.createdAt,
  }) : id = Isar.autoIncrement;

  /// Factory constructor for creating transaction with custom date
  factory Transaction.withDate({
    required double amount,
    required int type,
    required int accountId,
    int? categoryId,
    String? note,
    int? toAccountId,
    DateTime? date,
    String? counterparty,
    String? counterpartyAccount,
    String? productDescription,
    String? paymentMethod,
    String? transactionStatus,
    String? externalTransactionId,
    String? merchantOrderNo,
    String? dataSource,
  }) {
    return Transaction._(
      id: Isar.autoIncrement,
      amount: amount,
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      note: note,
      toAccountId: toAccountId,
      date: date ?? DateTime.now(),
      createdAt: DateTime.now(),
      counterparty: counterparty,
      counterpartyAccount: counterpartyAccount,
      productDescription: productDescription,
      paymentMethod: paymentMethod,
      transactionStatus: transactionStatus,
      externalTransactionId: externalTransactionId,
      merchantOrderNo: merchantOrderNo,
      dataSource: dataSource,
    );
  }

  /// Private constructor for updating existing transaction
  Transaction._({
    required this.id,
    required this.amount,
    required this.type,
    required this.accountId,
    required this.categoryId,
    required this.note,
    required this.date,
    required this.toAccountId,
    required this.createdAt,
    this.counterparty,
    this.counterpartyAccount,
    this.productDescription,
    this.paymentMethod,
    this.transactionStatus,
    this.externalTransactionId,
    this.merchantOrderNo,
    this.dataSource,
  });

  /// Unique identifier
  final Id id;

  /// Transaction amount (always positive, use type field to determine income/expense)
  final double amount;

  /// Transaction type: 0=expense, 1=income, 2=transfer
  final int type;

  /// Account ID (source account for transfer)
  final int accountId;

  /// Category ID (null for transfers)
  final int? categoryId;

  /// Optional note
  final String? note;

  /// Transaction date
  final DateTime date;

  /// Target account ID (for transfers only)
  final int? toAccountId;

  /// Creation timestamp
  final DateTime createdAt;

  /// Counterparty name (交易对方)
  final String? counterparty;

  /// Counterparty account (对方账号) - partially masked
  final String? counterpartyAccount;

  /// Product description (商品说明)
  final String? productDescription;

  /// Payment method (收/付款方式)
  final String? paymentMethod;

  /// Transaction status (交易状态)
  final String? transactionStatus;

  /// External transaction ID (交易单号) - for deduplication
  @Index()
  final String? externalTransactionId;

  /// Merchant order number (商家订单号)
  final String? merchantOrderNo;

  /// Data source identifier (alipay, wechat, manual, etc.)
  final String? dataSource;

  /// Check if this is an expense
  bool get isExpense => type == AppConstants.transactionTypeExpense;

  /// Check if this is an income
  bool get isIncome => type == AppConstants.transactionTypeIncome;

  /// Check if this is a transfer
  bool get isTransfer => type == AppConstants.transactionTypeTransfer;

  /// Get the absolute amount
  double get absoluteAmount => amount.abs();

  /// Convert to map for export
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'accountId': accountId,
      'categoryId': categoryId,
      'note': note,
      'date': date.toIso8601String(),
      'toAccountId': toAccountId,
      'createdAt': createdAt.toIso8601String(),
      'counterparty': counterparty,
      'counterpartyAccount': counterpartyAccount,
      'productDescription': productDescription,
      'paymentMethod': paymentMethod,
      'transactionStatus': transactionStatus,
      'externalTransactionId': externalTransactionId,
      'merchantOrderNo': merchantOrderNo,
      'dataSource': dataSource,
    };
  }

  /// Create from map for import
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction._(
      id: map['id'] as int,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as int,
      accountId: map['accountId'] as int,
      categoryId: map['categoryId'] as int?,
      note: map['note'] as String?,
      date: map['date'] != null
          ? DateTime.parse(map['date'] as String)
          : DateTime.now(),
      toAccountId: map['toAccountId'] as int?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      counterparty: map['counterparty'] as String?,
      counterpartyAccount: map['counterpartyAccount'] as String?,
      productDescription: map['productDescription'] as String?,
      paymentMethod: map['paymentMethod'] as String?,
      transactionStatus: map['transactionStatus'] as String?,
      externalTransactionId: map['externalTransactionId'] as String?,
      merchantOrderNo: map['merchantOrderNo'] as String?,
      dataSource: map['dataSource'] as String?,
    );
  }

  /// Copy with method for updates
  Transaction copyWith({
    double? amount,
    int? type,
    int? accountId,
    int? categoryId,
    String? note,
    DateTime? date,
    int? toAccountId,
    String? counterparty,
    String? counterpartyAccount,
    String? productDescription,
    String? paymentMethod,
    String? transactionStatus,
    String? externalTransactionId,
    String? merchantOrderNo,
    String? dataSource,
  }) {
    return Transaction._(
      id: id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      toAccountId: toAccountId ?? this.toAccountId,
      createdAt: createdAt,
      counterparty: counterparty ?? this.counterparty,
      counterpartyAccount: counterpartyAccount ?? this.counterpartyAccount,
      productDescription: productDescription ?? this.productDescription,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionStatus: transactionStatus ?? this.transactionStatus,
      externalTransactionId: externalTransactionId ?? this.externalTransactionId,
      merchantOrderNo: merchantOrderNo ?? this.merchantOrderNo,
      dataSource: dataSource ?? this.dataSource,
    );
  }
}
