import 'package:flutter/material.dart';

@immutable
class NeumorphicShadows extends ThemeExtension<NeumorphicShadows> {
  const NeumorphicShadows({
    required this.base,
    required this.insetBase,
    required this.raisedSmall,
    required this.raisedCard,
    required this.inset,
    required this.deepAccent,
  });

  /// Base tone every surface is molded from.
  final Color base;

  /// Base tone for pressed/inset elements.
  final Color insetBase;

  /// Raised pair: light top-left highlight + dark bottom-right shadow (16px tiles).
  final List<BoxShadow> raisedSmall;

  /// Raised pair for full-width cards (20px radius surfaces).
  final List<BoxShadow> raisedCard;

  /// Inset pair: dark top-left + light bottom-right (search bars, readouts, tracks).
  final List<BoxShadow> inset;

  /// Deep accent used for text/icons placed on the accent color.
  final Color deepAccent;

  @override
  NeumorphicShadows copyWith({
    Color? base,
    Color? insetBase,
    List<BoxShadow>? raisedSmall,
    List<BoxShadow>? raisedCard,
    List<BoxShadow>? inset,
    Color? deepAccent,
  }) {
    return NeumorphicShadows(
      base: base ?? this.base,
      insetBase: insetBase ?? this.insetBase,
      raisedSmall: raisedSmall ?? this.raisedSmall,
      raisedCard: raisedCard ?? this.raisedCard,
      inset: inset ?? this.inset,
      deepAccent: deepAccent ?? this.deepAccent,
    );
  }

  @override
  NeumorphicShadows lerp(NeumorphicShadows? other, double t) {
    if (other == null) return this;
    return NeumorphicShadows(
      base: Color.lerp(base, other.base, t)!,
      insetBase: Color.lerp(insetBase, other.insetBase, t)!,
      raisedSmall: BoxShadow.lerpList(raisedSmall, other.raisedSmall, t) ?? raisedSmall,
      raisedCard: BoxShadow.lerpList(raisedCard, other.raisedCard, t) ?? raisedCard,
      inset: BoxShadow.lerpList(inset, other.inset, t) ?? inset,
      deepAccent: Color.lerp(deepAccent, other.deepAccent, t)!,
    );
  }
}

class AppTheme {
  // Warm base tone and its embossed shadow pairs (design system values).
  static const Color base = Color(0xFFE7E1D8);
  static const Color shadowRaisedLight = Color(0xFFFFFFFF);
  static const Color shadowRaisedDark = Color(0xFFC9C2B5);
  static const Color insetBase = Color(0xFFDAD3C6);
  static const Color shadowInsetLight = Color(0xFFFFFFFF);
  static const Color shadowInsetDark = Color(0xFFC1BAAD);

  // Accent + semantic status palette.
  static const Color accent = Color(0xFF7FA37A);
  static const Color accentDeep = Color(0xFF3D5A3A);
  static const Color warningAmber = Color(0xFFD99A44);
  static const Color dangerBrick = Color(0xFFB4553F);

  // Text.
  static const Color textPrimary = Color(0xFF4A453D);
  static const Color textSecondary = Color(0xFF8C8776);

  // Dark warm variant (same hue family for the embossed illusion at night).
  static const Color baseDark = Color(0xFF23211D);
  static const Color shadowRaisedLightD = Color(0xFF2D2B26);
  static const Color shadowRaisedDarkD = Color(0xFF191713);
  static const Color insetBaseD = Color(0xFF1E1C19);
  static const Color shadowInsetLightD = Color(0xFF26241F);
  static const Color shadowInsetDarkD = Color(0xFF191713);
  static const Color textPrimaryD = Color(0xFFE8E2D8);
  static const Color textSecondaryD = Color(0xFFA29B8C);

  // Legacy aliases (kept for call-sites outside the theme).
  static const Color successGreen = accent;
  static const Color warningOrange = warningAmber;
  static const Color errorRed = dangerBrick;
  static const Color infoBlue = Color(0xFF6E93A8);
  static const Color brassGold = accent;

  // Typography.
  static const String displayFont = 'Inter';
  static const String bodyFont = 'Inter';
  static const String greetingFont = 'Caveat';

  static const NeumorphicShadows _lightShadows = NeumorphicShadows(
    base: base,
    insetBase: insetBase,
    raisedSmall: _raisedPairSmallLight,
    raisedCard: _raisedPairCardLight,
    inset: _insetPairLight,
    deepAccent: accentDeep,
  );

  static const NeumorphicShadows _darkShadows = NeumorphicShadows(
    base: baseDark,
    insetBase: insetBaseD,
    raisedSmall: _raisedPairSmallDark,
    raisedCard: _raisedPairCardDark,
    inset: _insetPairDark,
    deepAccent: accentDeep,
  );

  static const List<BoxShadow> _raisedPairSmallLight = [
    BoxShadow(
      color: shadowRaisedLight,
      offset: Offset(-4, -4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: shadowRaisedDark,
      offset: Offset(4, 4),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> _raisedPairCardLight = [
    BoxShadow(
      color: shadowRaisedLight,
      offset: Offset(-6, -6),
      blurRadius: 12,
    ),
    BoxShadow(
      color: shadowRaisedDark,
      offset: Offset(6, 6),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> _insetPairLight = [
    BoxShadow(
      color: shadowInsetDark,
      offset: Offset(3, 3),
      blurRadius: 6,
      blurStyle: BlurStyle.inner,
    ),
    BoxShadow(
      color: shadowInsetLight,
      offset: Offset(-3, -3),
      blurRadius: 6,
      blurStyle: BlurStyle.inner,
    ),
  ];

  static const List<BoxShadow> _raisedPairSmallDark = [
    BoxShadow(
      color: shadowRaisedLightD,
      offset: Offset(-4, -4),
      blurRadius: 8,
    ),
    BoxShadow(
      color: shadowRaisedDarkD,
      offset: Offset(4, 4),
      blurRadius: 8,
    ),
  ];

  static const List<BoxShadow> _raisedPairCardDark = [
    BoxShadow(
      color: shadowRaisedLightD,
      offset: Offset(-6, -6),
      blurRadius: 12,
    ),
    BoxShadow(
      color: shadowRaisedDarkD,
      offset: Offset(6, 6),
      blurRadius: 12,
    ),
  ];

  static const List<BoxShadow> _insetPairDark = [
    BoxShadow(
      color: shadowInsetDarkD,
      offset: Offset(3, 3),
      blurRadius: 6,
      blurStyle: BlurStyle.inner,
    ),
    BoxShadow(
      color: shadowInsetLightD,
      offset: Offset(-3, -3),
      blurRadius: 6,
      blurStyle: BlurStyle.inner,
    ),
  ];

  static ColorScheme get lightColorScheme => const ColorScheme.light(
        primary: accent,
        onPrimary: accentDeep,
        primaryContainer: Color(0xFFE2E9DE),
        onPrimaryContainer: Color(0xFF2E4A2C),
        secondary: textSecondary,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFEDE7DA),
        onSecondaryContainer: textPrimary,
        tertiary: warningAmber,
        onTertiary: Color(0xFF4A3208),
        error: dangerBrick,
        onError: Colors.white,
        errorContainer: Color(0xFFEED9D2),
        onErrorContainer: Color(0xFF5A2E23),
        surface: base,
        surfaceContainerLowest: base,
        surfaceContainerLow: Color(0xFFEBE5DC),
        surfaceContainer: Color(0xFFEDE7DE),
        surfaceContainerHigh: Color(0xFFDED7CB),
        surfaceContainerHighest: Color(0xFFD6CEC0),
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: Color(0xFFB3AB9B),
        outlineVariant: Color(0xFFC4BCAD),
        inverseSurface: Color(0xFF4A453D),
        onInverseSurface: Color(0xFFF0EADf),
        shadow: shadowRaisedDark,
      );

  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: accent,
    onPrimary: accentDeep,
    primaryContainer: Color(0xFF3A4A38),
    onPrimaryContainer: Color(0xFFE2E9DE),
    secondary: textSecondaryD,
    onSecondary: Color(0xFF14120F),
    secondaryContainer: Color(0xFF312E29),
    onSecondaryContainer: textPrimaryD,
    tertiary: warningAmber,
    onTertiary: Color(0xFF4A3208),
    error: dangerBrick,
    onError: Colors.white,
    errorContainer: Color(0xFF4A2A22),
    onErrorContainer: Color(0xFFEED9D2),
    surface: baseDark,
    surfaceContainerLowest: baseDark,
    surfaceContainerLow: Color(0xFF262420),
    surfaceContainer: Color(0xFF282520),
    surfaceContainerHigh: Color(0xFF1D1B17),
    surfaceContainerHighest: Color(0xFF181613),
    onSurface: textPrimaryD,
    onSurfaceVariant: textSecondaryD,
    outline: Color(0xFF6E6659),
    outlineVariant: Color(0xFF45403A),
    inverseSurface: Color(0xFFE8E2D8),
    onInverseSurface: Color(0xFF3A3630),
    shadow: shadowRaisedDarkD,
  );

  static ThemeData get lightTheme => _buildTheme(lightColorScheme, _lightShadows);

  static ThemeData get darkTheme => _buildTheme(darkColorScheme, _darkShadows);

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

  static TextStyle _title(TextStyle style, {FontWeight weight = FontWeight.w500}) {
    return style.copyWith(
      fontFamily: displayFont,
      fontWeight: weight,
      letterSpacing: -0.2,
      height: 1.15,
      decoration: TextDecoration.none,
    );
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, NeumorphicShadows shadows) {
    final isLight = colorScheme.brightness == Brightness.light;
    final background = colorScheme.surface;

    final baseText = ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      fontFamily: bodyFont,
    ).textTheme;

    final textTheme = baseText.copyWith(
      displayLarge: _title(baseText.displayLarge!, weight: FontWeight.w600),
      displayMedium: _title(baseText.displayMedium!, weight: FontWeight.w600),
      displaySmall: _title(baseText.displaySmall!, weight: FontWeight.w600),
      headlineLarge: _title(baseText.headlineLarge!, weight: FontWeight.w600),
      headlineMedium: _title(baseText.headlineMedium!, weight: FontWeight.w500),
      headlineSmall: _title(baseText.headlineSmall!, weight: FontWeight.w500),
      titleLarge: _title(baseText.titleLarge!, weight: FontWeight.w600),
      titleMedium: _title(baseText.titleMedium!, weight: FontWeight.w500),
      titleSmall: baseText.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.4),
      labelLarge: baseText.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      fontFamily: bodyFont,
      textTheme: textTheme,
      extensions: [shadows],
      scaffoldBackgroundColor: background,
      shadowColor: isLight ? Colors.transparent : null,
      iconTheme: _iconTheme(colorScheme.onSurface),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        iconTheme: _iconTheme(colorScheme.onSurface),
        titleTextStyle: _title(
          const TextStyle(color: Color(0xFFFFFFFF)),
          weight: FontWeight.w600,
        ).copyWith(
          color: colorScheme.onSurface,
          fontSize: 22,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? insetBase : insetBaseD,
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 5,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: bodyFont,
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
            fontFamily: bodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: _title(
          TextStyle(color: colorScheme.onSurface),
          weight: FontWeight.w600,
        ).copyWith(fontSize: 18),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 6,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        disabledColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimary),
        shape: const StadiumBorder(),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}