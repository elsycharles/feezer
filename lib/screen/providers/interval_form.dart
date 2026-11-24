import 'package:flutter/material.dart';

import '../../data/fee_interval_repository.dart';
import '../../data/provider_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../model/fee_interval_model.dart';
import '../../model/provider_model.dart';
import '../../theme/app_theme.dart';
import '../../util/constant_util.dart';
import '../../util/money.dart';
import '../../widget/amount_input_formatter.dart';
import '../../widget/app_toast.dart';
import '../../widget/common.dart';

/// Creates or edits (and deletes) a tier of the [provider]'s grid.
Future<void> showIntervalForm(
  BuildContext context, {
  required Provider provider,
  FeeInterval? interval,
}) {
  final l10n = AppLocalizations.of(context);
  return showAppSheet<void>(
    context,
    title: interval == null ? l10n.newFeeInterval : l10n.editFeeInterval,
    builder: (_) => _IntervalForm(provider: provider, interval: interval),
  );
}

class _IntervalForm extends StatefulWidget {
  const _IntervalForm({required this.provider, this.interval});

  final Provider provider;
  final FeeInterval? interval;

  @override
  State<_IntervalForm> createState() => _IntervalFormState();
}

class _IntervalFormState extends State<_IntervalForm> {
  final _formKey = GlobalKey<FormState>();
  final _repository = FeeIntervalRepository();
  late FeeType _type = widget.interval?.feeType ?? FeeType.fixed;
  final _min = TextEditingController();
  final _max = TextEditingController();
  final _fee = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  String? _overlap;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final decimal = Money.decimalSeparatorOf(Localizations.localeOf(context));
    String text(double? value) => value == null
        ? ''
        : ConstantUtil.formatAmountInput(value).replaceFirst('.', decimal);
    _min.text = text(widget.interval?.minAmount);
    _max.text = text(widget.interval?.maxAmount);
    _fee.text = text(widget.interval?.fee);
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    _fee.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) =>
      ConstantUtil.parseLocalizedNumber(c.text);

  String get _providerId => widget.provider.id;

  /// A downloaded grid changed by hand is no longer the published one.
  Future<void> _markEdited() async {
    final provider = widget.provider;
    if (provider.isPublished && provider.sourceType != Provider.editedSource) {
      await ProviderRepository().markEdited(provider.id);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _overlap = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final interval = FeeInterval(
      id: widget.interval?.id,
      minAmount: _parse(_min),
      maxAmount: _parse(_max),
      fee: _parse(_fee),
      feeType: _type,
      creationDateTime: widget.interval?.creationDatetime,
    );
    try {
      final overlap = await _repository.findOverlap(_providerId, interval);
      if (overlap != null) {
        setState(() {
          _saving = false;
          _overlap = l10n.feeIntervalOverlaps(
            '${context.money(overlap.minAmount!)} – ${context.money(overlap.maxAmount!)}',
          );
        });
        return;
      }
      if (widget.interval == null) {
        await _repository.insert(interval, _providerId);
      } else {
        await _repository.update(interval, _providerId);
      }
      await _markEdited();
      if (!mounted) return;
      AppToast.success(
        context,
        widget.interval == null
            ? l10n.feeIntervalCreatedSuccessfully
            : l10n.feeIntervalUpdatedSuccessfully,
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, l10n.failedToSaveChanges);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final ok = await confirm(
      context,
      title: l10n.deleteFeeIntervals,
      message: l10n.confirmDeleteIntervals(1),
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
    );
    if (!ok || !mounted) return;
    try {
      await _repository.delete([widget.interval!.id!]);
      await _markEdited();
      if (!mounted) return;
      AppToast.success(context, l10n.feeIntervalDeletedSuccessfully(1));
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) AppToast.error(context, l10n.failedToDeleteFeeIntervals);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final decimal = Money.decimalSeparatorOf(Localizations.localeOf(context));
    final percentage = _type == FeeType.percentage;

    String? amountValidator(String? value, {bool isMax = false}) {
      final amount = ConstantUtil.parseLocalizedNumber(value ?? '');
      if ((value ?? '').trim().isEmpty) return l10n.thisFieldIsRequired;
      if (amount == null || amount < 0) return l10n.pleaseEnterValidAmount;
      if (isMax) {
        final min = _parse(_min);
        if (min != null && amount <= min) {
          return l10n.maxAmountMustBeGreaterThanMinAmount;
        }
      }
      return null;
    }

    InputDecoration decoration(String label, {String? suffix}) =>
        InputDecoration(labelText: label, suffixText: suffix);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.provider.operation?.isWithdrawal == true
                ? l10n.intervalFormHelpWithdrawal
                : l10n.intervalFormHelp,
            style: context.text.bodySmall,
          ),
          if (widget.provider.isPublished &&
              widget.provider.sourceType != Provider.editedSource) ...[
            Space.gapMd,
            Container(
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: context.palette.warningContainer,
                borderRadius: BorderRadius.circular(Space.radiusSm),
              ),
              child: Text(
                l10n.editPublishedGridWarning,
                style: context.text.bodySmall?.copyWith(
                  color: context.palette.onWarningContainer,
                ),
              ),
            ),
          ],
          Space.gapLg,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _min,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    AmountInputFormatter(
                      max: ConstantUtil.maxInputAmount,
                      decimalSeparator: decimal,
                    ),
                  ],
                  decoration: decoration(l10n.minimumAmount),
                  validator: amountValidator,
                ),
              ),
              Space.gapMd,
              Expanded(
                child: TextFormField(
                  controller: _max,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    AmountInputFormatter(
                      max: ConstantUtil.maxInputAmount,
                      decimalSeparator: decimal,
                    ),
                  ],
                  decoration: decoration(l10n.maximumAmount),
                  validator: (v) => amountValidator(v, isMax: true),
                ),
              ),
            ],
          ),
          Space.gapLg,
          SegmentedButton<FeeType>(
            segments: [
              ButtonSegment(
                value: FeeType.fixed,
                label: Text(l10n.fixedAmount),
                icon: const Icon(Icons.payments_outlined),
              ),
              ButtonSegment(
                value: FeeType.percentage,
                label: Text(l10n.percentage),
                icon: const Icon(Icons.percent_rounded),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (value) => setState(() => _type = value.first),
          ),
          Space.gapLg,
          TextFormField(
            key: ValueKey(_type),
            controller: _fee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              AmountInputFormatter(
                max: percentage ? 100 : ConstantUtil.maxInputAmount,
                maxDecimals: percentage ? 4 : 2,
                decimalSeparator: decimal,
              ),
            ],
            decoration: decoration(l10n.fee, suffix: percentage ? '%' : null),
            validator: (value) {
              if ((value ?? '').trim().isEmpty) return l10n.thisFieldIsRequired;
              final fee = ConstantUtil.parseLocalizedNumber(value!);
              if (percentage && (fee == null || fee < 0 || fee > 100)) {
                return l10n.percentageMustBeBetween0And100;
              }
              if (fee == null || fee < 0) return l10n.pleaseEnterValidFee;
              return null;
            },
          ),
          if (_overlap != null) ...[
            Space.gapMd,
            Container(
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: context.colors.errorContainer,
                borderRadius: BorderRadius.circular(Space.radiusSm),
              ),
              child: Text(
                _overlap!,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onErrorContainer,
                ),
              ),
            ),
          ],
          Space.gapXl,
          AppButton(
            label: widget.interval == null
                ? l10n.createInterval
                : l10n.saveChanges,
            loading: _saving,
            onPressed: _save,
          ),
          if (widget.interval != null) ...[
            Space.gapSm,
            AppButton(
              label: l10n.delete,
              icon: Icons.delete_outline_rounded,
              style: AppButtonStyle.text,
              destructive: true,
              onPressed: _saving ? null : _delete,
            ),
          ],
        ],
      ),
    );
  }
}
