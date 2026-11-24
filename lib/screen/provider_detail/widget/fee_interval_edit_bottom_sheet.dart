import 'package:flutter/material.dart' hide BottomSheet;

import '../../../l10n/app_localizations.dart';
import '../../../model/fee_interval_model.dart';
import '../../../styles/global.dart';
import '../../../widget/bottom_sheet.dart';
import '../../../widget/loading_button.dart';
import '../../fee_interval/widget/fee_interval_form.dart';

/// Edits a fee interval. [onSave] persists the change and returns `true` on
/// success; the sheet then closes.
class FeeIntervalEditBottomSheet extends StatefulWidget {
  const FeeIntervalEditBottomSheet({
    super.key,
    required this.feeInterval,
    required this.providerId,
    required this.onSave,
  });

  final FeeInterval feeInterval;
  final String providerId;
  final Future<bool> Function(FeeInterval) onSave;

  static Future<void> show(
    BuildContext context,
    FeeInterval feeInterval,
    String providerId,
    Future<bool> Function(FeeInterval) onSave,
  ) => BottomSheet.show(
    context,
    AppLocalizations.of(context).editFeeInterval,
    FeeIntervalEditBottomSheet(
      feeInterval: feeInterval,
      providerId: providerId,
      onSave: onSave,
    ),
  );

  @override
  State<FeeIntervalEditBottomSheet> createState() => _State();
}

class _State extends State<FeeIntervalEditBottomSheet> {
  final _formKey = GlobalKey<FeeIntervalFormState>();
  bool _isSaving = false;

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final interval = await _formKey.currentState!.submit();
    final saved = interval != null && await widget.onSave(interval);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (saved) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      FeeIntervalForm(
        key: _formKey,
        initial: widget.feeInterval,
        providerId: widget.providerId,
      ),
      Global.gapXl,
      LoadingButton(
        text: AppLocalizations.of(context).saveChanges,
        isLoading: _isSaving,
        onPressed: _isSaving ? null : _save,
      ),
    ],
  );
}
