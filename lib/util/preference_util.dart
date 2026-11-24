import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class PreferenceUtil {
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyThemeMode = 'theme_mode';

  /// Checks if this is the first launch of the application
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// Marks the application as having been launched at least once
  static Future<void> setFirstLaunchCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  static const String _keyLastGrid = 'last_grid_id';

  /// Grid selected the last time the optimizer was used.
  static Future<String?> lastGridId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastGrid);
  }

  static Future<void> setLastGridId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastGrid, id);
  }

  static const String _keyWithdrawalStep = 'amount_step_withdrawal';
  static const String _keyTransferStep = 'amount_step_transfer';

  /// Cash points only hand out notes: withdrawals default to multiples of 100.
  static const int defaultWithdrawalStep = 100;

  /// Every amount of a plan is a multiple of this step (0: any amount), for
  /// withdrawals or for transfers.
  static Future<int> amountStep({required bool withdrawal}) async {
    final prefs = await SharedPreferences.getInstance();
    return withdrawal
        ? prefs.getInt(_keyWithdrawalStep) ?? defaultWithdrawalStep
        : prefs.getInt(_keyTransferStep) ?? 0;
  }

  static Future<void> setAmountStep(
    int step, {
    required bool withdrawal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      withdrawal ? _keyWithdrawalStep : _keyTransferStep,
      step,
    );
  }

  /// Gets the saved theme mode
  static Future<AppThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_keyThemeMode) ?? AppThemeMode.system.index;
    return index >= 0 && index < AppThemeMode.values.length
        ? AppThemeMode.values[index]
        : AppThemeMode.system;
  }

  /// Saves the theme mode preference
  static Future<void> setThemeMode(AppThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyThemeMode, themeMode.index);
  }

  /// Converts AppThemeMode to Flutter's ThemeMode
  static ThemeMode convertToFlutterThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
