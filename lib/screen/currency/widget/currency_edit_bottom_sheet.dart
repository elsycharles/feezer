import 'package:flutter/material.dart' hide BottomSheet;

import '../../../l10n/app_localizations.dart';
import '../../../model/currency_model.dart';
import '../../../styles/global.dart';
import '../../../widget/bottom_sheet.dart';
import '../../../widget/form_field.dart' as custom_form;
import '../../../widget/loading_button.dart';
import '../../../widget/app_toast.dart';
import '../../../util/database_util.dart';
import '../../../util/constant_util.dart';

/// Clean currency editor
class CurrencyEditBottomSheet extends StatefulWidget {
  const CurrencyEditBottomSheet({
    super.key,
    required this.currency,
  });

  final Currency currency;

  static Future<bool?> show(
    BuildContext context,
    Currency currency,
  ) => BottomSheet.show<bool>(
    context,
    AppLocalizations.of(context).editCurrency,
    CurrencyEditBottomSheet(currency: currency),
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
    text: widget.currency.rate.toString(),
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
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          custom_form.FormField(
            controller: _codeController,
            label: AppLocalizations.of(context).currencyCode,
            icon: Icons.code,
            required: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'This field is required';
              }
              if (value!.length != 3) {
                return 'Code must be 3 characters';
              }
              return null;
            },
          ),
          Global.gapMd,
          custom_form.FormField(
            controller: _nameController,
            label: AppLocalizations.of(context).currencyName,
            icon: Icons.currency_exchange,
            required: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'This field is required';
              }
              return null;
            },
          ),
          Global.gapMd,
          custom_form.FormField(
            controller: _symbolController,
            label: AppLocalizations.of(context).currencySymbolLabel,
            icon: Icons.attach_money,
            required: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'This field is required';
              }
              return null;
            },
          ),
          Global.gapMd,
          custom_form.FormField(
            controller: _rateController,
            label: AppLocalizations.of(context).exchangeRate,
            icon: Icons.trending_up,
            keyboardType: TextInputType.number,
            required: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'This field is required';
              }
              final rate = double.tryParse(value!);
              if (rate == null || rate <= 0) {
                return 'Invalid rate';
              }
              return null;
            },
          ),
          Global.gapLg,
          LoadingButton(
            onPressed: _updateCurrency,
            isLoading: _isLoading,
            text: AppLocalizations.of(context).save,
          ),
        ],
      ),
    );
  }

  Future<void> _updateCurrency() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedCurrency = widget.currency.copyWith(
        code: _codeController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        symbol: _symbolController.text.trim(),
        rate: double.parse(_rateController.text),
      );

      final db = DatabaseUtil();
      await db.update(
        ConstantUtil.tableCurrencies,
        updatedCurrency.toMap(),
        where: '${ConstantUtil.columnId} = ?',
        whereArgs: [updatedCurrency.id],
      );

      if (mounted) {
        AppToast.success(
          context,
          AppLocalizations.of(context).currencyUpdatedSuccessfully,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Failed to update currency');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}