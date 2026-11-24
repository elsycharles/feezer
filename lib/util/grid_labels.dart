import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../model/fee_operation.dart';
import '../model/provider_model.dart';
import 'date_label.dart';

/// Human labels of fee grids.
abstract final class GridLabels {
  static String operation(AppLocalizations l10n, FeeOperation? operation) =>
      switch (operation) {
        FeeOperation.withdrawal => l10n.opWithdrawal,
        FeeOperation.transferSame => l10n.opTransferSame,
        FeeOperation.transferSameApp => l10n.opTransferSameApp,
        FeeOperation.transferOther => l10n.opTransferOther,
        FeeOperation.transferMicrofinance => l10n.opTransferMicrofinance,
        FeeOperation.transferUnregistered => l10n.opTransferUnregistered,
        null => l10n.opCustom,
      };

  /// "MVola · Retrait".
  static String title(
    AppLocalizations l10n,
    String name,
    FeeOperation? operation,
  ) => operation == null
      ? name
      : '$name · ${GridLabels.operation(l10n, operation)}';

  /// Host of the official page, without "www.".
  static String? host(String? url) {
    final host = Uri.tryParse(url ?? '')?.host ?? '';
    if (host.isEmpty) return null;
    return host.startsWith('www.') ? host.substring(4) : host;
  }

  /// "Grille officielle mvola.mg · 17 févr. 2025", "Grille modifiée par
  /// vous"…, or `null` for grids entered in the app.
  static String? source(BuildContext context, Provider provider) {
    final l10n = AppLocalizations.of(context);
    final date = provider.effectiveDate == null
        ? null
        : context.date(provider.effectiveDate!);
    final host = GridLabels.host(provider.sourceUrl);
    switch (provider.sourceType) {
      case Provider.officialSource:
        if (host == null) return l10n.sourceManual;
        return date == null
            ? l10n.sourceOfficial(host)
            : l10n.sourceOfficialDated(host, date);
      case Provider.manualSource:
        return date == null ? l10n.sourceManual : l10n.sourceManualDated(date);
      case Provider.editedSource:
        return l10n.sourceEdited;
      default:
        return null;
    }
  }
}
