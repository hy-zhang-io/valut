import 'dart:math';
import 'package:isar/isar.dart';
import '../../core/constants/app_constants.dart';

part 'settings.g.dart';

/// App settings model
@collection
class Settings {
  Settings({
    this.themeMode = 0, // 0=system, 1=light, 2=dark
    this.currency = AppConstants.defaultCurrency,
    this.isBiometricEnabled = false,
    this.autoLockDelaySeconds = AppConstants.defaultAutoLockDelaySeconds,
    this.defaultAccountId,
    this.deviceId = '',
  })  : id = 1, // Single settings instance with id=1
        updatedAt = DateTime.now();

  /// Private constructor for updating existing settings
  Settings._({
    required this.id,
    required this.themeMode,
    required this.currency,
    required this.isBiometricEnabled,
    required this.autoLockDelaySeconds,
    required this.defaultAccountId,
    required this.deviceId,
    required this.updatedAt,
  });

  /// Generate a random 4-character device ID
  static String generateDeviceId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(4, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Unique identifier (always 1 for singleton)
  final Id id;

  /// Theme mode: 0=system, 1=light, 2=dark
  final int themeMode;

  /// Currency code (e.g., 'CNY', 'USD')
  final String currency;

  /// Whether biometric authentication is enabled
  final bool isBiometricEnabled;

  /// Auto-lock delay in seconds
  final int autoLockDelaySeconds;

  /// Default account ID for new transactions
  final int? defaultAccountId;

  /// Device unique identifier (4 characters, empty means not yet generated)
  final String deviceId;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Check if device ID is generated
  bool get hasDeviceId => deviceId.isNotEmpty;

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'themeMode': themeMode,
      'currency': currency,
      'isBiometricEnabled': isBiometricEnabled,
      'autoLockDelaySeconds': autoLockDelaySeconds,
      'defaultAccountId': defaultAccountId,
      'deviceId': deviceId,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from map
  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings._(
      id: map['id'] as int? ?? 1,
      themeMode: map['themeMode'] as int? ?? 0,
      currency: map['currency'] as String? ?? AppConstants.defaultCurrency,
      isBiometricEnabled: map['isBiometricEnabled'] as bool? ?? false,
      autoLockDelaySeconds:
          map['autoLockDelaySeconds'] as int? ?? AppConstants.defaultAutoLockDelaySeconds,
      defaultAccountId: map['defaultAccountId'] as int?,
      deviceId: map['deviceId'] as String? ?? '',
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  /// Copy with method
  Settings copyWith({
    int? themeMode,
    String? currency,
    bool? isBiometricEnabled,
    int? autoLockDelaySeconds,
    int? defaultAccountId,
    String? deviceId,
  }) {
    return Settings._(
      id: id,
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      autoLockDelaySeconds: autoLockDelaySeconds ?? this.autoLockDelaySeconds,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      deviceId: deviceId ?? this.deviceId,
      updatedAt: DateTime.now(),
    );
  }

  /// Create default settings
  factory Settings.defaultSettings() {
    return Settings();
  }
}
