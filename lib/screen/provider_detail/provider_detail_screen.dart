import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../model/provider_model.dart';
import '../../model/fee_interval_model.dart';
import '../../util/theme_util.dart';
import '../../util/navigation_util.dart';
import '../../styles/global.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/confirmation_modal.dart';
import '../../widget/search_empty_state.dart';
import '../../widget/loading_button.dart';
import '../../widget/collapsible_card.dart';
import 'widget/provider_header_card.dart';
import 'widget/fee_interval_tile.dart';
import '../../widget/selection_action_bar.dart';
import 'widget/fee_interval_edit_bottom_sheet.dart';
import '../../widget/app_toast.dart';
import '../../data/fee_interval_repository.dart';
import '../../provider/currency_provider.dart';
import '../../util/constant_util.dart';
import 'package:provider/provider.dart' show ReadContext;

/// Provider details screen with fee intervals management
class ProviderDetailScreen extends StatefulWidget {
  final Provider provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  final _repository = FeeIntervalRepository();
  List<FeeInterval> _feeIntervals = const [];
  List<FeeInterval> _filteredIntervals = const [];
  final Set<String> _selectedIds = {};
  final TextEditingController _feeMinController = TextEditingController();
  final TextEditingController _feeMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _feeMinController.addListener(_filterIntervals);
    _feeMaxController.addListener(_filterIntervals);
    _loadFeeIntervals();
  }

  @override
  void dispose() {
    _feeMinController.dispose();
    _feeMaxController.dispose();
    super.dispose();
  }

  Future<void> _loadFeeIntervals() async {
    try {
      final intervals = await _repository.getByProvider(widget.provider.id);
      if (!mounted) return;
      setState(() {
        _feeIntervals = intervals;
        _selectedIds.removeWhere((id) => !intervals.any((i) => i.id == id));
        _applyFilter();
      });
    } catch (_) {
      if (mounted) {
        AppToast.error(context, AppLocalizations.of(context).failedToLoadData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _selectedIds.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        // When selection mode is active, clear it instead of popping the route
        if (!didPop && _selectedIds.isNotEmpty) {
          setState(() => _selectedIds.clear());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: custom.AppBar(
          title: AppLocalizations.of(context).providerDetails,
          leading: _selectedIds.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _selectedIds.clear()),
                )
              : null, // Let Navigator handle the back button
        ),
        bottomNavigationBar: _buildAddButton(colorScheme),
        body: SafeArea(
          child: CustomScrollView(
            // Use BouncingScrollPhysics for better UX on all platforms
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Header section
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeader(),
                    Global.gapMd,
                    _buildSearchBar(colorScheme),
                    if (_selectedIds.isNotEmpty) ...[
                      Global.gapMd,
                      _buildSelectionBar(),
                    ],
                    Global.gapMd,
                    _buildIntervalsTitle(),
                    Global.gapSm,
                    // Fixed header for intervals
                    if (_filteredIntervals.isNotEmpty)
                      _buildIntervalsHeaderRow(),
                  ],
                ),
              ),
              // Intervals list - now properly integrated in the main scroll
              _buildIntervalSliver(),
              // Bottom padding for FAB
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SelectionActionBar(
      selectedCount: _selectedIds.length,
      totalCount: _filteredIntervals.length,
      onSelectAll: _selectAll,
      onClearSelection: _clearSelection,
      onDelete: _deleteSelectedIntervals,
      onEdit: _selectedIds.length == 1 ? () => _editSelectedInterval() : null,
      margin: EdgeInsets.zero,
    ),
  );

  Widget _buildHeader() => Container(
    margin: const EdgeInsets.all(16),
    child: ProviderHeaderCard(
      provider: widget.provider,
      onOptimize: _onOptimizeFees,
    ),
  );

  Widget _buildIntervalSliver() => _filteredIntervals.isEmpty
      ? SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: MediaQuery.of(context).textScaler.scale(1.0) > 1.3
                  ? 48
                  : 32,
            ),
            child: SearchEmptyState(
              icon: Icons.search_off,
              title: AppLocalizations.of(context).noFeeIntervalsFound,
              message: AppLocalizations.of(context).tryAdjustingYourSearchRange,
            ),
          ),
        )
      : SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: MediaQuery.of(context).textScaler.scale(1.0) > 1.3
                ? 8
                : 4,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final interval = _filteredIntervals[index];
              return Padding(
                // Add proper spacing between items for better touch targets
                padding: const EdgeInsets.only(bottom: 4),
                child: FeeIntervalTile(
                  feeInterval: interval,
                  isSelected: _selectedIds.contains(interval.id),
                  showSelection: _selectedIds.isNotEmpty,
                  onTap: () => _onIntervalTap(interval),
                  onSelectionChanged: (selected) =>
                      _onSelectionChanged(interval.id, selected),
                  onLongPress: () => _onIntervalLongPress(interval),
                ),
              );
            }, childCount: _filteredIntervals.length),
          ),
        );

  Widget _buildIntervalsTitle() => Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Text(
          AppLocalizations.of(context).feeIntervals,
          style: ThemeUtil.titleSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${_filteredIntervals.length})',
          style: ThemeUtil.labelMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );

  Widget _buildIntervalsHeaderRow() => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    padding: const EdgeInsets.all(16), // Same padding as tiles
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16), // Same radius as tiles
      border: Border.all(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
      ),
    ),
    child: Row(
      children: [
        // No checkbox in header, so no reserved space
        Expanded(
          child: _headerCell(
            AppLocalizations.of(context).feeInterval,
            alignment: TextAlign.left,
          ),
        ),
        // Approximate space for fee chip (padding + content)
        Container(
          constraints: const BoxConstraints(minWidth: 60),
          child: _headerCell(
            AppLocalizations.of(context).fee,
            alignment: TextAlign.center,
          ),
        ),
      ],
    ),
  );

  Widget _headerCell(String text, {TextAlign alignment = TextAlign.center}) =>
      Text(
        text,
        style: ThemeUtil.labelMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        textAlign: alignment,
      );

  Widget _buildSearchBar(ColorScheme colorScheme) => CollapsibleCard(
    title: AppLocalizations.of(context).searchByFeeRange,
    icon: Icons.search,
    iconColor: Theme.of(context).brightness == Brightness.dark
        ? ThemeUtil.textLight
        : ThemeUtil.textPrimary,
    titleStyle: ThemeUtil.titleMedium.copyWith(
      color: Theme.of(context).brightness == Brightness.dark
          ? ThemeUtil.textLight
          : ThemeUtil.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    isInitiallyExpanded: true,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildFeeMinField(colorScheme)),
                const SizedBox(width: 12),
                Expanded(child: _buildFeeMaxField(colorScheme)),
              ],
            ),
          ),
          if (_feeMinController.text.isNotEmpty ||
              _feeMaxController.text.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.clear,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    ],
  );

  Widget _buildAddButton(ColorScheme colorScheme) => Container(
    color: colorScheme.surface,
    padding: const EdgeInsets.all(16),
    child: SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: LoadingButton(
          text: AppLocalizations.of(context).addFeeInterval,
          onPressed: _addInterval,
          isLoading: false,
        ),
      ),
    ),
  );

  Future<void> _addInterval() async {
    final l10n = AppLocalizations.of(context);
    final interval = await NavigationUtil.pushTo<FeeInterval>(
      context,
      NavigationUtil.newFeeIntervalRoute,
      extra: widget.provider.id,
    );
    if (interval == null || !mounted) return;
    try {
      await _repository.insert(interval, widget.provider.id);
      if (mounted) {
        AppToast.success(context, l10n.feeIntervalCreatedSuccessfully);
      }
    } catch (_) {
      if (mounted) AppToast.error(context, l10n.failedToSaveChanges);
    }
    await _loadFeeIntervals();
  }

  void _onIntervalTap(FeeInterval interval) {
    if (_selectedIds.isNotEmpty) {
      _onSelectionChanged(interval.id, !_selectedIds.contains(interval.id));
    } else {
      _editInterval(interval);
    }
  }

  void _onIntervalLongPress(FeeInterval interval) {
    if (_selectedIds.isEmpty) {
      _startSelection(interval.id);
    }
  }

  void _onSelectionChanged(String? id, bool selected) {
    if (id == null) return;
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _startSelection(String? id) {
    if (id == null) return;
    setState(() {
      _selectedIds.add(id);
    });
  }

  void _clearSelection() => setState(() => _selectedIds.clear());

  void _selectAll() {
    setState(() {
      _selectedIds.addAll(
        _filteredIntervals.map((e) => e.id).whereType<String>(),
      );
    });
  }

  Widget _buildFeeMinField(ColorScheme colorScheme) => TextField(
    controller: _feeMinController,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      hintText: AppLocalizations.of(context).minFee,
      hintStyle: ThemeUtil.bodySmall.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    style: ThemeUtil.bodySmall.copyWith(color: colorScheme.onSurface),
  );

  Widget _buildFeeMaxField(ColorScheme colorScheme) => TextField(
    controller: _feeMaxController,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      hintText: AppLocalizations.of(context).maxFee,
      hintStyle: ThemeUtil.bodySmall.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    style: ThemeUtil.bodySmall.copyWith(color: colorScheme.onSurface),
  );

  void _filterIntervals() => setState(_applyFilter);

  /// Filters by fee: fixed fees are compared in the display currency,
  /// percentage fees by their percentage.
  void _applyFilter() {
    final min = ConstantUtil.parseLocalizedNumber(_feeMinController.text);
    final max = ConstantUtil.parseLocalizedNumber(_feeMaxController.text);
    if (min == null && max == null) {
      _filteredIntervals = _feeIntervals;
      return;
    }
    final currency = context.read<CurrencyProvider>();
    _filteredIntervals = _feeIntervals.where((interval) {
      final fee = interval.isPercentage
          ? (interval.fee ?? 0)
          : currency.convertFromAriary(interval.fee ?? 0);
      return fee >= (min ?? double.negativeInfinity) &&
          fee <= (max ?? double.infinity);
    }).toList();
  }

  void _clearSearch() {
    _feeMinController.clear();
    _feeMaxController.clear();
  }

  void _editInterval(FeeInterval interval) {
    final l10n = AppLocalizations.of(context);
    FeeIntervalEditBottomSheet.show(context, interval, widget.provider.id, (
      updated,
    ) async {
      try {
        await _repository.update(updated, widget.provider.id);
        await _loadFeeIntervals();
        if (mounted) {
          AppToast.success(context, l10n.feeIntervalUpdatedSuccessfully);
        }
        return true;
      } catch (_) {
        if (mounted) AppToast.error(context, l10n.failedToUpdateFeeInterval);
        return false;
      }
    });
  }

  void _editSelectedInterval() {
    if (_selectedIds.length == 1) {
      final interval = _feeIntervals
          .where((i) => i.id == _selectedIds.first)
          .firstOrNull;
      if (interval != null) _editInterval(interval);
    }
  }

  void _onOptimizeFees() {
    // Opens the optimizer with this provider preselected.
    NavigationUtil.goTo(
      context,
      NavigationUtil.homeRoute,
      extra: widget.provider,
    );
  }

  Future<void> _deleteSelectedIntervals() async {
    final l10n = AppLocalizations.of(context);
    final ids = Set.of(_selectedIds);
    final confirmed = await ConfirmationModal.show(
      context,
      l10n.deleteFeeIntervals,
      l10n.confirmDeleteIntervals(ids.length),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _repository.delete(ids);
      if (!mounted) return;
      setState(_selectedIds.clear);
      AppToast.success(
        context,
        l10n.feeIntervalDeletedSuccessfully(ids.length),
      );
    } catch (_) {
      if (mounted) AppToast.error(context, l10n.failedToDeleteFeeIntervals);
    }
    await _loadFeeIntervals();
  }
}
