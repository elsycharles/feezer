import 'package:flutter/material.dart';

class Global {
  static const _baseUnit = 4.0;

  // Spacing System
  static const double spacingXs = _baseUnit * 1; // 4
  static const double spacingMd = _baseUnit * 4; // 16
  static const double spacingLg = _baseUnit * 6; // 24
  static const double spacingXl = _baseUnit * 8; // 32
  static const double spacingXxl = _baseUnit * 12; // 48

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusXl = 20.0;

  // Component Sizes
  static const double buttonHeight = 48.0;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 300);

  // Padding Helpers
  static EdgeInsets get padLg => const EdgeInsets.all(spacingLg);
  static EdgeInsets get padXl => const EdgeInsets.all(spacingXl);

  // Border Radius Helpers
  static BorderRadius get borderSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderXl => BorderRadius.circular(radiusXl);

  // Gap Helpers
  static SizedBox get gapSm =>
      const SizedBox(height: spacingXs, width: spacingXs);
  static SizedBox get gapMd =>
      const SizedBox(height: spacingMd, width: spacingMd);
  static SizedBox get gapLg =>
      const SizedBox(height: spacingLg, width: spacingLg);
  static SizedBox get gapXl =>
      const SizedBox(height: spacingXl, width: spacingXl);
}
