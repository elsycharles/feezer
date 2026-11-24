import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../styles/global.dart';
import '../../util/extensions_util.dart';
import '../../util/theme_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/loading_button.dart';
import 'widget/fee_interval_form.dart';

/// Creates a fee interval and returns it (not yet saved) to the caller.
class NewFeeIntervalScreen extends StatefulWidget {
  const NewFeeIntervalScreen({super.key, this.providerId});

  /// Provider whose intervals must not overlap the new one.
  final String? providerId;

  @override
  State<NewFeeIntervalScreen> createState() => _NewFeeIntervalScreenState();
}

class _NewFeeIntervalScreenState extends State<NewFeeIntervalScreen> {
  final _formKey = GlobalKey<FeeIntervalFormState>();
  bool _isSaving = false;

  Future<void> _create() async {
    setState(() => _isSaving = true);
    final interval = await _formKey.currentState!.submit();
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (interval != null) Navigator.of(context).pop(interval);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: custom.AppBar(title: l10n.newFeeInterval),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: Global.padLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.createNewFeeInterval,
                    style: ThemeUtil.titleLarge.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  Global.gapSm,
                  Text(
                    l10n.defineNewFeeStructure,
                    style: ThemeUtil.bodyMedium.copyWith(
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.7,
                      ),
                      height: 1.4,
                    ),
                  ),
                  Global.gapXl,
                  FeeIntervalForm(key: _formKey, providerId: widget.providerId),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              context.mediaQuery.padding.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              boxShadow: Global.shadowMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: LoadingButton(
                    text: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                    isOutlined: true,
                  ),
                ),
                Global.gapMd,
                Expanded(
                  flex: 2,
                  child: LoadingButton(
                    text: l10n.createInterval,
                    onPressed: _isSaving ? null : _create,
                    isLoading: _isSaving,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
