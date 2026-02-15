/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'VAULT';
  static const String appTagline = '极致隐私离线记账';
  static const String appVersion = '1.0.0';

  // Animation Durations (ms)
  static const int animationDurationMedium = 300;
  static const int animationDurationShort = 200;
  static const int animationDurationFast = 100;

  // Animation Curves
  static const String animationCurve = 'cubic-bezier(0.2, 0, 0, 1)';

  // Easing
  static const double animationScaleStart = 1.0;
  static const double animationScaleExpand = 1.02;

  // Dimensions (dp)
  static const double cardBorderRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double fabSize = 56.0;
  static const double inputBorderRadius = 12.0;
  static const double chipHeight = 32.0;
  static const double bottomSheetMaxHeight = 0.9;

  // Font Sizes (sp)
  static const double fontSizeDisplayLarge = 64.0;
  static const double fontSizeHeadlineLarge = 32.0;
  static const double fontSizeTitleLarge = 22.0;
  static const double fontSizeBodyLarge = 16.0;
  static const double fontSizeLabelLarge = 14.0;
  static const double fontSizeCaption = 12.0;

  // Transaction Types
  static const int transactionTypeExpense = 0;
  static const int transactionTypeIncome = 1;
  static const int transactionTypeTransfer = 2;

  // Note Length
  static const int maxNoteLength = 50;

  // Storage Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyIsBiometricEnabled = 'is_biometric_enabled';
  static const String keyAutoLockDelay = 'auto_lock_delay';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrency = 'currency';
  static const String keyDefaultAccountId = 'default_account_id';

  // Default Values
  static const int defaultAutoLockDelaySeconds = 30; // 30 seconds
  static const String defaultCurrency = 'CNY';
}

/// Currency symbols
class CurrencySymbols {
  CurrencySymbols._();

  static const Map<String, String> symbols = {
    'CNY': '¥',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'HKD': 'HK\$',
    'TWD': 'NT\$',
  };

  static String getSymbol(String currency) =>
      symbols[currency] ?? symbols['CNY']!;
}

/// Transaction type utilities
class TransactionType {
  TransactionType._();

  static String getTypeLabel(int type) {
    switch (type) {
      case AppConstants.transactionTypeExpense:
        return '支出';
      case AppConstants.transactionTypeIncome:
        return '收入';
      case AppConstants.transactionTypeTransfer:
        return '转账';
      default:
        return '未知';
    }
  }
}
