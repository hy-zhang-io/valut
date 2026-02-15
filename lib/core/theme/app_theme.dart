import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 深色主题 - 智能记账本
class AppTheme {
  // 主色调
  static const Color primaryColor = Color(0xFF4CAF50); // 清新的绿色
  static const Color onPrimaryColor = Colors.white;
  
  // 支出/收入颜色
  static const Color expenseColor = Color(0xFFEF5350); // 柔和的红色
  static const Color incomeColor = Color(0xFF66BB6A); // 柔和的绿色
  
  // 深色背景
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  static const Color surfaceContainer = Color(0xFF252525);
  
  // 文字颜色
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceVariant = Color(0xFF9E9E9E);
  static const Color outline = Color(0xFF404040);
  
  // 导航栏宽度
  static const double navigationRailWidth = 280;
  static const double navigationRailCollapsedWidth = 80;

  static ThemeData getDarkTheme() {
    final colorScheme = const ColorScheme.dark(
      primary: primaryColor,
      onPrimary: onPrimaryColor,
      secondary: Color(0xFF81C784),
      onSecondary: Colors.black,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      error: expenseColor,
      onError: Colors.white,
      outline: outline,
      shadow: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.notoSans().fontFamily,
      
      // AppBar 主题
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 底部导航栏主题
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        height: 80,
        indicatorColor: primaryColor.withValues(alpha: 0.2),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryColor);
          }
          return IconThemeData(color: onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            );
          }
          return GoogleFonts.notoSans(
            fontSize: 12,
            color: onSurfaceVariant,
          );
        }),
      ),
      
      // 导航Rail主题
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        elevation: 0,
        selectedIconTheme: const IconThemeData(color: primaryColor),
        selectedLabelTextStyle: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        unselectedIconTheme: IconThemeData(color: onSurfaceVariant),
        unselectedLabelTextStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: onSurfaceVariant,
        ),
        indicatorColor: primaryColor.withValues(alpha: 0.2),
      ),
      
      // 底部Sheet主题
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      
      // FAB主题
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: expenseColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      // 列表瓦片主题
      listTileTheme: ListTileThemeData(
        tileColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // 分割线主题
      dividerTheme: const DividerThemeData(
        color: outline,
        thickness: 1,
      ),
      
      // 文字主题
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSans(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        displayMedium: GoogleFonts.notoSans(
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        displaySmall: GoogleFonts.notoSans(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        headlineSmall: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        titleSmall: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurface,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        labelMedium: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        labelSmall: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
      ),
    );
  }
}
