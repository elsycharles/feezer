import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/fee_interval_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../model/fee_interval_model.dart';
import '../../../provider/currency_provider.dart';
import '../../../styles/global.dart';
import '../../../util/constant_util.dart';
import '../../../util/theme_util.dart';
import '../../../widget/amount_input_formatter.dart';
import '../../../widget/form_field.dart' as custom_form;

/// Form shared by the creation screen and the edition bottom sheet.
///
/// Amounts are typed in the display currency and converted to Ariary; the
/// interval is checked against the other intervals of [providerId].
class FeeIntervalForm extends StatefulWidget {
  /// Use a `GlobalKey<FeeIntervalFormState>` as [key] to call
  /// [FeeIntervalFormState.submit].
  const FeeIntervalForm({super.key, this.initial, this.providerId});

  final FeeInterval? initial;
  final String? providerId;

  @override
  State<FeeIntervalForm> createState() => FeeIntervalFormState();
}

class FeeIntervalFormState extends State<FeeIntervalForm> {
  final _formKey = GlobalKey<FormState>();
  late final CurrencyProvider _currency = context.read<CurrencyProvider>();
  late FeeType _feeType = widget.initial?.feeType ?? FeeType.fixed;
  late final _minController = TextEditingController(
    text: _amountText(widget.initial?.minAmount),
  );
  late final _maxController = TextEditingController(
    text: _amountText(widget.initial?.maxAmount),
  );
  late final _feeController = TextEditingController(
    text: widget.initial?.fee == null
        ? ''
        : widget.initial!.isPercentage
        ? ConstantUtil.formatPercentage(widget.initial!.fee!)
        : _amountText(widget.initial!.fee),
  );
  String? _overlapError;

  String _amountText(double? valueInBase) => valueInBase == null
      ? ''
      : ConstantUtil.formatAmountInput(
          _currency.convertFromAriary(valueInBase),
        );

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) =>
      ConstantUtil.parseLocalizedNumber(c.text);

  /// Validates the fields and the overlap with existing intervals; returns
  /// the interval (in Ariary) or `null` when invalid.
  Future<FeeInterval?> submit() async {
    setState(() => _overlapError = null);
    if (!_formKey.currentState!.validate()) return null;
    final fee = _parse(_feeController)!;
    final interval = FeeInterval(
      id: widget.initial?.id,
      minAmount: _currency.convertToAriary(_parse(_minController)!),
      maxAmount: _currency.convertToAriary(_parse(_maxController)!),
      fee: _feeType == FeeType.percentage
          ? fee
          : _currency.convertToAriary(fee),
      feeType: _feeType,
      creationDateTime: widget.initial?.creationDatetime,
    );
    final providerId = widget.providerId;
    if (providerId != null) {
      final overlap = await FeeIntervalRepository().findOverlap(
        providerId,
        interval,
      );
      if (overlap != null) {
        if (mounted) {
          setState(() {
            _overlapError = AppLocalizations.of(context).feeIntervalOverlaps(
              overlap.formattedRangeWithSymbol(
                _currency.currencySymbol,
                _currency.exchangeRate,
              ),
            );
          });
        }
        return null;
      }
    }
    return interval;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final symbol = _currency.currencySymbol;
    final percentage = _feeType == FeeType.percentage;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          custom_form.FormField(
            label: '${l10n.minimumAmount} ($symbol)',
            controller: _minController,
            icon: Icons.money,
            hintText: l10n.enterMinimumAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              AmountInputFormatter(max: ConstantUtil.maxInputAmount),
            ],
            required: true,
            validator: (value) {
              final amount = ConstantUtil.parseLocalizedNumber(value ?? '');
              if ((value ?? '').trim().isEmpty) {
                return l10n.pleaseEnterMinAmount;
              }
              if (amount == null || amount < 0) {
                return l10n.pleaseEnterValidAmount;
              }
              return null;
            },
          ),
          Global.gapLg,
          custom_form.FormField(
            label: '${l10n.maximumAmount} ($symbol)',
            controller: _maxController,
            icon: Icons.money,
            hintText: l10n.enterMaximumAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              AmountInputFormatter(max: ConstantUtil.maxInputAmount),
            ],
            required: true,
            validator: (value) {
              final amount = ConstantUtil.parseLocalizedNumber(value ?? '');
              if ((value ?? '').trim().isEmpty) {
                return l10n.pleaseEnterMaxAmount;
              }
              if (amount == null || amount < 0) {
                return l10n.pleaseEnterValidAmount;
              }
              final min = _parse(_minController);
              if (min != null && amount <= min) {
                return l10n.maxAmountMustBeGreaterThanMinAmount;
              }
              return null;
            },
          ),
          Global.gapLg,
          _FeeTypeSelector(
            value: _feeType,
            onChanged: (type) => setState(() => _feeType = type),
          ),
          Global.gapLg,
          custom_form.FormField(
            key: ValueKey(_feeType),
            label: percentage ? '${l10n.fee} (%)' : '${l10n.fee} ($symbol)',
            controller: _feeController,
            icon: Icons.attach_money,
            hintText: percentage ? l10n.enterPercentage : l10n.enterFeeAmount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              percentage
                  ? AmountInputFormatter(max: 100, maxDecimals: 4)
                  : AmountInputFormatter(max: ConstantUtil.maxInputAmount),
            ],
            required: true,
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return percentage
                    ? l10n.pleaseEnterPercentage
                    : l10n.pleaseEnterFeeAmount;
              }
              final fee = ConstantUtil.parseLocalizedNumber(value!);
              if (percentage) {
                if (fee == null || fee < 0 || fee > 100) {
                  return l10n.percentageMustBeBetween0And100;
                }
              } else if (fee == null || fee < 0) {
                return l10n.pleaseEnterValidFee;
              }
              return null;
            },
          ),
          if (_overlapError != null) ...[
            Global.gapMd,
            Text(
              _overlapError!,
              style: ThemeUtil.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeeTypeSelector extends StatelessWidget {
  const _FeeTypeSelector({required this.value, required this.onChanged});

  final FeeType value;
  final ValueChanged<FeeType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    Widget option(FeeType type, String label) {
      final selected = type == value;
      return Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.primaryContainer
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected
                    ? colorScheme.primary
                    : colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: ThemeUtil.bodyMedium.copyWith(
                color: selected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.feeType,
            style: ThemeUtil.labelLarge.copyWith(color: colorScheme.onSurface),
          ),
          Global.gapMd,
          Row(
            children: [
              option(FeeType.fixed, l10n.fixedAmount),
              Global.gapMd,
              option(FeeType.percentage, l10n.percentage),
            ],
          ),
        ],
      ),
    );
  }
}
