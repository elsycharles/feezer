import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fee_minimizer/model/currency_model.dart';
import 'package:fee_minimizer/util/database_util.dart';
import 'package:fee_minimizer/util/constant_util.dart';

/// Provider for managing the currently selected currency
class CurrencyProvider extends ChangeNotifier {
  static const String _selectedCurrencyIdKey = 'selected_currency_id';

  Currency? _selectedCurrency;
  bool _isInitialized = false;

  Currency? get selectedCurrency => _selectedCurrency;
  bool get isInitialized => _isInitialized;

  /// Get the currency symbol for display
  String get currencySymbol => _selectedCurrency?.symbol ?? 'Ar'; // Default to 'Ar' if no currency selected

  /// Get the currency code for display
  String get currencyCode => _selectedCurrency?.code ?? 'MGA'; // Default to MGA

  /// Get the currency name for display
  String get currencyName => _selectedCurrency?.name ?? 'Ariary';

  /// Initialize the selected currency from shared preferences
  Future<void> initializeCurrency() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final selectedCurrencyId = prefs.getString(_selectedCurrencyIdKey);

    if (selectedCurrencyId != null) {
      await _loadCurrencyById(selectedCurrencyId);
    } else {
      // If no currency is selected, try to load the first available currency
      await _loadDefaultCurrency();
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Load currency by ID from database
  Future<void> _loadCurrencyById(String currencyId) async {
    try {
      final db = DatabaseUtil();
      final currencyMaps = await db.query(
        ConstantUtil.tableCurrencies,
        where: '${ConstantUtil.columnId} = ?',
        whereArgs: [currencyId],
      );

      if (currencyMaps.isNotEmpty) {
        _selectedCurrency = Currency.fromMap(currencyMaps.first);
      }
    } catch (e) {
      // If loading fails, try to load default currency
      await _loadDefaultCurrency();
    }
  }

  /// Load the first available currency as default
  Future<void> _loadDefaultCurrency() async {
    try {
      final db = DatabaseUtil();
      final currencyMaps = await db.query(ConstantUtil.tableCurrencies);

      if (currencyMaps.isNotEmpty) {
        _selectedCurrency = Currency.fromMap(currencyMaps.first);
        // Save this as the selected currency
        await _saveSelectedCurrencyId(_selectedCurrency!.id);
      }
    } catch (e) {
      // If no currencies exist in database, keep _selectedCurrency as null
      // The app will use default values
    }
  }

  /// Set the selected currency
  Future<void> setSelectedCurrency(Currency currency) async {
    if (_selectedCurrency?.id != currency.id) {
      _selectedCurrency = currency;
      await _saveSelectedCurrencyId(currency.id);
      notifyListeners();
    }
  }

  /// Save selected currency ID to shared preferences
  Future<void> _saveSelectedCurrencyId(String currencyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCurrencyIdKey, currencyId);
  }

  /// Clear selected currency (reset to default)
  Future<void> clearSelectedCurrency() async {
    _selectedCurrency = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedCurrencyIdKey);
    await _loadDefaultCurrency();
    notifyListeners();
  }

  /// Refresh the selected currency (useful when currency data is updated)
  Future<void> refreshSelectedCurrency() async {
    if (_selectedCurrency != null) {
      await _loadCurrencyById(_selectedCurrency!.id);
      notifyListeners();
    } else {
      await _loadDefaultCurrency();
    }
  }
}