import 'package:flutter/material.dart' hide BottomSheet;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/fee_interval_model.dart';
import '../../../styles/global.dart';
import '../../../widget/bottom_sheet.dart';
import '../../../widget/form_field.dart' as custom_form;
import '../../../widget/loading_button.dart';
import '../../../widget/app_toast.dart';

/// Clean fee interval editor
class FeeIntervalEditBottomSheet extends StatefulWidget {
  const FeeIntervalEditBottomSheet({
    super.key,
    required this.feeInterval,
    required this.onSave,
  });

  final FeeInterval feeInterval;
  final Function(FeeInterval) onSave;

  static Future<void> show(
    BuildContext context,
    FeeInterval feeInterval,
    Function(FeeInterval) onSave,
  ) => BottomSheet.show(
    context,
    AppLocalizations.of(context).editFeeInterval,
    FeeIntervalEditBottomSheet(feeInterval: feeInterval, onSave: onSave),
  );

  @override
  State<FeeIntervalEditBottomSheet> createState() => _State();
}

class _State extends State<FeeIntervalEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late final _minAmountController = TextEditingController(
    text: widget.feeInterval.minAmount?.toString() ?? '',
  );
  late final _maxAmountController = TextEditingController(
    text: widget.feeInterval.maxAmount?.toString() ?? '',
  );
  late final _feeController = TextEditingController(
    text: widget.feeInterval.fee?.toString() ?? '',
  );

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      children: [
        custom_form.FormField(
          label: AppLocalizations.of(context).minimumAmountAr,
          controller: _minAmountController,
          icon: Icons.money,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: _validateMinAmount,
          required: true,
        ),
        Global.gapLg,
        custom_form.FormField(
          label: AppLocalizations.of(context).maximumAmountAr,
          controller: _maxAmountController,
          icon: Icons.money,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: _validateMaxAmount,
          required: true,
        ),
        Global.gapLg,
        custom_form.FormField(
          label: AppLocalizations.of(context).feeAr,
          controller: _feeController,
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: _validateFee,
          required: true,
        ),
        Global.gapXl,
        LoadingButton(
          text: AppLocalizations.of(context).saveChanges,
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _save,
        ),
      ],
    ),
  );

  String? _validateMinAmount(String? value) {
    if (value?.isEmpty ?? true) {
      return AppLocalizations.of(context).pleaseEnterMinAmount;
    }
    final amount = double.tryParse(value!);
    if (amount == null || amount < 0) {
      return AppLocalizations.of(context).pleaseEnterValidAmount;
    }
    return null;
  }

  String? _validateMaxAmount(String? value) {
    if (value?.isEmpty ?? true) {
      return AppLocalizations.of(context).pleaseEnterMaxAmount;
    }
    final amount = double.tryParse(value!);
    if (amount == null || amount < 0) {
      return AppLocalizations.of(context).pleaseEnterValidAmount;
    }

    final minAmount = double.tryParse(_minAmountController.text) ?? 0;
    if (amount <= minAmount) {
      return AppLocalizations.of(context).maxAmountMustBeGreaterThanMinAmount;
    }
    return null;
  }

  String? _validateFee(String? value) {
    if (value?.isEmpty ?? true) {
      return AppLocalizations.of(context).pleaseEnterFeeAmount;
    }
    final fee = double.tryParse(value!);
    if (fee == null || fee < 0) {
      return AppLocalizations.of(context).pleaseEnterValidFee;
    }
    return null;
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final feeInterval = FeeInterval(
          id: widget.feeInterval.id,
          minAmount: double.parse(_minAmountController.text.trim()),
          maxAmount: double.parse(_maxAmountController.text.trim()),
          fee: double.parse(_feeController.text.trim()),
          creationDateTime: widget.feeInterval.creationDatetime,
        );

        // Simulate async operation
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          GoRouter.of(context).pop();
          widget.onSave(feeInterval);
          AppToast.success(
            context,
            AppLocalizations.of(context).feeIntervalUpdatedSuccessfully,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
