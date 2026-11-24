import 'package:flutter/material.dart';

/// Icons of operators without brand colors. Names are stored in the database,
/// so existing names must stay readable.
abstract final class IconUtil {
  static const Map<String, IconData> _icons = {
    'phone_android': Icons.phone_android_rounded,
    'account_balance': Icons.account_balance_outlined,
    'account_balance_wallet': Icons.account_balance_wallet_outlined,
    'credit_card': Icons.credit_card_rounded,
    'store': Icons.storefront_outlined,
    'savings': Icons.savings_outlined,
    'local_atm': Icons.local_atm_rounded,
    'business': Icons.business_rounded,
    'payment': Icons.payment_rounded,
    'money': Icons.payments_outlined,
    'currency_exchange': Icons.currency_exchange_rounded,
    'wallet': Icons.wallet_rounded,
    'card_membership': Icons.card_membership_rounded,
    'mobile_friendly': Icons.mobile_friendly_rounded,
    'bank': Icons.account_balance_outlined,
    'group': Icons.people_alt_outlined,
  };

  /// Icons offered in the form.
  static const List<String> choices = [
    'phone_android',
    'account_balance',
    'account_balance_wallet',
    'credit_card',
    'store',
    'savings',
    'local_atm',
    'business',
  ];

  static IconData getIcon(String iconName) =>
      _icons[iconName] ?? Icons.business_rounded;
}
