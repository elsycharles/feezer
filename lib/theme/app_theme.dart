import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Spacing scale (4 pt grid), corner radii and motion durations.
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Horizontal padding of screen content.
  static const double page = 20;

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 26;

  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);
}

/// Motion: short, consistent, decelerating.
abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration medium = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 380);
  static const Curve curve = Curves.easeOutCubic;
}

/// Brand colors. [blueLight] and [navy] are the logo's light and folded parts;
/// [blue] is a little deeper so text and buttons keep a good contrast.
abstract final class Brand {
  static const Color blue = Color(0xFF1E6BFF);
  static const Color blueLight = Color(0xFF2C8EFF);
  static const Color navy = Color(0xFF003DC5);
  static const Color ink = Color(0xFF101828);
}

/// Semantic colors not covered by [ColorScheme].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.highlight,
    required this.onHighlight,
  });

  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  /// Solid background of the main result.
  final Color highlight;
  final Color onHighlight;

  static const light = AppPalette(
    success: Color(0xFF0F8A5F),
    successContainer: Color(0xFFE5F6EE),
    onSuccessContainer: Color(0xFF0B5C40),
    warning: Color(0xFFB54708),
    warningContainer: Color(0xFFFFF3E0),
    onWarningContainer: Color(0xFF7A3505),
    highlight: Brand.blue,
    onHighlight: Colors.white,
  );

  static const dark = AppPalette(
    success: Color(0xFF4CC68D),
    successContainer: Color(0xFF113526),
    onSuccessContainer: Color(0xFFB4EDD0),
    warning: Color(0xFFF7B955),
    warningContainer: Color(0xFF3D2A0E),
    onWarningContainer: Color(0xFFFCE2B8),
    highlight: Color(0xFF2A6FF0),
    onHighlight: Colors.white,
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      success: mix(success, other.success),
      successContainer: mix(successContainer, other.successContainer),
      onSuccessContainer: mix(onSuccessContainer, other.onSuccessContainer),
      warning: mix(warning, other.warning),
      warningContainer: mix(warningContainer, other.warningContainer),
      onWarningContainer: mix(onWarningContainer, other.onWarningContainer),
      highlight: mix(highlight, other.highlight),
      onHighlight: mix(onHighlight, other.onHighlight),
    );
  }
}

/// Application themes: flat surfaces, no gradients, Inter.
abstract final class AppTheme {
  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  /// Tabular figures keep amounts aligned.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static ColorScheme _scheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: Brand.blue,
      brightness: brightness,
    );
    if (brightness == Brightness.dark) {
      return base.copyWith(
        primary: const Color(0xFF6A9EFF),
        onPrimary: const Color(0xFF051634),
        primaryContainer: const Color(0xFF15294D),
        onPrimaryContainer: const Color(0xFFD7E4FF),
        secondary: const Color(0xFF9DB4E0),
        onSecondary: const Color(0xFF0B1A33),
        secondaryContainer: const Color(0xFF1D2838),
        onSecondaryContainer: const Color(0xFFDCE5F5),
        surface: const Color(0xFF0F1218),
        surfaceContainerLowest: const Color(0xFF0B0E13),
        surfaceContainerLow: const Color(0xFF171B23),
        surfaceContainer: const Color(0xFF1C212A),
        surfaceContainerHigh: const Color(0xFF232934),
        surfaceContainerHighest: const Color(0xFF2B3240),
        onSurface: const Color(0xFFE9ECF1),
        onSurfaceVariant: const Color(0xFF9AA3B2),
        outline: const Color(0xFF4A5261),
        outlineVariant: const Color(0xFF2A303B),
        error: const Color(0xFFFF8F87),
        onError: const Color(0xFF3A0905),
        errorContainer: const Color(0xFF4A1612),
        onErrorContainer: const Color(0xFFFFDAD5),
        inverseSurface: const Color(0xFFE9ECF1),
        onInverseSurface: const Color(0xFF151922),
        inversePrimary: Brand.blue,
        surfaceTint: Colors.transparent,
      );
    }
    return base.copyWith(
      primary: Brand.blue,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE8F0FF),
      onPrimaryContainer: Brand.navy,
      secondary: const Color(0xFF3A4A66),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFEDF1F7),
      onSecondaryContainer: const Color(0xFF1B2638),
      surface: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: const Color(0xFFF4F6F9),
      surfaceContainer: const Color(0xFFEEF1F5),
      surfaceContainerHigh: const Color(0xFFE7EBF1),
      surfaceContainerHighest: const Color(0xFFDFE4EC),
      onSurface: Brand.ink,
      onSurfaceVariant: const Color(0xFF5B6576),
      outline: const Color(0xFFC4CAD4),
      outlineVariant: const Color(0xFFE3E7EE),
      error: const Color(0xFFD92D20),
      onError: Colors.white,
      errorContainer: const Color(0xFFFDECEA),
      onErrorContainer: const Color(0xFF7A1A12),
      inverseSurface: const Color(0xFF1B2130),
      onInverseSurface: const Color(0xFFF2F4F7),
      inversePrimary: const Color(0xFF9DBEFF),
      surfaceTint: Colors.transparent,
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    TextStyle style(
      double size,
      FontWeight weight, {
      double? height,
      double spacing = 0,
    }) => TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      color: scheme.onSurface,
    );
    return TextTheme(
      displayLarge: style(46, FontWeight.w700, height: 1.1, spacing: -1.4),
      displayMedium: style(38, FontWeight.w700, height: 1.1, spacing: -1.1),
      displaySmall: style(32, FontWeight.w700, height: 1.15, spacing: -0.9),
      headlineLarge: style(28, FontWeight.w700, height: 1.2, spacing: -0.7),
      headlineMedium: style(25, FontWeight.w700, height: 1.2, spacing: -0.5),
      headlineSmall: style(21, FontWeight.w700, height: 1.25, spacing: -0.3),
      titleLarge: style(19, FontWeight.w600, height: 1.3, spacing: -0.2),
      titleMedium: style(16, FontWeight.w600, height: 1.4, spacing: -0.1),
      titleSmall: style(14, FontWeight.w600, height: 1.4),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(14, FontWeight.w400, height: 1.45),
      bodySmall: style(
        12.5,
        FontWeight.w400,
        height: 1.4,
      ).copyWith(color: scheme.onSurfaceVariant),
      labelLarge: style(15, FontWeight.w600, height: 1.2),
      labelMedium: style(13, FontWeight.w600, height: 1.2),
      labelSmall: style(11.5, FontWeight.w600, height: 1.2, spacing: 0.4),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final scheme = _scheme(brightness);
    final text = _textTheme(scheme);
    final isDark = brightness == Brightness.dark;
    final radiusMd = BorderRadius.circular(Space.radiusMd);
    final radiusLg = BorderRadius.circular(Space.radiusLg);

    // Pressed / hovered overlays, shared by every interactive surface.
    final overlay = WidgetStateProperty.resolveWith<Color?>((states) {
      final ink = scheme.onSurface;
      if (states.contains(WidgetState.pressed) ||
          states.contains(WidgetState.focused)) {
        return ink.withValues(alpha: 0.08);
      }
      if (states.contains(WidgetState.hovered)) {
        return ink.withValues(alpha: 0.04);
      }
      return null;
    });

    final inputBorder = OutlineInputBorder(
      borderRadius: radiusMd,
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: 'Inter',
      textTheme: text,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      extensions: [isDark ? AppPalette.dark : AppPalette.light],
      // Calm ripple (no sparkle effect).
      splashFactory: InkRipple.splashFactory,
      hoverColor: scheme.onSurface.withValues(alpha: 0.04),
      highlightColor: Colors.transparent,
      splashColor: scheme.onSurface.withValues(alpha: 0.06),
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(64, 54)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: radiusMd),
          ),
          textStyle: WidgetStatePropertyAll(text.labelLarge),
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.black.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.black.withValues(alpha: 0.06);
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 54),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          side: BorderSide(color: scheme.outline),
          foregroundColor: scheme.onSurface,
          textStyle: text.labelLarge,
        ).copyWith(overlayColor: overlay),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
        ).copyWith(overlayColor: overlay),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
        extendedTextStyle: text.labelLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: inputBorder,
        enabledBorder: inputBorder.copyWith(borderSide: BorderSide.none),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        hintStyle: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        prefixIconColor: scheme.onSurfaceVariant,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(borderRadius: radiusMd),
        overlayColor: overlay,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Space.radiusXl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radiusLg),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          side: BorderSide(color: scheme.outlineVariant),
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          textStyle: text.labelMedium,
        ).copyWith(overlayColor: overlay),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.lg),
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primaryContainer,
        circularTrackColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: radiusMd,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        textStyle: text.bodyMedium,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(Space.radiusSm),
        ),
        textStyle: text.labelMedium?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }
}

/// Shortcuts on [BuildContext].
extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
