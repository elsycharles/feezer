import 'package:flutter/material.dart';
import '../util/preference_util.dart';

/// Provider to manage theme state across the app
class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.system;

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get flutterThemeMode =>
      PreferenceUtil.convertToFlutterThemeMode(_themeMode);

  /// Initialize theme from saved preferences
  Future<void> initializeTheme() async {
    _themeMode = await PreferenceUtil.getThemeMode();
    notifyListeners();
  }

  /// Changes the theme mode and saves preference
  Future<void> setThemeMode(AppThemeMode newThemeMode) async {
    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      await PreferenceUtil.setThemeMode(newThemeMode);
      notifyListeners();
    }
  }
}
