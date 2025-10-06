import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtil {
  static const String _keyFirstLaunch = 'first_launch';

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

  /// Resets the first launch status (useful for testing)
  static Future<void> resetFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFirstLaunch);
  }
}
