import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../model/currency_model.dart';
import '../../styles/global.dart';
import '../../util/theme_util.dart';
import '../../util/extensions_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/form_field.dart' as custom_form;
import '../../widget/loading_button.dart';
import '../../widget/app_toast.dart';
import '../../util/database_util.dart';
import '../../util/constant_util.dart';
import '../../util/navigation_util.dart';
import '../../screen/optimize_fee/widget/amount_input_widget.dart'; // For ThousandsSeparatorInputFormatter

/// Clean screen for creating new currencies
class NewCurrencyScreen extends StatefulWidget {
  const NewCurrencyScreen({super.key});

  @override
  State<NewCurrencyScreen> createState() => _State();
}

class _State extends State<NewCurrencyScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _codeController = TextEditingController();
  late final _nameController = TextEditingController();
  late final _symbolController = TextEditingController();
  late final _rateController = TextEditingController(text: '1.0');
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Reset loading state in case screen is reused
    _isCreating = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset loading state when screen becomes visible again
    if (mounted && _isCreating) {
      setState(() => _isCreating = false);
    }
  }

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
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: AppLocalizations.of(context).newCurrency,
        leading: null, // Will be handled by automaticallyImplyLeading
        automaticallyImplyLeading: ModalRoute.of(context)?.canPop ?? false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: Global.padLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      AppLocalizations.of(context).createNewCurrency,
                      style: ThemeUtil.titleLarge.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    Global.gapMd,
                    Text(
                      AppLocalizations.of(context).addNewCurrencyDescription,
                      style: ThemeUtil.bodyMedium.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Global.gapXl,

                    // Form fields
                    custom_form.FormField(
                      controller: _codeController,
                      label: AppLocalizations.of(context).currencyCode,
                      icon: Icons.code,
                      required: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(
                            context,
                          ).thisFieldIsRequired;
                        }
                        if (value!.length != 3) {
                          return AppLocalizations.of(
                            context,
                          ).currencyCodeMustBe3Characters;
                        }
                        if (!RegExp(r'^[A-Z]{3}$').hasMatch(value)) {
                          return AppLocalizations.of(
                            context,
                          ).currencyCodeMustContainOnlyUppercase;
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
                          return AppLocalizations.of(
                            context,
                          ).thisFieldIsRequired;
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
                          return AppLocalizations.of(
                            context,
                          ).thisFieldIsRequired;
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
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d\s\.]')),
                        ThousandsSeparatorInputFormatter(max: 99999999999.0),
                      ],
                      required: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return AppLocalizations.of(
                            context,
                          ).thisFieldIsRequired;
                        }
                        final cleanValue = value!.replaceAll(' ', '');
                        final rate = double.tryParse(cleanValue);
                        if (rate == null || rate <= 0) {
                          return AppLocalizations.of(
                            context,
                          ).pleaseEnterValidPositiveRate;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Create button at bottom
            Container(
              padding: Global.padLg,
              child: LoadingButton(
                onPressed: _createCurrency,
                isLoading: _isCreating,
                text: AppLocalizations.of(context).create,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createCurrency() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final currency = Currency(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        code: _codeController.text.trim().toUpperCase(),
        name: _nameController.text.trim(),
        symbol: _symbolController.text.trim(),
        rate: double.parse(_rateController.text.replaceAll(' ', '')),
      );

      final db = DatabaseUtil();
      await db.insert(ConstantUtil.tableCurrencies, currency.toMap());

      if (mounted) {
        AppToast.success(
          context,
          AppLocalizations.of(context).currencyCreatedSuccessfully,
        );
        NavigationUtil.safeBack(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          AppLocalizations.of(context).failedToCreateCurrency,
        );
        setState(() => _isCreating = false);
      }
    }
  }
}
