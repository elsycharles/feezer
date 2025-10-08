import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../model/provider_model.dart';
import '../../model/fee_interval_model.dart';
import '../../util/theme_util.dart';
import '../../styles/global.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/confirmation_modal.dart';
import '../../widget/search_empty_state.dart';
import '../../widget/app_loading.dart';
import '../../widget/loading_button.dart';
import '../../widget/collapsible_card.dart';
import 'widget/provider_header_card.dart';
import 'widget/fee_interval_tile.dart';
import '../../widget/selection_action_bar.dart';
import '../fee_interval/new_fee_interval_screen.dart';
import 'widget/fee_interval_edit_bottom_sheet.dart';
import '../../widget/app_toast.dart';
import '../optimize_fee/optimize_fee_screen.dart';

/// Provider details screen with fee intervals management
class ProviderDetailScreen extends StatefulWidget {
  final Provider provider;

  const ProviderDetailScreen({super.key, required this.provider});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  late List<FeeInterval> _feeIntervals;
  late List<FeeInterval> _filteredIntervals;
  final Set<String> _selectedIds = {};
  final TextEditingController _feeMinController = TextEditingController();
  final TextEditingController _feeMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _feeIntervals = _generateMockIntervals();
    _filteredIntervals = _feeIntervals;
    _feeMinController.addListener(_filterIntervals);
    _feeMaxController.addListener(_filterIntervals);
  }

  @override
  void dispose() {
    _feeMinController.dispose();
    _feeMaxController.dispose();
    super.dispose();
  }

  List<FeeInterval> _generateMockIntervals() => [
    FeeInterval(
      id: 'interval_0',
      minAmount: 0,
      maxAmount: 1000,
      fee: 50,
      creationDateTime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FeeInterval(
      id: 'interval_1',
      minAmount: 1001,
      maxAmount: 5000,
      fee: 150,
      creationDateTime: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FeeInterval(
      id: 'interval_2',
      minAmount: 5001,
      maxAmount: 10000,
      fee: 300,
      creationDateTime: DateTime.now().subtract(const Duration(days: 7)),
    ),
    FeeInterval(
      id: 'interval_3',
      minAmount: 10001,
      maxAmount: 25000,
      fee: 500,
      creationDateTime: DateTime.now().subtract(const Duration(days: 14)),
    ),
    FeeInterval(
      id: 'interval_4',
      minAmount: 25001,
      maxAmount: 50000,
      fee: 800,
      creationDateTime: DateTime.now().subtract(const Duration(days: 21)),
    ),
  ];

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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () {
              if (_selectedIds.isNotEmpty) {
                // Clear selection instead of popping when in selection mode
                setState(() => _selectedIds.clear());
              } else {
                context.pop();
              }
            },
          ),
        ),
        bottomNavigationBar: _buildAddButton(colorScheme),
        body: SafeArea(
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
              // Fixed header outside of scroll view
              if (_filteredIntervals.isNotEmpty)
                _buildIntervalsHeaderRow(),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    _buildIntervalSliver(),
                    SliverToBoxAdapter(child: Global.gapMd),
                    SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: SearchEmptyState(
              icon: Icons.search_off,
              title: AppLocalizations.of(context).noFeeIntervalsFound,
              message: AppLocalizations.of(context).tryAdjustingYourSearchRange,
            ),
          ),
        )
      : SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final interval = _filteredIntervals[index];
              return FeeIntervalTile(
                feeInterval: interval,
                isSelected: _selectedIds.contains(interval.id),
                showSelection: _selectedIds.isNotEmpty,
                onTap: () => _onIntervalTap(interval),
                onSelectionChanged: (selected) =>
                    _onSelectionChanged(interval.id, selected),
                onLongPress: () => _onIntervalLongPress(interval),
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
    isInitiallyExpanded: false,
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

  void _addInterval() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewFeeIntervalScreen(
          onFeeIntervalAdded: (feeInterval) {
            setState(() => _feeIntervals.add(feeInterval));
          },
        ),
      ),
    );
  }

  void _onIntervalTap(FeeInterval interval) {
    if (_selectedIds.isNotEmpty) {
      _onSelectionChanged(interval.id, !_selectedIds.contains(interval.id));
    }
    // Tap functionality removed - only selection mode supported
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
    keyboardType: TextInputType.number,
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
    keyboardType: TextInputType.number,
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

  void _filterIntervals() {
    setState(() {
      final feeMinText = _feeMinController.text.trim();
      final feeMaxText = _feeMaxController.text.trim();

      if (feeMinText.isEmpty && feeMaxText.isEmpty) {
        _filteredIntervals = _feeIntervals;
        return;
      }

      final feeMin = double.tryParse(feeMinText) ?? 0.0;
      final feeMax = double.tryParse(feeMaxText) ?? double.infinity;

      _filteredIntervals = _feeIntervals.where((interval) {
        final intervalFee = interval.fee ?? 0.0;
        return intervalFee >= feeMin && intervalFee <= feeMax;
      }).toList();
    });
  }

  void _clearSearch() {
    _feeMinController.clear();
    _feeMaxController.clear();
  }

  void _editInterval(FeeInterval interval) {
    FeeIntervalEditBottomSheet.show(context, interval, (updatedInterval) {
      setState(() {
        final index = _feeIntervals.indexWhere((i) => i.id == interval.id);
        if (index != -1) _feeIntervals[index] = updatedInterval;
      });
    });
  }

  void _editSelectedInterval() {
    if (_selectedIds.length == 1) {
      final interval = _feeIntervals.firstWhere(
        (i) => i.id == _selectedIds.first,
      );
      _editInterval(interval);
    }
  }

  void _onOptimizeFees() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OptimizeFeeScreen()),
    );

    // Future: Navigate to FeeOptimizationScreen with min/max transaction amounts
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (_) => FeeOptimizationScreen(provider: widget.provider)
    // ));
  }

  void _deleteSelectedIntervals() async {
    final count = _selectedIds.length;
    final confirmed = await ConfirmationModal.show(
      context,
      AppLocalizations.of(context).deleteFeeIntervals,
      AppLocalizations.of(context).confirmDeleteIntervals(count),
    );

    if (confirmed == true && mounted) {
      // Show loading overlay
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AppLoading.overlay(),
      );

      // Simulate deletion process
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        context.pop(); // Close loading dialog
        setState(() {
          _feeIntervals.removeWhere((item) => _selectedIds.contains(item.id));
          _filteredIntervals = _feeIntervals;
          _selectedIds.clear();
        });
        AppToast.success(
          context,
          AppLocalizations.of(context).feeIntervalDeletedSuccessfully(count),
        );
      }
    }
  }
}
