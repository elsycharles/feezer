import 'package:flutter/widgets.dart';

/// Dates with the year, in the app's languages: "Feb 17, 2025",
/// "17 févr. 2025", "17 Febroary 2025".
abstract final class DateLabel {
  static const _en = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static const _fr = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', //
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];
  static const _mg = [
    'Janoary', 'Febroary', 'Martsa', 'Aprily', 'Mey', 'Jona', //
    'Jolay', 'Aogositra', 'Septambra', 'Oktobra', 'Novambra', 'Desambra',
  ];

  static String format(DateTime date, String languageCode) {
    final month = date.month - 1;
    return switch (languageCode) {
      'fr' => '${date.day == 1 ? '1er' : date.day} ${_fr[month]} ${date.year}',
      'mg' => '${date.day} ${_mg[month]} ${date.year}',
      _ => '${_en[month]} ${date.day}, ${date.year}',
    };
  }
}

extension DateLabelContext on BuildContext {
  /// [date] formatted for the current language.
  String date(DateTime date) =>
      DateLabel.format(date, Localizations.localeOf(this).languageCode);
}
