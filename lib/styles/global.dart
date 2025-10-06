import 'package:flutter/material.dart';

/// Global design system with consistent spacing, sizing, and animation values
class Global {
  Global._(); // Private constructor to prevent instantiation

  static const _baseUnit = 4.0;

  // Spacing System
  static const double spacingXs = _baseUnit * 1; // 4
  static const double spacingSm = _baseUnit * 2; // 8
  static const double spacingMd = _baseUnit * 4; // 16
  static const double spacingLg = _baseUnit * 6; // 24
  static const double spacingXl = _baseUnit * 8; // 32
  static const double spacingXxl = _baseUnit * 12; // 48

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;

  // Component Sizes
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 56.0;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Animation Curves
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveEmphasis = Curves.easeOutBack;

  // Padding Helpers
  static EdgeInsets get padXs => const EdgeInsets.all(spacingXs);
  static EdgeInsets get padSm => const EdgeInsets.all(spacingSm);
  static EdgeInsets get padMd => const EdgeInsets.all(spacingMd);
  static EdgeInsets get padLg => const EdgeInsets.all(spacingLg);
  static EdgeInsets get padXl => const EdgeInsets.all(spacingXl);
  static EdgeInsets get padXxl => const EdgeInsets.all(spacingXxl);

  // Horizontal Padding
  static EdgeInsets get padHorizontalMd => const EdgeInsets.symmetric(horizontal: spacingMd);
  static EdgeInsets get padHorizontalLg => const EdgeInsets.symmetric(horizontal: spacingLg);
  static EdgeInsets get padHorizontalXl => const EdgeInsets.symmetric(horizontal: spacingXl);

  // Vertical Padding
  static EdgeInsets get padVerticalMd => const EdgeInsets.symmetric(vertical: spacingMd);
  static EdgeInsets get padVerticalLg => const EdgeInsets.symmetric(vertical: spacingLg);
  static EdgeInsets get padVerticalXl => const EdgeInsets.symmetric(vertical: spacingXl);

  // Border Radius Helpers
  static BorderRadius get borderXs => BorderRadius.circular(radiusXs);
  static BorderRadius get borderSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderXl => BorderRadius.circular(radiusXl);

  // Gap Helpers
  static SizedBox get gapXs => const SizedBox(height: spacingXs, width: spacingXs);
  static SizedBox get gapSm => const SizedBox(height: spacingSm, width: spacingSm);
  static SizedBox get gapMd => const SizedBox(height: spacingMd, width: spacingMd);
  static SizedBox get gapLg => const SizedBox(height: spacingLg, width: spacingLg);
  static SizedBox get gapXl => const SizedBox(height: spacingXl, width: spacingXl);
  static SizedBox get gapXxl => const SizedBox(height: spacingXxl, width: spacingXxl);

  // Custom Gap Helpers
  static SizedBox gapH(double width) => SizedBox(width: width);
  static SizedBox gapV(double height) => SizedBox(height: height);

  // Box Shadow Helpers
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
