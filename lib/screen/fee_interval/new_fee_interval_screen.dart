import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/fee_interval_model.dart';
import '../../styles/global.dart';
import '../../util/theme_util.dart';
import '../../util/extensions_util.dart';
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
      title: 'New Fee Interval',
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
        'Create New Fee Interval',
        style: ThemeUtil.titleLarge.copyWith(
          color: context.colorScheme.onSurface,
        ),
      ),
      Global.gapSm,
      Text(
        'Define a new fee structure for transaction amounts',
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
    hintText: 'Enter minimum amount',
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: _validateMinAmount,
    required: true,
  );

  Widget _buildMaxAmountField() => custom_form.FormField(
    label: 'Maximum Amount (Ar)',
    controller: _maxAmountController,
    icon: Icons.money,
    hintText: 'Enter maximum amount',
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: _validateMaxAmount,
    required: true,
  );

  Widget _buildFeeField() => custom_form.FormField(
    label: 'Fee (Ar)',
    controller: _feeController,
    icon: Icons.attach_money,
    hintText: 'Enter fee amount',
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    validator: _validateFee,
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
          child: OutlinedButton(
            onPressed: context.pop,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(
                context.colorScheme.onSurfaceVariant,
              ),
              overlayColor: ThemeUtil.interactiveOverlay(
                context.colorScheme.onSurfaceVariant,
              ),
              side: WidgetStateProperty.all(
                BorderSide(color: context.colorScheme.outlineVariant),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: Global.borderMd),
              ),
              padding: WidgetStateProperty.all(Global.padVerticalMd),
              splashFactory: NoSplash.splashFactory,
            ),
            child: Text(
              'Cancel',
              style: ThemeUtil.bodyMedium.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Global.gapMd,
        Expanded(
          flex: 2,
          child: LoadingButton(
            text: 'Create Interval',
            onPressed: _create,
            isLoading: _isCreating,
          ),
        ),
      ],
    ),
  );

  String? _validateMinAmount(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter minimum amount';
    final amount = double.tryParse(value!);
    if (amount == null || amount < 0) return 'Please enter a valid amount';
    return null;
  }

  String? _validateMaxAmount(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter maximum amount';
    final amount = double.tryParse(value!);
    if (amount == null || amount < 0) return 'Please enter a valid amount';
    
    final minAmount = double.tryParse(_minAmountController.text) ?? 0;
    if (amount <= minAmount) return 'Max amount must be greater than min amount';
    return null;
  }

  String? _validateFee(String? value) {
    if (value?.isEmpty ?? true) return 'Please enter fee amount';
    final fee = double.tryParse(value!);
    if (fee == null || fee < 0) return 'Please enter a valid fee';
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
        AppToast.success(context, 'Fee interval created successfully');
        context.pop();
      }
    }
  }
}