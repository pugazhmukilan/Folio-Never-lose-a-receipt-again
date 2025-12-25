import 'package:flutter/material.dart';

class AppTheme {
  // Brand / accent
  static const Color accentGreen = Color(0xFF4ECDC4);
  static const Color accentBlue = Color(0xFF5B9BD5);

  // Status
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);
  static const Color infoBlue = Color(0xFF2196F3);

  // Dark palette anchors (preserve your current aesthetic)
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF252525);
  static const Color darkSurfaceAlt = Color(0xFF2A2A2A);
  static const Color darkOutline = Color(0xFF3A3A3A);

  static ColorScheme get lightColorScheme {
    final base = ColorScheme.fromSeed(
      seedColor: accentGreen,
      brightness: Brightness.light,
    );
    return base.copyWith(
      secondary: accentBlue,
      error: errorRed,
    );
  }

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: Color.fromARGB(255, 78, 205, 196),
    secondary: accentBlue,
    error: errorRed,
    surface: darkSurface,
    surfaceContainerHighest: darkSurfaceAlt,
    outline: darkOutline,
    onPrimary: darkBackground,
  );

  static ThemeData get lightTheme => _buildTheme(lightColorScheme);

  static ThemeData get darkTheme => _buildTheme(
        darkColorScheme,
        scaffoldBackground: darkBackground,
      );

  static IconThemeData _iconTheme(Color color) {
    return IconThemeData(
      color: color,
      size: 22,
      weight: 200,
      opticalSize: 24,
      grade: 0,
      fill: 0,
    );
  }

  static ThemeData _buildTheme(
    ColorScheme colorScheme, {
    Color? scaffoldBackground,
  }) {
    final background = scaffoldBackground ?? colorScheme.surface;
    final isLight = colorScheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      // In light theme we prefer crisp borders over drop shadows.
      shadowColor: isLight ? Colors.transparent : null,
      iconTheme: _iconTheme(colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        surfaceTintColor: background,
        foregroundColor: colorScheme.onSurface,
        iconTheme: _iconTheme(colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.6),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 6,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}






