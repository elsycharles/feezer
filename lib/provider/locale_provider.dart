import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fee_minimizer/model/locale_model.dart';

/// Provider for managing app locale/language settings
class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  Locale? _locale;

  Locale? get locale => _locale;

  /// Initialize locale from shared preferences
  Future<void> initializeLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);

    if (localeCode != null) {
      // Find the locale in supported locales
      final supportedLocale = SupportedLocale.supportedLocales
          .where((sl) => sl.locale.languageCode == localeCode)
          .firstOrNull;

      if (supportedLocale != null) {
        _locale = supportedLocale.locale;
        notifyListeners();
      }
    }
  }

  /// Set locale and save to preferences
  Future<void> setLocale(Locale locale) async {
    if (_locale != locale) {
      _locale = locale;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);

      notifyListeners();
    }
  }

  /// Clear locale (use system default)
  Future<void> clearLocale() async {
    if (_locale != null) {
      _locale = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);

      notifyListeners();
    }
  }

  /// Get current supported locale info
  SupportedLocale? get currentSupportedLocale {
    if (_locale == null) return null;

    return SupportedLocale.supportedLocales
        .where((sl) => sl.locale.languageCode == _locale!.languageCode)
        .firstOrNull;
  }
}
