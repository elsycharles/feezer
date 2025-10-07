import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../model/fee_interval_model.dart';
import '../../styles/global.dart';
import '../../util/theme_util.dart';
import '../../util/extensions_util.dart';
import '../../util/validation_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/form_field.dart' as custom_form;
import '../../widget/loading_button.dart';
import '../../widget/app_toast.dart';

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
    appBar: custom.AppBar(
      title: AppLocalizations.of(context).newFeeInterval,
      leading: IconButton(
        onPressed: context.pop,
        icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
      ),
    ),
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
    label: 'Minimum Amount (Ar)',
    controller: _minAmountController,
    icon: Icons.money,
    hintText: AppLocalizations.of(context).enterMinimumAmount,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) => ValidationUtil.positiveNumber(value, AppLocalizations.of(context).minimumAmount),
    required: true,
  );

  Widget _buildMaxAmountField() => custom_form.FormField(
    label: 'Maximum Amount (Ar)',
    controller: _maxAmountController,
    icon: Icons.money,
    hintText: AppLocalizations.of(context).enterMaximumAmount,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: _validateMaxAmount,
    required: true,
  );

  Widget _buildFeeField() => custom_form.FormField(
    label: 'Fee (Ar)',
    controller: _feeController,
    icon: Icons.attach_money,
    hintText: AppLocalizations.of(context).enterFeeAmount,
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: (value) => ValidationUtil.positiveNumber(value, AppLocalizations.of(context).feeAmount),
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
            onPressed: context.pop,
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
    // First validate it's a positive number
    final basicValidation = ValidationUtil.positiveNumber(value, AppLocalizations.of(context).maximumAmount);
    if (basicValidation != null) return basicValidation;
    
    // Then check it's greater than min amount
    final amount = double.parse(value!);
    final minAmount = double.tryParse(_minAmountController.text) ?? 0;
    if (amount <= minAmount) return AppLocalizations.of(context).maxAmountMustBeGreater;
    return null;
  }



  void _create() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isCreating = true);
      
      // Simulate creation process
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        final now = DateTime.now();
        final feeInterval = FeeInterval(
          id: now.millisecondsSinceEpoch.toString(),
          minAmount: double.parse(_minAmountController.text.trim()),
          maxAmount: double.parse(_maxAmountController.text.trim()),
          fee: double.parse(_feeController.text.trim()),
          creationDateTime: now,
        );
        widget.onFeeIntervalAdded?.call(feeInterval);
        AppToast.success(context, AppLocalizations.of(context).feeIntervalCreatedSuccessfully);
        context.pop();
      }
    }
  }
}