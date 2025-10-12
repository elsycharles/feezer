import 'package:flutter/material.dart' hide BottomSheet;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/fee_interval_model.dart';
import '../../../styles/global.dart';
import '../../../widget/bottom_sheet.dart';
import '../../../widget/form_field.dart' as custom_form;
import '../../../util/constant_util.dart';
import '../../../util/theme_util.dart';
import '../../../widget/app_toast.dart';
import '../../../widget/loading_button.dart';
import '../../../provider/currency_provider.dart';

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
  late FeeType _feeType;
  late final _minAmountController = TextEditingController(
    text: widget.feeInterval.minAmount != null
        ? ConstantUtil.formatCurrencyAmount(context.read<CurrencyProvider>().convertFromAriary(widget.feeInterval.minAmount!))
        : '',
  );
  late final _maxAmountController = TextEditingController(
    text: widget.feeInterval.maxAmount != null
        ? ConstantUtil.formatCurrencyAmount(context.read<CurrencyProvider>().convertFromAriary(widget.feeInterval.maxAmount!))
        : '',
  );
  late final _feeController = TextEditingController(
    text: widget.feeInterval.fee != null
        ? widget.feeInterval.feeType == FeeType.percentage
            ? widget.feeInterval.fee!.toStringAsFixed(2)
            : ConstantUtil.formatCurrencyAmount(context.read<CurrencyProvider>().convertFromAriary(widget.feeInterval.fee!))
        : '',
  );

  @override
  void initState() {
    super.initState();
    _feeType = widget.feeInterval.feeType;
  }

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
          label: '${AppLocalizations.of(context).minimumAmount} (${context.read<CurrencyProvider>().currencySymbol})',
          controller: _minAmountController,
          icon: Icons.money,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: _validateMinAmount,
          required: true,
        ),
        Global.gapLg,
        custom_form.FormField(
          label: '${AppLocalizations.of(context).maximumAmount} (${context.read<CurrencyProvider>().currencySymbol})',
          controller: _maxAmountController,
          icon: Icons.money,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: _validateMaxAmount,
          required: true,
        ),
        Global.gapLg,
        _buildFeeTypeSelector(),
        Global.gapLg,
        custom_form.FormField(
          label: _feeType == FeeType.percentage
              ? '${AppLocalizations.of(context).fee} (%)'
              : '${AppLocalizations.of(context).fee} (${context.read<CurrencyProvider>().currencySymbol})',
          controller: _feeController,
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
          inputFormatters: _feeType == FeeType.percentage
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
              : [FilteringTextInputFormatter.digitsOnly],
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

  Widget _buildFeeTypeSelector() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).feeType, // TODO: add to localizations
          style: TextStyle(
            fontSize: ThemeUtil.fontSizeLabelLarge,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _feeType = FeeType.fixed),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _feeType == FeeType.fixed
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _feeType == FeeType.fixed
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).fixedAmount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ThemeUtil.fontSizeLabelLarge,
                      color: _feeType == FeeType.fixed
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _feeType = FeeType.percentage),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _feeType == FeeType.percentage
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _feeType == FeeType.percentage
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).percentage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ThemeUtil.fontSizeLabelLarge,
                      color: _feeType == FeeType.percentage
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      return _feeType == FeeType.percentage
          ? AppLocalizations.of(context).pleaseEnterPercentage
          : AppLocalizations.of(context).pleaseEnterFeeAmount;
    }
    final fee = double.tryParse(value!);
    if (fee == null || fee < 0) {
      return _feeType == FeeType.percentage
          ? AppLocalizations.of(context).pleaseEnterValidPercentage
          : AppLocalizations.of(context).pleaseEnterValidFee;
    }
    if (_feeType == FeeType.percentage && fee > 100) {
      return AppLocalizations.of(context).percentageCannotExceed100;
    }
    return null;
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final feeInterval = FeeInterval(
          id: widget.feeInterval.id,
          minAmount: context.read<CurrencyProvider>().convertToAriary(ConstantUtil.parseLocalizedNumber(_minAmountController.text.trim()) ?? 0),
          maxAmount: context.read<CurrencyProvider>().convertToAriary(ConstantUtil.parseLocalizedNumber(_maxAmountController.text.trim()) ?? 0),
          fee: _feeType == FeeType.percentage
              ? (ConstantUtil.parseLocalizedNumber(_feeController.text.trim()) ?? 0)
              : context.read<CurrencyProvider>().convertToAriary(ConstantUtil.parseLocalizedNumber(_feeController.text.trim()) ?? 0),
          feeType: _feeType,
          creationDateTime: widget.feeInterval.creationDatetime,
        );

        // Simulate async operation
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          Navigator.of(context).pop();
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
