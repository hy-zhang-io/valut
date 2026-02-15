import 'package:flutter/material.dart';
import '../utils/responsive.dart' show DeviceType;

/// App Color Scheme for Material Design 3
///
/// 遵循 README.md 中的设计规范
class AppColors {
  AppColors._();

  // ==================== 深色主题颜色 ====================
  // 主色：#B39DDB（用于主要按钮和强调元素）
  static const Color darkPrimary = Color(0xFFB39DDB);

  // 辅助色：#4285F4（用于浮动按钮和次要元素）
  static const Color darkSecondary = Color(0xFF4285F4);

  // 三级色：#34A853（用于成功状态和正向反馈/收入）
  static const Color darkTertiary = Color(0xFF34A853);

  // 表面色：#2D2D2D（卡片和底板背景）
  static const Color darkSurface = Color(0xFF2D2D2D);

  // 背景色：#1F1F1F（整体页面背景）
  static const Color darkBackground = Color(0xFF1F1F1F);

  // 表面上的文字颜色：#E8E8E8
  static const Color darkOnSurface = Color(0xFFE8E8E8);

  // 边框和分隔线颜色：#4A4A4A
  static const Color darkOutline = Color(0xFF4A4A4A);

  // 深色主题额外颜色
  static const Color darkSurfaceVariant = Color(0xFF2E2E2E);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);

  // ==================== 浅色主题颜色 ====================
  // 主色：#7B4BDB
  static const Color lightPrimary = Color(0xFF7B4BDB);

  // 辅助色：#1A73E8
  static const Color lightSecondary = Color(0xFF1A73E8);

  // 三级色：#0F9D58
  static const Color lightTertiary = Color(0xFF0F9D58);

  // 表面色：#FFFFFF
  static const Color lightSurface = Color(0xFFFFFFFF);

  // 背景色：#FAFAFA
  static const Color lightBackground = Color(0xFFFAFAFA);

  // 表面上的文字颜色：#1F1F1F
  static const Color lightOnSurface = Color(0xFF1F1F1F);

  // 边框和分隔线颜色：#E0E0E0
  static const Color lightOutline = Color(0xFFE0E0E0);

  // 浅色主题额外颜色
  static const Color lightSurfaceVariant = Color(0xFFE3E3E3);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);

  // ==================== 语义化颜色 ====================
  // 成功/收入：#10B981（绿色）
  static const Color success = Color(0xFF10B981);

  // 警告：#F59E0B
  static const Color warning = Color(0xFFF59E0B);

  // 错误/支出：#EF4444（红色）
  static const Color error = Color(0xFFEF4444);

  // 信息：#3B82F6
  static const Color info = Color(0xFF3B82F6);

  // 收入（浅色主题）
  static const Color incomeLight = Color(0xFF10B981);

  // 支出（浅色主题）
  static const Color expenseLight = Color(0xFFEF4444);

  // ==================== Material Design 3 颜色方案 ====================

  /// 深色主题颜色方案
  static ColorScheme get darkColorScheme {
    return const ColorScheme.dark(
      primary: darkPrimary,
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFF3E2F5F),
      onPrimaryContainer: Color(0xFFEADDFF),
      secondary: darkSecondary,
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFF29428F),
      onSecondaryContainer: Color(0xFFD8E6FF),
      tertiary: darkTertiary,
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFF1D4D3E),
      onTertiaryContainer: Color(0xFFA1F7D6),
      error: error,
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: darkSurface,
      onSurface: darkOnSurface,
      surfaceContainerHighest: Color(0xFF3A3A3A),
      outline: darkOutline,
      outlineVariant: Color(0xFF49454F),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFFB39DDB),
    );
  }

  /// 浅色主题颜色方案
  static ColorScheme get lightColorScheme {
    return const ColorScheme.light(
      primary: lightPrimary,
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFEADDFF),
      onPrimaryContainer: Color(0xFF21005D),
      secondary: lightSecondary,
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFD8E6FF),
      onSecondaryContainer: Color(0xFF001F29),
      tertiary: lightTertiary,
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFA1F7D6),
      onTertiaryContainer: Color(0xFF00211D),
      error: error,
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: lightSurface,
      onSurface: lightOnSurface,
      surfaceContainerHighest: Color(0xFFEBEBEB),
      outline: lightOutline,
      outlineVariant: Color(0xFFCAC4D0),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFF313033),
      onInverseSurface: Color(0xFFF4EFF4),
      inversePrimary: Color(0xFF7B4BDB),
    );
  }

  /// 根据亮度获取颜色方案
  static ColorScheme getColorScheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkColorScheme : lightColorScheme;
  }

  /// 根据设备类型获取颜色方案（折叠屏使用特殊配色）
  static ColorScheme getColorSchemeForDevice(
    Brightness brightness,
    DeviceType deviceType,
  ) {
    // 折叠屏可以使用更丰富的配色
    if (deviceType == DeviceType.foldable) {
      return getColorScheme(brightness);
    }
    return getColorScheme(brightness);
  }
}

/// Category colors for transaction categories
class CategoryColors {
  CategoryColors._();

  static const List<Color> colors = [
    Color(0xFFEA4335), // Red
    Color(0xFFFBBC04), // Yellow
    Color(0xFF34A853), // Green
    Color(0xFF4285F4), // Blue
    Color(0xFF7B4BDB), // Purple
    Color(0xFFFF6D01), // Orange
    Color(0xFF46BDC6), // Teal
    Color(0xFFF78CAB), // Pink
    Color(0xFF8D6E63), // Brown
    Color(0xFF607D8B), // Blue Grey
  ];

  static Color getColor(int index) {
    return colors[index % colors.length];
  }
}
