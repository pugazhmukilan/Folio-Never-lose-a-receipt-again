import 'package:flutter/material.dart';

class AppTheme {
  // Apple-inspired Color Palette
  static const Color appleBlue = Color(0xFF007AFF);
  static const Color appleGray = Color(0xFF8E8E93);
  static const Color appleGray2 = Color(0xFFAEAEB2);
  static const Color appleGray3 = Color(0xFFC7C7CC);
  static const Color appleGray4 = Color(0xFFD1D1D6);
  static const Color appleGray5 = Color(0xFFE5E5EA);
  static const Color appleGray6 = Color(0xFFF2F2F7);
  
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFF2F2F7);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFFF3B30);
  
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black;
  static const Color onSurface = Colors.black;
  static const Color onError = Colors.white;
  
  // Status Colors (Apple style)
  static const Color expiringColor = Color(0xFFFF3B30); // Apple Red
  static const Color warningColor = Color(0xFFFF9500); // Apple Orange
  static const Color activeColor = Color(0xFF34C759); // Apple Green
  
  // Light Theme (Apple style)
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: appleBlue,
      secondary: appleBlue,
      surface: surfaceColor,
      surfaceContainerHighest: appleGray6,
      error: errorColor,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onSurface: onSurface,
      onError: onError,
      outline: appleGray3,
      primaryContainer: appleGray6,
      secondaryContainer: appleGray5,
    ),
    scaffoldBackgroundColor: secondaryBackground,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: backgroundColor,
      surfaceTintColor: backgroundColor,
      foregroundColor: onSurface,
      iconTheme: IconThemeData(color: onSurface),
      titleTextStyle: TextStyle(
        color: onSurface,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: appleBlue,
      foregroundColor: onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appleGray6,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: appleBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: appleBlue,
        foregroundColor: onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: appleBlue,
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: appleGray5,
      thickness: 0.5,
      space: 1,
    ),
  );
  
  // Dark Theme (Apple style)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0A84FF), // Lighter blue for dark mode
      secondary: Color(0xFF0A84FF),
      surface: Color(0xFF1C1C1E),
      surfaceContainerHighest: Color(0xFF2C2C2E),
      error: Color(0xFFFF453A),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
      outline: Color(0xFF48484A),
      primaryContainer: Color(0xFF2C2C2E),
      secondaryContainer: Color(0xFF3A3A3C),
    ),
    scaffoldBackgroundColor: const Color(0xFF000000),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF000000),
      surfaceTintColor: Color(0xFF000000),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF0A84FF),
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C1C1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0A84FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF453A), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0A84FF),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF0A84FF),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF38383A),
      thickness: 0.5,
      space: 1,
    ),
  );
}
