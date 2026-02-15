import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Formatters for displaying data
class Formatters {
  Formatters._();

  static final NumberFormat currencyFormat = NumberFormat.currency(
    symbol: CurrencySymbols.getSymbol(AppConstants.defaultCurrency),
    decimalDigits: 2,
  );

  static final NumberFormat numberFormat = NumberFormat.decimalPattern();

  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat monthFormat = DateFormat('yyyy年MM月');
  static final DateFormat monthDayFormat = DateFormat('MM月dd日');

  /// Format amount as currency
  static String formatCurrency(double amount, {String? currency}) {
    final symbol = CurrencySymbols.getSymbol(
      currency ?? AppConstants.defaultCurrency,
    );
    final formatted = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    ).format(amount.abs());
    return amount < 0 ? '-$formatted' : formatted;
  }

  /// Format amount with compact notation (e.g., 1.2K, 1.5M)
  static String formatCompactCurrency(double amount, {String? currency}) {
    final symbol = CurrencySymbols.getSymbol(
      currency ?? AppConstants.defaultCurrency,
    );
    final absAmount = amount.abs();

    String compact;
    if (absAmount >= 100000000) {
      compact = '${(absAmount / 100000000).toStringAsFixed(2)}亿';
    } else if (absAmount >= 10000) {
      compact = '${(absAmount / 10000).toStringAsFixed(2)}万';
    } else {
      compact = absAmount.toStringAsFixed(2);
    }

    final prefix = amount < 0 ? '-' : '';
    return '$prefix$symbol$compact';
  }

  /// Format date
  static String formatDate(DateTime date) {
    return dateFormat.format(date);
  }

  /// Format time
  static String formatTime(DateTime date) {
    return timeFormat.format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime date) {
    return dateTimeFormat.format(date);
  }

  /// Format month
  static String formatMonth(DateTime date) {
    return monthFormat.format(date);
  }

  /// Format month and day
  static String formatMonthDay(DateTime date) {
    return monthDayFormat.format(date);
  }

  /// Get relative time string (e.g., "今天", "昨天", "3天前")
  static String getRelativeTimeString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(targetDay).inDays;

    if (difference == 0) {
      return '今天';
    } else if (difference == 1) {
      return '昨天';
    } else if (difference < 7) {
      return '$difference天前';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks周前';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '$months个月前';
    } else {
      final years = (difference / 365).floor();
      return '$years年前';
    }
  }

  /// Format number with thousand separator
  static String formatNumber(double number) {
    return numberFormat.format(number);
  }

  /// Format percentage
  static String formatPercentage(double value, {int decimalDigits = 1}) {
    return '${(value * 100).toStringAsFixed(decimalDigits)}%';
  }
}
