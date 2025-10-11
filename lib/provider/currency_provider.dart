import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fee_minimizer/model/currency_model.dart';
import 'package:fee_minimizer/util/database_util.dart';
import 'package:fee_minimizer/util/constant_util.dart';

/// Provider for managing the currently selected currency
class CurrencyProvider extends ChangeNotifier {
  static const String _selectedCurrencyIdKey = 'selected_currency_id';
  static const String _currenciesInitializedKey = 'currencies_initialized';

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

  /// Get the exchange rate for the selected currency
  double get exchangeRate => _selectedCurrency?.rate ?? 1.0;

  /// Initialize the selected currency from shared preferences
  Future<void> initializeCurrency() async {
    if (_isInitialized) return;

    // Insert default currencies if not already done
    await _ensureDefaultCurrencies();

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

  /// Ensure default currencies are inserted in the database
  Future<void> _ensureDefaultCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_currenciesInitializedKey) ?? false;

    if (isInitialized) return;

    final db = DatabaseUtil();
    final defaultCurrencies = [
      Currency(
        id: 'eur',
        code: 'EUR',
        name: 'Euro',
        symbol: '€',
        rate: 5200.0, // 5200 Ar = 1€
      ),
      Currency(
        id: 'mga',
        code: 'MGA',
        name: 'Ariary',
        symbol: 'Ar',
        rate: 1.0, // 1 Ar = 1 Ar (base currency)
      ),
      Currency(
        id: 'usd',
        code: 'USD',
        name: 'US Dollar',
        symbol: '\$',
        rate: 4478.8, // 4478.8 Ar = 1$
      ),
    ];

    for (final currency in defaultCurrencies) {
      try {
        await db.insert(ConstantUtil.tableCurrencies, currency.toMap());
      } catch (e) {
        // Currency might already exist, continue
      }
    }

    await prefs.setBool(_currenciesInitializedKey, true);
  }

  /// Convert amount from Ariary (base currency) to selected currency
  double convertFromAriary(double ariaryAmount) {
    if (_selectedCurrency == null) return ariaryAmount;
    return ariaryAmount / _selectedCurrency!.rate;
  }

  /// Convert amount from selected currency to Ariary (base currency)
  double convertToAriary(double amount) {
    if (_selectedCurrency == null) return amount;
    return amount * _selectedCurrency!.rate;
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

  /// Load Ariary currency specifically
  Future<void> _loadAriaryCurrency() async {
    try {
      final db = DatabaseUtil();
      final currencyMaps = await db.query(
        ConstantUtil.tableCurrencies,
        where: '${ConstantUtil.columnCode} = ?',
        whereArgs: ['MGA'],
      );

      if (currencyMaps.isNotEmpty) {
        _selectedCurrency = Currency.fromMap(currencyMaps.first);
      } else {
        // If Ariary doesn't exist, fall back to default loading
        await _loadDefaultCurrency();
      }
    } catch (e) {
      // If loading fails, fall back to default loading
      await _loadDefaultCurrency();
    }
  }

  /// Load the first available currency as default, preferring Ariary (MGA)
  Future<void> _loadDefaultCurrency() async {
    try {
      final db = DatabaseUtil();
      final currencyMaps = await db.query(ConstantUtil.tableCurrencies);

      if (currencyMaps.isNotEmpty) {
        // First try to find Ariary (MGA) as the default currency
        final ariaryMap = currencyMaps.firstWhere(
          (map) => map[ConstantUtil.columnCode] == 'MGA',
          orElse: () => currencyMaps.first,
        );

        _selectedCurrency = Currency.fromMap(ariaryMap);
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

  /// Clear selected currency (reset to Ariary as system default)
  Future<void> clearSelectedCurrency() async {
    // Always reset to Ariary (MGA) as the system default
    await _loadAriaryCurrency();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedCurrencyIdKey);
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