import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ParafixTheme {
  static final List<ParafixThemePreset> presets = [
    const ParafixThemePreset(
      id: 'graphite',
      name: 'Grafit',
      brightness: Brightness.light,
      background: Color(0xFFE0E6EE),
      surface: Color(0xFFF7F9FC),
      surfaceAlt: Color(0xFFD0D8E3),
      textPrimary: Color(0xFF1B2128),
      mutedText: Color(0xFF5D6772),
      accent: Color(0xFF355FD8),
    ),
    const ParafixThemePreset(
      id: 'forest',
      name: 'Orman',
      brightness: Brightness.light,
      background: Color(0xFFE6EEE7),
      surface: Color(0xFFF5FAF5),
      surfaceAlt: Color(0xFFD5E2D6),
      textPrimary: Color(0xFF17231B),
      mutedText: Color(0xFF5A685E),
      accent: Color(0xFF2F8A62),
    ),
    const ParafixThemePreset(
      id: 'sand',
      name: 'Kum',
      brightness: Brightness.light,
      background: Color(0xFFF0E5D6),
      surface: Color(0xFFFFFAF2),
      surfaceAlt: Color(0xFFE7D6BF),
      textPrimary: Color(0xFF261F18),
      mutedText: Color(0xFF75685A),
      accent: Color(0xFFC6842A),
    ),
    const ParafixThemePreset(
      id: 'dust-rose',
      name: 'Toz Pembe',
      brightness: Brightness.light,
      background: Color(0xFFF4E8EA),
      surface: Color(0xFFFFF7F8),
      surfaceAlt: Color(0xFFEAD6DA),
      textPrimary: Color(0xFF2A2023),
      mutedText: Color(0xFF79676D),
      accent: Color(0xFFC17D8F),
    ),
    const ParafixThemePreset(
      id: 'burgundy',
      name: 'Bordo',
      brightness: Brightness.light,
      background: Color(0xFFF1E5E7),
      surface: Color(0xFFFFF7F7),
      surfaceAlt: Color(0xFFE7D0D5),
      textPrimary: Color(0xFF2A1D21),
      mutedText: Color(0xFF765F65),
      accent: Color(0xFFA8324A),
    ),
    const ParafixThemePreset(
      id: 'night',
      name: 'Koyu',
      brightness: Brightness.dark,
      background: Color(0xFF101723),
      surface: Color(0xFF182131),
      surfaceAlt: Color(0xFF243149),
      textPrimary: Color(0xFFF4F7FB),
      mutedText: Color(0xFFA8B5C8),
      accent: Color(0xFF5D86F8),
    ),
  ];

  static ThemeData buildTheme({required ParafixThemePreset preset}) {
    final palette = preset.toPalette();
    final isDark = preset.brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: preset.brightness,
      primary: palette.accent,
      onPrimary: palette.surface,
      secondary: palette.accent,
      onSecondary: palette.surface,
      error: const Color(0xFFC53D4A),
      onError: Colors.white,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      primaryContainer: palette.highlight,
      onPrimaryContainer: palette.textPrimary,
      secondaryContainer: palette.highlight,
      onSecondaryContainer: palette.textPrimary,
      tertiary: palette.accent,
      onTertiary: palette.surface,
      tertiaryContainer: palette.highlight,
      onTertiaryContainer: palette.textPrimary,
      errorContainer: const Color(0xFFF8D7DA),
      onErrorContainer: const Color(0xFF5F121A),
      surfaceContainerHighest: palette.surfaceAlt,
      outline: palette.border,
      outlineVariant: palette.border,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: palette.textPrimary,
      onInverseSurface: palette.surface,
      inversePrimary: palette.accent,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: preset.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: palette.background,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: palette.surface,
          systemNavigationBarDividerColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: palette.surface.withValues(alpha: 0.94),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: palette.accent,
          disabledForegroundColor: Colors.white.withValues(alpha: 0.72),
          disabledBackgroundColor: palette.accent.withValues(alpha: 0.38),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.textPrimary,
        contentTextStyle: TextStyle(color: palette.surface),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
          letterSpacing: -0.8,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.35,
          color: palette.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.35,
          color: palette.textPrimary,
        ),
        bodySmall: TextStyle(fontSize: 12, color: palette.mutedText),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: palette.surface,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: palette.mutedText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceAlt.withValues(alpha: 0.64),
        hintStyle: TextStyle(color: palette.mutedText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

ScrollPhysics parafixPlatformScrollPhysics(TargetPlatform platform) {
  switch (platform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return const ClampingScrollPhysics();
  }
}

class ParafixScrollBehavior extends MaterialScrollBehavior {
  const ParafixScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return parafixPlatformScrollPhysics(getPlatform(context));
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return child;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return super.buildOverscrollIndicator(context, child, details);
    }
  }
}

class ParafixThemePreset {
  const ParafixThemePreset({
    required this.id,
    required this.name,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.mutedText,
    required this.accent,
  });

  final String id;
  final String name;
  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color mutedText;
  final Color accent;

  ParafixPalette toPalette() {
    final border = brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final highlight = accent.withValues(
      alpha: brightness == Brightness.dark ? 0.24 : 0.12,
    );

    return ParafixPalette(
      background: background,
      surface: surface,
      surfaceAlt: surfaceAlt,
      textPrimary: textPrimary,
      mutedText: mutedText,
      accent: accent,
      border: border,
      highlight: highlight,
    );
  }
}

class ParafixPalette extends ThemeExtension<ParafixPalette> {
  const ParafixPalette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.mutedText,
    required this.accent,
    required this.border,
    required this.highlight,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color mutedText;
  final Color accent;
  final Color border;
  final Color highlight;

  @override
  ThemeExtension<ParafixPalette> copyWith({
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? mutedText,
    Color? accent,
    Color? border,
    Color? highlight,
  }) {
    return ParafixPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      mutedText: mutedText ?? this.mutedText,
      accent: accent ?? this.accent,
      border: border ?? this.border,
      highlight: highlight ?? this.highlight,
    );
  }

  @override
  ThemeExtension<ParafixPalette> lerp(
    covariant ThemeExtension<ParafixPalette>? other,
    double t,
  ) {
    if (other is! ParafixPalette) {
      return this;
    }

    return ParafixPalette(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t) ?? surfaceAlt,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      mutedText: Color.lerp(mutedText, other.mutedText, t) ?? mutedText,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      border: Color.lerp(border, other.border, t) ?? border,
      highlight: Color.lerp(highlight, other.highlight, t) ?? highlight,
    );
  }
}
