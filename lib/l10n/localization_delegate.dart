import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Custom localization delegate that provides fallback for unsupported locales
/// This ensures Material and Cupertino components work with Malagasy (mg) locale
/// by falling back to English when Material/Cupertino delegates don't support the locale
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support all locales, but fall back to English for unsupported ones
    return true;
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // If the locale is supported by Material, use it
    if (GlobalMaterialLocalizations.delegate.isSupported(locale)) {
      return await GlobalMaterialLocalizations.delegate.load(locale);
    }

    // Otherwise, fall back to English
    return await GlobalMaterialLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(FallbackMaterialLocalizationsDelegate old) => false;
}

/// Custom Cupertino localization delegate with fallback
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Support all locales, but fall back to English for unsupported ones
    return true;
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    // If the locale is supported by Cupertino, use it
    if (GlobalCupertinoLocalizations.delegate.isSupported(locale)) {
      return await GlobalCupertinoLocalizations.delegate.load(locale);
    }

    // Otherwise, fall back to English
    return await GlobalCupertinoLocalizations.delegate.load(const Locale('en'));
  }

  @override
  bool shouldReload(FallbackCupertinoLocalizationsDelegate old) => false;
}
