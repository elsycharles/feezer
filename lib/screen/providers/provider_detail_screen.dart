import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../../data/fee_interval_repository.dart';
import '../../data/provider_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../model/fee_interval_model.dart';
import '../../model/provider_model.dart';
import '../../theme/app_theme.dart';
import '../../util/grid_labels.dart';
import '../../util/link_util.dart';
import '../../util/money.dart';
import '../../util/navigation_util.dart';
import '../../widget/app_toast.dart';
import '../../widget/common.dart';
import 'interval_form.dart';
import 'provider_form.dart';

enum _Action { edit, delete }

/// One fee grid: operator, operation, source and tiers.
class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({super.key, required this.provider});

  final Provider provider;

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final _providerRepository = ProviderRepository();
  final _intervalRepository = FeeIntervalRepository();
  late Provider _provider = widget.provider;
  List<FeeInterval>? _intervals;

  @override
  void initState() {
    super.initState();
    AppDatabase.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    AppDatabase.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final providers = await _providerRepository.getAll();
      final provider = providers.where((p) => p.id == _provider.id).firstOrNull;
      if (provider == null) {
        // Deleted (from another screen or by a CSV import).
        if (mounted) Navigator.of(context).maybePop();
        return;
      }
      final intervals = await _intervalRepository.getByProvider(provider.id);
      if (!mounted) return;
      setState(() {
        _provider = provider;
        _intervals = intervals;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _intervals = const []);
      AppToast.error(context, AppLocalizations.of(context).failedToLoadData);
    }
  }

  Future<void> _onAction(_Action action) async {
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case _Action.edit:
        await showProviderForm(context, provider: _provider);
      case _Action.delete:
        final ok = await confirm(
          context,
          title: l10n.deleteGridTitle,
          message: l10n.deleteGridMessage(
            GridLabels.title(l10n, _provider.name, _provider.operation),
          ),
          confirmLabel: l10n.delete,
          cancelLabel: l10n.cancel,
        );
        if (!ok || !mounted) return;
        try {
          await _providerRepository.delete([_provider.id]);
          if (!mounted) return;
          AppToast.success(context, l10n.gridDeleted);
        } catch (_) {
          if (mounted) AppToast.error(context, l10n.failedToSaveChanges);
        }
    }
  }

  void _editInterval([FeeInterval? interval]) =>
      showIntervalForm(context, provider: _provider, interval: interval);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final intervals = _intervals;
    final source = GridLabels.source(context, _provider);
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<_Action>(
            tooltip: l10n.moreOptions,
            onSelected: _onAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _Action.edit,
                child: ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.editGrid),
                ),
              ),
              PopupMenuItem(
                value: _Action.delete,
                child: ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: context.colors.error,
                  ),
                  title: Text(
                    l10n.deleteGridTitle,
                    style: TextStyle(color: context.colors.error),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-interval',
        onPressed: _editInterval,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addFeeInterval),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, 112),
        children: [
          Row(
            children: [
              ProviderAvatar(
                name: _provider.name,
                iconName: _provider.iconName,
                size: 56,
              ),
              Space.gapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_provider.name, style: context.text.headlineSmall),
                    Text(
                      GridLabels.operation(l10n, _provider.operation),
                      style: context.text.bodyMedium?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Published grids carry a generic description: their source says more.
          if (!_provider.isPublished && _provider.description.isNotEmpty) ...[
            Space.gapLg,
            Text(
              _provider.description,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
          if (source != null) ...[
            Space.gapLg,
            _SourceCard(provider: _provider, label: source),
          ],
          Space.gapLg,
          AppButton(
            label: l10n.optimizeWithGrid,
            icon: Icons.calculate_outlined,
            style: AppButtonStyle.tonal,
            onPressed: () => NavigationUtil.optimizeWith(context, _provider),
          ),
          Space.gapXl,
          SectionLabel(
            l10n.feeGrid,
            trailing: intervals == null
                ? null
                : Text(
                    l10n.tierCount(intervals.length),
                    style: context.text.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
          ),
          AnimatedSwitcher(
            duration: Motion.medium,
            child: intervals == null
                ? const SectionCard(
                    key: ValueKey('loading'),
                    child: Column(
                      children: [
                        Skeleton(),
                        Space.gapLg,
                        Skeleton(),
                        Space.gapLg,
                        Skeleton(),
                      ],
                    ),
                  )
                : intervals.isEmpty
                ? SectionCard(
                    key: const ValueKey('empty'),
                    child: EmptyState(
                      icon: Icons.table_rows_outlined,
                      title: l10n.noTiersYet,
                    ),
                  )
                : _GridCard(
                    key: const ValueKey('grid'),
                    intervals: intervals,
                    operationIsWithdrawal: _provider.operation?.isWithdrawal,
                    onTap: _editInterval,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Where the grid comes from, with a link to the official page.
class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.provider, required this.label});

  final Provider provider;
  final String label;

  @override
  Widget build(BuildContext context) {
    final url = Uri.tryParse(provider.sourceUrl ?? '');
    final edited = provider.sourceType == Provider.editedSource;
    final hasLink = url != null && url.hasScheme;
    return SectionCard(
      onTap: hasLink ? () => LinkUtil.open(context, url) : null,
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.md,
        Space.md,
        Space.md,
      ),
      child: Row(
        children: [
          Icon(
            edited ? Icons.edit_note_rounded : Icons.public_rounded,
            size: 22,
            color: context.colors.onSurfaceVariant,
          ),
          Space.gapMd,
          Expanded(child: Text(label, style: context.text.titleSmall)),
          if (hasLink)
            Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: context.colors.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({
    super.key,
    required this.intervals,
    required this.operationIsWithdrawal,
    required this.onTap,
  });

  final List<FeeInterval> intervals;
  final bool? operationIsWithdrawal;
  final ValueChanged<FeeInterval> onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final header = context.text.labelMedium?.copyWith(
      color: colors.onSurfaceVariant,
    );
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Space.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: colors.surfaceContainer,
            padding: const EdgeInsets.fromLTRB(
              Space.lg,
              Space.md,
              Space.lg + 28,
              Space.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    operationIsWithdrawal == true
                        ? l10n.amountWithdrawn
                        : l10n.amountRange,
                    style: header,
                  ),
                ),
                Text(l10n.fee, style: header),
              ],
            ),
          ),
          for (var i = 0; i < intervals.length; i++) ...[
            if (i > 0) const Divider(indent: Space.lg, endIndent: Space.lg),
            Pressable(
              onTap: () => onTap(intervals[i]),
              borderRadius: 0,
              scale: 0.99,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.lg,
                  Space.md,
                  Space.sm,
                  Space.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${context.money(intervals[i].minAmount ?? 0)} – '
                        '${context.money(intervals[i].maxAmount ?? 0)}',
                        style: context.text.bodyMedium?.copyWith(
                          fontFeatures: AppTheme.tabular,
                        ),
                      ),
                    ),
                    _FeeChip(interval: intervals[i]),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.outline,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeeChip extends StatelessWidget {
  const _FeeChip({required this.interval});

  final FeeInterval interval;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fee = interval.fee ?? 0;
    final percentage = interval.isPercentage;
    final free = !percentage && fee == 0;
    final (background, foreground) = percentage
        ? (context.palette.warningContainer, context.palette.onWarningContainer)
        : free
        ? (context.palette.successContainer, context.palette.onSuccessContainer)
        : (colors.primaryContainer, colors.onPrimaryContainer);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        percentage
            ? context.percent(fee)
            : free
            ? AppLocalizations.of(context).free
            : context.money(fee),
        style: context.text.labelMedium?.copyWith(
          color: foreground,
          fontFeatures: AppTheme.tabular,
        ),
      ),
    );
  }
}
