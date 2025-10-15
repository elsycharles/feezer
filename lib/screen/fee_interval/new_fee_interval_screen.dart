import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:decimal/decimal.dart';

import '../../l10n/app_localizations.dart';
import '../../model/fee_interval_model.dart';
import '../../styles/global.dart';
import '../../util/theme_util.dart';
import '../../util/extensions_util.dart';
import '../../util/constant_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/form_field.dart' as custom_form;
import '../../widget/loading_button.dart';
import '../../widget/app_toast.dart';
import '../../provider/currency_provider.dart';
import '../../screen/optimize_fee/widget/amount_input_widget.dart'; // Pour ThousandsSeparatorInputFormatter

/// Clean screen for creating new fee intervals
class NewFeeIntervalScreen extends StatefulWidget {
  const NewFeeIntervalScreen({super.key, this.onFeeIntervalAdded});

  final Function(FeeInterval)? onFeeIntervalAdded;

  @override
  State<NewFeeIntervalScreen> createState() => _State();
}

class _State extends State<NewFeeIntervalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _minAmountController = TextEditingController();
  late final _maxAmountController = TextEditingController();
  late final _feeController = TextEditingController();
  FeeType _feeType = FeeType.fixed;
  bool _isCreating = false;

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.theme.scaffoldBackgroundColor,
    appBar: custom.AppBar(title: AppLocalizations.of(context).newFeeInterval),
    body: Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: Global.padLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  Global.gapXl,
                  _buildMinAmountField(),
                  Global.gapLg,
                  _buildMaxAmountField(),
                  Global.gapLg,
                  _buildFeeTypeSelector(),
                  Global.gapLg,
                  _buildFeeField(),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    ),
  );

  Widget _buildHeader() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        AppLocalizations.of(context).createNewFeeInterval,
        style: ThemeUtil.titleLarge.copyWith(
          color: context.colorScheme.onSurface,
        ),
      ),
      Global.gapSm,
      Text(
        AppLocalizations.of(context).defineNewFeeStructure,
        style: ThemeUtil.bodyMedium.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.4,
        ),
      ),
    ],
  );

  Widget _buildMinAmountField() => custom_form.FormField(
    label:
        '${AppLocalizations.of(context).minimumAmount} (${context.read<CurrencyProvider>().currencySymbol})',
    controller: _minAmountController,
    icon: Icons.money,
    hintText: AppLocalizations.of(context).enterMinimumAmount,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d\s\.]')),
      ThousandsSeparatorInputFormatter(max: 99999999999.0),
    ],
    validator: (value) {
      if (value?.isEmpty ?? true) {
        return AppLocalizations.of(context).thisFieldIsRequired;
      }
      final cleanValue = value!.replaceAll(' ', '');
      final amount = double.tryParse(cleanValue);
      if (amount == null || amount < 0) {
        return AppLocalizations.of(context).pleaseEnterValidAmount;
      }
      return null;
    },
    required: true,
  );

  Widget _buildMaxAmountField() => custom_form.FormField(
    label:
        '${AppLocalizations.of(context).maximumAmount} (${context.read<CurrencyProvider>().currencySymbol})',
    controller: _maxAmountController,
    icon: Icons.money,
    hintText: AppLocalizations.of(context).enterMaximumAmount,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'[\d\s\.]')),
      ThousandsSeparatorInputFormatter(max: 99999999999.0),
    ],
    validator: _validateMaxAmount,
    required: true,
  );

  Widget _buildFeeTypeSelector() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: context.colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).feeType,
          style: ThemeUtil.labelLarge.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        Global.gapMd,
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _feeType = FeeType.fixed),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _feeType == FeeType.fixed
                        ? context.colorScheme.primaryContainer
                        : context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _feeType == FeeType.fixed
                          ? context.colorScheme.primary
                          : context.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).fixedAmount,
                    textAlign: TextAlign.center,
                    style: ThemeUtil.bodyMedium.copyWith(
                      color: _feeType == FeeType.fixed
                          ? context.colorScheme.onPrimaryContainer
                          : context.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            Global.gapMd,
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _feeType = FeeType.percentage),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _feeType == FeeType.percentage
                        ? context.colorScheme.primaryContainer
                        : context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _feeType == FeeType.percentage
                          ? context.colorScheme.primary
                          : context.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).percentage,
                    textAlign: TextAlign.center,
                    style: ThemeUtil.bodyMedium.copyWith(
                      color: _feeType == FeeType.percentage
                          ? context.colorScheme.onPrimaryContainer
                          : context.colorScheme.onSurface,
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

  Widget _buildFeeField() => custom_form.FormField(
    label: _feeType == FeeType.percentage
        ? '${AppLocalizations.of(context).fee} (%)'
        : '${AppLocalizations.of(context).fee} (${context.read<CurrencyProvider>().currencySymbol})',
    controller: _feeController,
    icon: Icons.attach_money,
    hintText: _feeType == FeeType.percentage
        ? AppLocalizations.of(context).enterPercentage
        : AppLocalizations.of(context).enterFeeAmount,
    keyboardType: TextInputType.number,
    inputFormatters: _feeType == FeeType.percentage
        ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
        : [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s\.]')),
            ThousandsSeparatorInputFormatter(max: 99999999999.0),
          ],
    validator: (value) {
      if (value?.isEmpty ?? true) {
        return _feeType == FeeType.percentage
            ? AppLocalizations.of(context).pleaseEnterPercentage
            : AppLocalizations.of(context).pleaseEnterFeeAmount;
      }
      
      if (_feeType == FeeType.percentage) {
        final num? numValue = num.tryParse(value!);
        if (numValue == null || numValue < 0 || numValue > 100) {
          return AppLocalizations.of(context).percentageMustBeBetween0And100;
        }
      } else {
        final cleanValue = value!.replaceAll(' ', '');
        final amount = double.tryParse(cleanValue);
        if (amount == null || amount <= 0) {
          return AppLocalizations.of(context).pleaseEnterValidAmount;
        }
      }
      return null;
    },
    required: true,
  );

  Widget _buildActions() => Container(
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
            text: AppLocalizations.of(context).cancel,
            onPressed: () => Navigator.of(context).pop(),
            isLoading: false,
            isOutlined: true,
          ),
        ),
        Global.gapMd,
        Expanded(
          flex: 2,
          child: LoadingButton(
            text: AppLocalizations.of(context).createInterval,
            onPressed: _create,
            isLoading: _isCreating,
          ),
        ),
      ],
    ),
  );

  String? _validateMaxAmount(String? value) {
    if (value?.isEmpty ?? true) {
      return AppLocalizations.of(context).thisFieldIsRequired;
    }

    final cleanValue = value!.replaceAll(' ', '');
    final amountDecimal = ConstantUtil.parseLocalizedNumber(cleanValue);
    if (amountDecimal == null) {
      return AppLocalizations.of(context).invalidAmount;
    }
    final amount = amountDecimal.toDouble();
    
    if (amount < 0) {
      return AppLocalizations.of(context).pleaseEnterValidAmount;
    }
    
    final minCleanValue = _minAmountController.text.replaceAll(' ', '');
    final minAmount = double.tryParse(minCleanValue) ?? 0;
    if (amount <= minAmount) {
      return AppLocalizations.of(context).maxAmountMustBeGreater;
    }
    return null;
  }

  void _create() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isCreating = true);

      // Simulate creation process
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        final now = DateTime.now();
        
        final minCleanValue = _minAmountController.text.trim().replaceAll(' ', '');
        final maxCleanValue = _maxAmountController.text.trim().replaceAll(' ', '');
        final feeCleanValue = _feeController.text.trim().replaceAll(' ', '');
        
        final feeInterval = FeeInterval(
          id: now.millisecondsSinceEpoch.toString(),
          minAmount: context.read<CurrencyProvider>().convertToAriary(
            (ConstantUtil.parseLocalizedNumber(minCleanValue) ?? Decimal.zero).toDouble(),
          ),
          maxAmount: context.read<CurrencyProvider>().convertToAriary(
            (ConstantUtil.parseLocalizedNumber(maxCleanValue) ?? Decimal.zero).toDouble(),
          ),
          fee: _feeType == FeeType.percentage
              ? ((ConstantUtil.parseLocalizedNumber(feeCleanValue) ?? Decimal.zero).toDouble())
              : context.read<CurrencyProvider>().convertToAriary(
                  (ConstantUtil.parseLocalizedNumber(feeCleanValue) ?? Decimal.zero).toDouble(),
                ),
          feeType: _feeType,
          creationDateTime: now,
        );
        widget.onFeeIntervalAdded?.call(feeInterval);
        AppToast.success(
          context,
          AppLocalizations.of(context).feeIntervalCreatedSuccessfully,
        );
        Navigator.of(context).pop(feeInterval);
      }
    }
  }
}
