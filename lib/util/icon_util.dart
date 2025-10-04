import 'package:flutter/material.dart';

/// Utility class for provider icons
class IconUtil {
  static const Map<String, IconData> _icons = {
    'business': Icons.business,
    'account_balance': Icons.account_balance,
    'phone_android': Icons.phone_android,
    'credit_card': Icons.credit_card,
    'account_balance_wallet': Icons.account_balance_wallet,
    'payment': Icons.payment,
    'money': Icons.monetization_on,
    'savings': Icons.savings,
    'currency_exchange': Icons.currency_exchange,
    'wallet': Icons.wallet,
    'card_membership': Icons.card_membership,
    'mobile_friendly': Icons.mobile_friendly,
    'store': Icons.store,
    'local_atm': Icons.local_atm,
    'bank': Icons.account_balance,
    'group': Icons.people_alt,
  };

  static IconData getIcon(String iconName) => _icons[iconName] ?? Icons.business;

  static List<String> get availableIcons => _icons.keys.toList();

  static String getIconName(IconData icon) =>
      _icons.entries.firstWhere((e) => e.value == icon, orElse: () => const MapEntry('business', Icons.business)).key;
}