import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/currency_repository.dart';
import '../model/currency_model.dart';

/// Currently selected display currency.
///
/// Every amount is stored in Ariary (base currency) and converted on display
/// with [convertFromAriary] / on input with [convertToAriary].
class CurrencyProvider extends ChangeNotifier {
  CurrencyProvider({CurrencyRepository? repository})
    : _repository = repository ?? CurrencyRepository();

  static const String _selectedCurrencyIdKey = 'selected_currency_id';
  static const String _currenciesInitializedKey = 'currencies_initialized';

  final CurrencyRepository _repository;

  Currency? _selectedCurrency;
  bool _isInitialized = false;

  Currency? get selectedCurrency => _selectedCurrency;
  bool get isInitialized => _isInitialized;

  String get currencySymbol => _selectedCurrency?.symbol ?? 'Ar';
  String get currencyCode => _selectedCurrency?.code ?? Currency.baseCode;
  String get currencyName => _selectedCurrency?.name ?? 'Ariary';
  double get exchangeRate => _selectedCurrency?.rate ?? 1.0;
  bool get isBaseCurrency => _selectedCurrency?.isBase ?? true;

  double convertFromAriary(double ariaryAmount) => ariaryAmount / exchangeRate;

  double convertToAriary(double amount) => amount * exchangeRate;

  Future<void> initializeCurrency() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    try {
      final firstRun = !(prefs.getBool(_currenciesInitializedKey) ?? false);
      // Optional defaults are only inserted once (the user may delete them);
      // the base currency is always restored.
      await _repository.ensureDefaults(includeOptional: firstRun);
      if (firstRun) await prefs.setBool(_currenciesInitializedKey, true);

      final selectedId = prefs.getString(_selectedCurrencyIdKey);
      _selectedCurrency = selectedId == null
          ? null
          : await _repository.getById(selectedId);
      _selectedCurrency ??= await _repository.getByCode(Currency.baseCode);
    } catch (e) {
      debugPrint('Currency initialization failed: $e');
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setSelectedCurrency(Currency currency) async {
    if (_selectedCurrency == currency) return;
    _selectedCurrency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCurrencyIdKey, currency.id);
  }

  /// Selects the base currency (Ariary).
  Future<void> clearSelectedCurrency() async {
    final base = await _repository.getByCode(Currency.baseCode);
    _selectedCurrency = base;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedCurrencyIdKey);
    notifyListeners();
  }

  /// Reloads the selected currency after the currency list was edited (rate
  /// changed, currency deleted...).
  Future<void> refreshSelectedCurrency() async {
    final current = _selectedCurrency;
    final reloaded = current == null
        ? null
        : await _repository.getById(current.id);
    if (reloaded == null) {
      await clearSelectedCurrency();
      return;
    }
    if (reloaded != current || reloaded.symbol != current?.symbol) {
      _selectedCurrency = reloaded;
      notifyListeners();
    }
  }
}
