import 'package:flutter/material.dart';

import '../../data/fee_table_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../util/date_label.dart';
import '../../util/grid_labels.dart';
import '../../widget/app_toast.dart';
import '../../widget/common.dart';

/// Downloads the official fee grids, shows what changes and applies them
/// after confirmation, all in one sheet. Completes when the sheet closes.
Future<void> runFeeUpdate(BuildContext context, {FeeTableService? service}) {
  final l10n = AppLocalizations.of(context);
  return showAppSheet<void>(
    context,
    title: l10n.updateFeesTitle,
    builder: (_) => _FeeUpdateSheet(service: service ?? FeeTableService()),
  );
}

enum _Step { loading, failed, upToDate, review, applying }

class _FeeUpdateSheet extends StatefulWidget {
  const _FeeUpdateSheet({required this.service});

  final FeeTableService service;

  @override
  State<_FeeUpdateSheet> createState() => _FeeUpdateSheetState();
}

class _FeeUpdateSheetState extends State<_FeeUpdateSheet> {
  _Step _step = _Step.loading;
  FeeUpdatePlan? _plan;

  @override
  void initState() {
    super.initState();
    _download();
  }

  Future<void> _download() async {
    setState(() => _step = _Step.loading);
    try {
      final plan = await widget.service.plan(await widget.service.fetch());
      if (!plan.hasChanges) await FeeTableService.rememberCheck(plan.tables);
      if (!mounted) return;
      setState(() {
        _plan = plan;
        _step = plan.hasChanges ? _Step.review : _Step.upToDate;
      });
    } catch (e) {
      debugPrint('Fee download failed: $e');
      if (mounted) setState(() => _step = _Step.failed);
    }
  }

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _step = _Step.applying);
    try {
      await widget.service.apply(_plan!.tables);
      if (!mounted) return;
      AppToast.success(context, l10n.feesUpdatedSuccessfully);
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Fee update failed: $e');
      if (!mounted) return;
      setState(() => _step = _Step.review);
      AppToast.error(context, l10n.failedToSaveChanges);
    }
  }

  String? _date(DateTime? date) => date == null ? null : context.date(date);

  @override
  Widget build(BuildContext context) {
    final step = _step == _Step.applying ? _Step.review : _step;
    return AnimatedSize(
      duration: Motion.medium,
      curve: Motion.curve,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: Motion.medium,
        switchInCurve: Motion.curve,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        child: KeyedSubtree(
          key: ValueKey(step),
          child: switch (step) {
            _Step.loading => _loading(),
            _Step.failed => _failed(),
            _Step.upToDate => _upToDate(),
            _Step.review || _Step.applying => _review(),
          },
        ),
      ),
    );
  }

  Widget _loading() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.downloadingFees,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Space.gapLg,
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: const LinearProgressIndicator(minHeight: 6),
        ),
        Space.gapXl,
      ],
    );
  }

  Widget _failed() {
    final l10n = AppLocalizations.of(context);
    return _Message(
      icon: Icons.wifi_off_rounded,
      color: context.colors.error,
      title: l10n.feesDownloadFailedTitle,
      message: l10n.feesDownloadFailed,
      action: AppButton(label: l10n.retry, onPressed: _download),
    );
  }

  Widget _upToDate() {
    final l10n = AppLocalizations.of(context);
    final checked = _date(_plan?.tables.checkedAt);
    return _Message(
      icon: Icons.check_circle_outline_rounded,
      color: context.palette.success,
      title: l10n.feesAlreadyUpToDate,
      message: checked == null ? null : l10n.feesCheckedOn(checked),
      action: AppButton(
        label: l10n.ok,
        style: AppButtonStyle.tonal,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _review() {
    final l10n = AppLocalizations.of(context);
    final plan = _plan!;
    final applying = _step == _Step.applying;
    final changes = [
      for (final grid in plan.updated) (grid, false),
      for (final grid in plan.created) (grid, true),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.updateReviewIntro,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
        Space.gapLg,
        Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(Space.radiusLg),
          ),
          child: Column(
            children: [
              for (var i = 0; i < changes.length; i++) ...[
                if (i > 0) const Divider(indent: 56),
                _ChangeRow(grid: changes[i].$1, added: changes[i].$2),
              ],
            ],
          ),
        ),
        Space.gapMd,
        Text(l10n.gridsOthersUnchanged, style: context.text.bodySmall),
        Space.gapXl,
        AppButton(
          label: l10n.updateAction,
          loading: applying,
          onPressed: _apply,
        ),
        Space.gapSm,
        AppButton(
          label: l10n.later,
          style: AppButtonStyle.text,
          onPressed: applying ? null : () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({required this.grid, required this.added});

  final RemoteGrid grid;
  final bool added;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final date = grid.effectiveDate == null
        ? null
        : context.date(grid.effectiveDate!);
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.md,
      ),
      child: Row(
        children: [
          ProviderAvatar(name: grid.name, iconName: grid.iconName, size: 28),
          Space.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  GridLabels.title(l10n, grid.name, grid.operation),
                  style: context.text.titleSmall,
                ),
                Text(
                  [
                    l10n.tierCount(grid.intervals.length),
                    if (date != null) l10n.effectiveSince(date),
                  ].join('  ·  '),
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
          Space.gapSm,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: added
                  ? context.palette.successContainer
                  : colors.primaryContainer,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              added ? l10n.newTag : l10n.updatedTag,
              style: context.text.labelSmall?.copyWith(
                color: added
                    ? context.palette.onSuccessContainer
                    : colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon, title, message and action, centered.
class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.color,
    required this.title,
    required this.action,
    this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? message;
  final Widget action;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Icon(icon, size: 40, color: color),
      Space.gapMd,
      Text(title, textAlign: TextAlign.center, style: context.text.titleMedium),
      if (message != null) ...[
        Space.gapXs,
        Text(
          message!,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
      Space.gapXl,
      action,
    ],
  );
}
