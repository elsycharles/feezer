import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../widget/app_toast.dart';

/// Opening links outside the app.
abstract final class LinkUtil {
  /// Opens [uri] in the matching app (browser, mail…); shows a toast when it
  /// cannot be opened.
  static Future<void> open(BuildContext context, Uri uri) async {
    final failed = AppLocalizations.of(context).failedToOpenLink;
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) AppToast.error(context, failed);
    } catch (_) {
      if (context.mounted) AppToast.error(context, failed);
    }
  }
}
