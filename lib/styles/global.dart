import 'package:flutter/material.dart';

class Global {
  static const _baseUnit = 4.0;

  // Spacing System
  static const double spacingXs = _baseUnit * 1; // 4
  static const double spacingSm = _baseUnit * 2; // 8
  static const double spacingMd = _baseUnit * 4; // 16
  static const double spacingLg = _baseUnit * 6; // 24
  static const double spacingXl = _baseUnit * 8; // 32
  static const double spacingXxl = _baseUnit * 12; // 48

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // Elevation
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;

  // Icon Sizes
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 60.0;

  // Font Sizes
  static const double fontSm = 12.0;
  static const double fontMd = 14.0;
  static const double fontLg = 16.0;
  static const double fontXl = 20.0;
  static const double fontXxl = 24.0;
  static const double fontDisplay = 32.0;

  // Component Sizes
  static const double logoSize = 120.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Padding Helpers
  static EdgeInsets get padXs => const EdgeInsets.all(spacingXs);
  static EdgeInsets get padSm => const EdgeInsets.all(spacingSm);
  static EdgeInsets get padMd => const EdgeInsets.all(spacingMd);
  static EdgeInsets get padLg => const EdgeInsets.all(spacingLg);
  static EdgeInsets get padXl => const EdgeInsets.all(spacingXl);

  // Margin Helpers
  static EdgeInsets get marginXs => const EdgeInsets.all(spacingXs);
  static EdgeInsets get marginSm => const EdgeInsets.all(spacingSm);
  static EdgeInsets get marginMd => const EdgeInsets.all(spacingMd);
  static EdgeInsets get marginLg => const EdgeInsets.all(spacingLg);
  static EdgeInsets get marginXl => const EdgeInsets.all(spacingXl);

  // Border Radius Helpers
  static BorderRadius get borderSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderXl => BorderRadius.circular(radiusXl);

  // Gap Helpers
  static SizedBox get gapXs =>
      const SizedBox(height: spacingXs, width: spacingXs);
  static SizedBox get gapSm =>
      const SizedBox(height: spacingSm, width: spacingSm);
  static SizedBox get gapMd =>
      const SizedBox(height: spacingMd, width: spacingMd);
  static SizedBox get gapLg =>
      const SizedBox(height: spacingLg, width: spacingLg);
  static SizedBox get gapXl =>
      const SizedBox(height: spacingXl, width: spacingXl);

  // Shadow Helpers
  static BoxShadow get shadowSm => BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  static BoxShadow get shadowMd => BoxShadow(
    color: Colors.black.withValues(alpha: 0.15),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  static BoxShadow get shadowLg => BoxShadow(
    color: Colors.black.withValues(alpha: 0.2),
    blurRadius: 16,
    offset: const Offset(0, 8),
  );
}
