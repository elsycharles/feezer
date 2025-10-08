import 'package:flutter/material.dart';

/// Supported locale model with name and display name
class SupportedLocale {
  final Locale locale;
  final String displayName;
  final String nativeName;

  const SupportedLocale({
    required this.locale,
    required this.displayName,
    required this.nativeName,
  });

  static const List<SupportedLocale> supportedLocales = [
    SupportedLocale(
      locale: Locale('en'),
      displayName: 'English',
      nativeName: 'English',
    ),
    SupportedLocale(
      locale: Locale('fr'),
      displayName: 'French',
      nativeName: 'Français',
    ),
    SupportedLocale(
      locale: Locale('mg'),
      displayName: 'Malagasy',
      nativeName: 'Malagasy',
    ),
  ];
}
