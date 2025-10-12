import 'package:flutter/material.dart';

class ThemeUtil {
  // Theme Colors
  static const Color primaryColor = Color(0xFF4A6CF7);
  static const Color primaryLight = Color(0xFF6B8EF7);
  static const Color primaryDark = Color(0xFF2E4EF7);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color accentLight = Color(0xFF67E8F9);
  static const Color accentDark = Color(0xFF0891B2);
  static const Color backgroundLight = Color(0xFFF8F9FF);
  static const Color backgroundDark = Color(0xFF1A1B2E);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2A2B3E);
  static const Color textPrimary = Color(0xFF1A1B2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Onboarding Colors
  static const Color onboardingBackground = Color(0xFF6366F1);
  static const Color onboardingButton = Color(0xFF4338CA);
  static const Color onboardingTextPrimary = Color(0xFFFFFFFF);
  static const Color onboardingTextSecondary = Color(0xFFFFFFFF);
  static const double onboardingTextSecondaryOpacity = 0.8;
  static const Color onboardingDotActive = Color(0xFFFFFFFF);
  static const Color onboardingDotInactive = Color(0xFFFFFFFF);
  static const double onboardingDotInactiveOpacity = 0.3;
  static const Color onboardingIllustrationBg = Color(0xFFFFFFFF);
  static const double onboardingIllustrationBgOpacity = 0.1;

  // Font size constants - Small fixed sizes
  static const double fontSizeDisplayLarge = 28;
  static const double fontSizeDisplayMedium = 20;
  static const double fontSizeTitleLarge = 20;
  static const double fontSizeTitleMedium = 16;
  static const double fontSizeTitleSmall = 14;
  static const double fontSizeBodyLarge = 13;
  static const double fontSizeBodyMedium = 12;
  static const double fontSizeBodySmall = 11;
  static const double fontSizeLabelLarge = 12;
  static const double fontSizeLabelMedium = 11;
  static const double fontSizeLabelSmall = 10;
  static const double fontSizeCaption = 11;
  static const double fontSizeAppBar = 15;
  static const double fontSizeButton = 12;
  static const double fontSizeTextButton = 11;

  // Text Styles - Optimized for smaller, more readable sizes
  static const TextStyle titleLarge = TextStyle(
    fontSize: ThemeUtil.fontSizeTitleLarge,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: ThemeUtil.fontSizeTitleMedium,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: ThemeUtil.fontSizeTitleSmall,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: ThemeUtil.fontSizeBodyLarge,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: ThemeUtil.fontSizeBodyMedium,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: ThemeUtil.fontSizeBodySmall,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: ThemeUtil.fontSizeLabelLarge,
    fontWeight: FontWeight.w600,
    color: textLight,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: ThemeUtil.fontSizeLabelMedium,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: ThemeUtil.fontSizeLabelSmall,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle displayLarge = TextStyle(
    fontSize: ThemeUtil.fontSizeDisplayLarge,
    fontWeight: FontWeight.bold,
    color: textLight,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: ThemeUtil.fontSizeDisplayMedium,
    fontWeight: FontWeight.bold,
    color: textLight,
  );

  static const TextStyle captionLight = TextStyle(
    fontSize: ThemeUtil.fontSizeCaption,
    fontWeight: FontWeight.w300,
    color: textLight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceLight,
        error: error,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: ThemeUtil.fontSizeAppBar,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: interactiveBackground(primaryColor),
          foregroundColor: WidgetStateProperty.all(textLight),
          overlayColor: interactiveOverlay(textLight),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: ThemeUtil.fontSizeButton,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primaryColor),
          overlayColor: interactiveOverlay(primaryColor),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: ThemeUtil.fontSizeTextButton,
              fontWeight: FontWeight.w500,
            ),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primaryColor),
          overlayColor: interactiveOverlay(primaryColor),
          side: WidgetStateProperty.all(
            const BorderSide(color: primaryColor, width: 1.5),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: ThemeUtil.fontSizeButton,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      textTheme: TextTheme(
        displayLarge: titleLarge,
        displayMedium: displayMedium,
        displaySmall: displayMedium,
        headlineLarge: titleLarge,
        headlineMedium: titleMedium,
        headlineSmall: titleSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );

    final colorScheme = baseScheme.copyWith(
      primary: primaryLight,
      onPrimary: textLight,
      primaryContainer: primaryDark,
      onPrimaryContainer: textLight,
      secondary: secondaryLight,
      onSecondary: textLight,
      secondaryContainer: secondaryDark,
      onSecondaryContainer: textLight,
      tertiary: accentLight,
      onTertiary: textLight,
      tertiaryContainer: accentDark,
      onTertiaryContainer: textLight,
      error: error,
      onError: textLight,
      errorContainer: error.withValues(alpha: 0.2),
      onErrorContainer: error,
      surface: surfaceDark,
      onSurface: textLight,
      onSurfaceVariant: textLight.withValues(alpha: 0.72),
      outline: textLight.withValues(alpha: 0.2),
      outlineVariant: textLight.withValues(alpha: 0.1),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: surfaceLight,
      onInverseSurface: textPrimary,
      inversePrimary: primaryColor,
      surfaceTint: primaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: ThemeUtil.fontSizeAppBar,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: interactiveBackground(primaryLight),
          foregroundColor: WidgetStateProperty.all(textLight),
          overlayColor: interactiveOverlay(textLight),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: ThemeUtil.fontSizeButton,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: WidgetStateProperty.all(0),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryLight.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        labelStyle: TextStyle(color: textLight.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: textLight.withValues(alpha: 0.5)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primaryLight),
          overlayColor: interactiveOverlay(primaryLight),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: ThemeUtil.fontSizeTextButton,
              fontWeight: FontWeight.w500,
            ),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(primaryLight),
          overlayColor: interactiveOverlay(primaryLight),
          side: WidgetStateProperty.all(
            const BorderSide(color: primaryLight, width: 1.5),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(
              fontSize: ThemeUtil.fontSizeButton,
              fontWeight: FontWeight.w600,
            ),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: titleLarge,
        displayMedium: displayMedium,
        displaySmall: displayMedium,
        headlineLarge: titleLarge,
        headlineMedium: titleMedium,
        headlineSmall: titleSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),
    );
  }

  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor, primaryColor],
  );

  static LinearGradient get backgroundGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryColor.withValues(alpha: 0.1), backgroundLight],
  );

  static LinearGradient darkBackgroundGradient(ColorScheme colorScheme) =>
      LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colorScheme.primary.withValues(alpha: 0.15),
          colorScheme.surface,
        ],
      );

  static WidgetStateProperty<Color?> interactiveOverlay(
    Color color, {
    double hoverOpacity = 0.06,
    double pressedOpacity = 0.12,
  }) => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) return null;
    if (states.contains(WidgetState.pressed)) {
      return color.withValues(alpha: pressedOpacity);
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return color.withValues(alpha: hoverOpacity);
    }
    return null;
  });

  static WidgetStateProperty<Color?> interactiveBackground(
    Color color, {
    double hoverShade = 0.08,
    double pressedShade = 0.14,
    double disabledOpacity = 0.4,
  }) => WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.disabled)) {
      return color.withValues(alpha: disabledOpacity);
    }
    if (states.contains(WidgetState.pressed)) {
      return _shade(color, pressedShade);
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return _shade(color, hoverShade);
    }
    return color;
  });

  static Color interactiveSurfaceColor(
    Color base, {
    bool hovered = false,
    bool pressed = false,
    Color overlayColor = primaryColor,
    double hoverOpacity = 0.06,
    double pressedOpacity = 0.12,
  }) {
    if (pressed) {
      return Color.alphaBlend(
        overlayColor.withValues(alpha: pressedOpacity),
        base,
      );
    }
    if (hovered) {
      return Color.alphaBlend(
        overlayColor.withValues(alpha: hoverOpacity),
        base,
      );
    }
    return base;
  }

  static Color _shade(Color color, double amount) =>
      Color.lerp(color, Colors.black, amount) ?? color;

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'active':
        return success;
      case 'warning':
      case 'pending':
        return warning;
      case 'error':
      case 'failed':
      case 'inactive':
        return error;
      case 'info':
      case 'processing':
        return info;
      default:
        return primaryColor;
    }
  }

  /// Get the appropriate surface color based on theme
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Get the appropriate outline color based on theme
  static Color getOutlineColor(BuildContext context, {double alpha = 0.12}) {
    return Theme.of(context).colorScheme.outline.withValues(alpha: alpha);
  }

  /// Get the appropriate primary color based on theme
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  /// Get the appropriate text color for labels based on theme
  static Color getLabelColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  /// Get the appropriate text color based on theme
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
}
