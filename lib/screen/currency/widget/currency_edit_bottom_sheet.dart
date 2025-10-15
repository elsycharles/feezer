import 'package:flutter/material.dart' hide BottomSheet;
import 'package:flutter/services.dart';

import '../../../l10n/app_localizations.dart';
import '../../../model/currency_model.dart';
import '../../../styles/global.dart';
import '../../../widget/bottom_sheet.dart';
import '../../../widget/form_field.dart' as custom_form;
import '../../../widget/loading_button.dart';
import '../../../widget/app_toast.dart';
import '../../../screen/optimize_fee/widget/amount_input_widget.dart'; // Pour ThousandsSeparatorInputFormatter

/// Clean currency editor
class CurrencyEditBottomSheet extends StatefulWidget {
  const CurrencyEditBottomSheet({
    super.key,
    required this.currency,
    required this.onSave,
  });

  final Currency currency;
  final Function(Currency) onSave;

  static Future<void> show(
    BuildContext context,
    Currency currency,
    Function(Currency) onSave,
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
    text: _formatRate(widget.currency.rate),
  );

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  String _formatRate(double value) {
    String valueStr;
    
    if (value == value.toInt()) {
      valueStr = value.toInt().toString();
    } else {
      String tempStr = value.toString();
      if (tempStr.contains('.')) {
        List<String> parts = tempStr.split('.');
        String decimalPart = parts[1].replaceAll(RegExp(r'0+$'), '');
        if (decimalPart.isEmpty) {
          valueStr = parts[0];
        } else {
          valueStr = '${parts[0]}.$decimalPart';
        }
      } else {
        valueStr = tempStr;
      }
    }
    
    List<String> parts = valueStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = ' $formatted';
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    
    if (decimalPart.isNotEmpty) {
      formatted += '.$decimalPart';
    }
    
    return formatted;
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
            if (!RegExp(r'^[A-Z]{3}$').hasMatch(value)) {
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
        custom_form.FormField(
          label: AppLocalizations.of(context).exchangeRate,
          controller: _rateController,
          icon: Icons.trending_up,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d\s\.]')),
            ThousandsSeparatorInputFormatter(max: 99999999999.0),
          ],
          required: true,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return AppLocalizations.of(context).thisFieldIsRequired;
            }
            final cleanValue = value!.replaceAll(' ', '');
            final rate = double.tryParse(cleanValue);
            if (rate == null || rate <= 0) {
              return AppLocalizations.of(context).pleaseEnterValidPositiveRate;
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

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final currency = Currency(
          id: widget.currency.id,
          code: _codeController.text.trim().toUpperCase(),
          name: _nameController.text.trim(),
          symbol: _symbolController.text.trim(),
          rate: double.parse(_rateController.text.replaceAll(' ', '')),
        );

        // Simulate async operation
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          Navigator.of(context).pop();
          widget.onSave(currency);
          AppToast.success(
            context,
            AppLocalizations.of(context).currencyUpdatedSuccessfully,
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
