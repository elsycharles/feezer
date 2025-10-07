import 'package:flutter/material.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';

class ConstanteUtil {
  // App Information
  static const String appName = 'Feezer';
  
  // Get localized app title
  static String getAppTitle(BuildContext context) {
    return AppLocalizations.of(context).appTitle;
  }
}
