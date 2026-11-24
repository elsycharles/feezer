import 'package:flutter/material.dart' hide BottomSheet;

import '../../../l10n/app_localizations.dart';
import '../../../model/currency_model.dart';
import '../../../styles/global.dart';
import '../../../widget/bottom_sheet.dart';
import '../../../widget/form_field.dart' as custom_form;
import '../../../widget/loading_button.dart';
import '../../../widget/app_toast.dart';
import '../../../util/constant_util.dart';
import '../../../widget/amount_input_formatter.dart';

/// Clean currency editor
class CurrencyEditBottomSheet extends StatefulWidget {
  const CurrencyEditBottomSheet({
    super.key,
    required this.currency,
    required this.onSave,
  });

  final Currency currency;

  /// Persists the currency; returns an error message, or `null` on success.
  final Future<String?> Function(Currency) onSave;

  static Future<void> show(
    BuildContext context,
    Currency currency,
    Future<String?> Function(Currency) onSave,
  ) => BottomSheet.show(
    context,
    AppLocalizations.of(context).editCurrency,
    CurrencyEditBottomSheet(currency: currency, onSave: onSave),
  );

  @override
  State<CurrencyEditBottomSheet> createState() => _State();
}

class _State extends State<CurrencyEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late final _codeController = TextEditingController(
    text: widget.currency.code,
  );
  late final _nameController = TextEditingController(
    text: widget.currency.name,
  );
  late final _symbolController = TextEditingController(
    text: widget.currency.symbol,
  );
  late final _rateController = TextEditingController(
    text: ConstantUtil.formatAmountInput(widget.currency.rate),
  );

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      children: [
        custom_form.FormField(
          label: AppLocalizations.of(context).currencyCode,
          controller: _codeController,
          icon: Icons.code,
          required: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return AppLocalizations.of(context).thisFieldIsRequired;
            }
            if (value!.length != 3) {
              return AppLocalizations.of(context).codeMustBe3Characters;
            }
            if (!RegExp(r'^[A-Z]{3}$').hasMatch(value.toUpperCase())) {
              return AppLocalizations.of(
                context,
              ).currencyCodeMustContainOnlyUppercase;
            }
            return null;
          },
        ),
        Global.gapLg,
        custom_form.FormField(
          label: AppLocalizations.of(context).currencyName,
          controller: _nameController,
          icon: Icons.currency_exchange,
          required: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return AppLocalizations.of(context).thisFieldIsRequired;
            }
            return null;
          },
        ),
        Global.gapLg,
        custom_form.FormField(
          label: AppLocalizations.of(context).currencySymbolLabel,
          controller: _symbolController,
          icon: Icons.attach_money,
          required: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return AppLocalizations.of(context).thisFieldIsRequired;
            }
            return null;
          },
        ),
        Global.gapLg,
        if (widget.currency.isBase)
          Text(
            AppLocalizations.of(context).baseCurrencyRateIsFixed,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          custom_form.FormField(
            label: AppLocalizations.of(context).exchangeRate,
            controller: _rateController,
            icon: Icons.trending_up,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              AmountInputFormatter(max: ConstantUtil.maxInputAmount),
            ],
            required: true,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return AppLocalizations.of(context).thisFieldIsRequired;
              }
              final rate = ConstantUtil.parseLocalizedNumber(value!);
              if (rate == null || rate <= 0) {
                return AppLocalizations.of(
                  context,
                ).pleaseEnterValidPositiveRate;
              }
              return null;
            },
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final base = widget.currency.isBase;
    final currency = widget.currency.copyWith(
      // The base currency keeps its code and a rate of 1.
      code: base
          ? widget.currency.code
          : _codeController.text.trim().toUpperCase(),
      name: _nameController.text.trim(),
      symbol: _symbolController.text.trim(),
      rate: base ? 1 : ConstantUtil.parseLocalizedNumber(_rateController.text),
    );
    final error = await widget.onSave(currency);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      AppToast.error(context, error);
      return;
    }
    AppToast.success(
      context,
      AppLocalizations.of(context).currencyUpdatedSuccessfully,
    );
    Navigator.of(context).pop();
  }
}
