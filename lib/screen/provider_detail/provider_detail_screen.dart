import 'package:flutter/material.dart';
import '../../model/provider_model.dart';
import '../../model/fee_interval_model.dart';
import '../../util/theme_util.dart';
import '../../styles/global.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/confirmation_modal.dart';
import '../../widget/search_empty_state.dart';
import 'widget/provider_header_card.dart';
import 'widget/fee_interval_tile.dart';
import 'widget/fee_interval_selection_action_bar.dart';

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
      creationDatetime: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FeeInterval(
      id: 'interval_1',
      minAmount: 1001,
      maxAmount: 5000,
      fee: 150,
      creationDatetime: DateTime.now().subtract(const Duration(days: 3)),
    ),
    FeeInterval(
      id: 'interval_2',
      minAmount: 5001,
      maxAmount: 10000,
      fee: 300,
      creationDatetime: DateTime.now().subtract(const Duration(days: 7)),
    ),
    FeeInterval(
      id: 'interval_3',
      minAmount: 10001,
      maxAmount: 25000,
      fee: 500,
      creationDatetime: DateTime.now().subtract(const Duration(days: 14)),
    ),
    FeeInterval(
      id: 'interval_4',
      minAmount: 25001,
      maxAmount: 50000,
      fee: 800,
      creationDatetime: DateTime.now().subtract(const Duration(days: 21)),
    ),
  ];

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: _selectedIds.isEmpty,
        onPopInvokedWithResult: (didPop, result) {
          // When selection mode is active, clear it instead of popping the route
          if (!didPop && _selectedIds.isNotEmpty) {
            setState(() => _selectedIds.clear());
          }
        },
    child: Scaffold(
      backgroundColor: ThemeUtil.backgroundLight,
      appBar: custom.AppBar(
        title: 'Provider details',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedIds.isNotEmpty) {
              // Clear selection instead of popping when in selection mode
              setState(() => _selectedIds.clear());
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      bottomNavigationBar: _buildAddButton(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Global.gapMd,
            _buildSearchBar(),
            if (_selectedIds.isNotEmpty) ...[
              Global.gapMd,
              _buildSelectionBar(),
            ],
            Global.gapMd,
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

  Widget _buildSelectionBar() => FeeIntervalSelectionActionBar(
    selectedCount: _selectedIds.length,
    totalCount: _filteredIntervals.length,
    onSelectAll: _selectAll,
    onClearSelection: _clearSelection,
    onDelete: _deleteSelectedIntervals,
    onEdit: _selectedIds.length == 1 ? () => _editSelectedInterval() : null,
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
            child: const SearchEmptyState(
              icon: Icons.search_off,
              title: 'No fee intervals found',
              message: 'Try adjusting your search range.',
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

  Widget _buildSearchBar() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ThemeUtil.surfaceLight,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: ThemeUtil.textSecondary.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.search, size: 18, color: ThemeUtil.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Search by Fee Range',
                  style: ThemeUtil.titleSmall.copyWith(
                    color: ThemeUtil.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (_feeMinController.text.isNotEmpty ||
                _feeMaxController.text.isNotEmpty)
              GestureDetector(
                onTap: _clearSearch,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: ThemeUtil.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.clear,
                    size: 16,
                    color: ThemeUtil.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        Global.gapMd,
        Row(
          children: [
            Expanded(child: _buildFeeMinField()),
            const SizedBox(width: 12),
            Expanded(child: _buildFeeMaxField()),
          ],
        ),
      ],
    ),
  );

  Widget _buildAddButton() => Container(
    color: ThemeUtil.backgroundLight,
    padding: const EdgeInsets.all(16),
    child: SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _addInterval,
          icon: const Icon(Icons.add),
          label: const Text('Add Fee Interval'),
          style: ButtonStyle(
            backgroundColor: ThemeUtil.interactiveBackground(
              ThemeUtil.primaryColor,
            ),
            foregroundColor: WidgetStateProperty.all(ThemeUtil.textLight),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(vertical: 14),
            ),
            overlayColor: ThemeUtil.interactiveOverlay(ThemeUtil.textLight),
            elevation: WidgetStateProperty.all(0),
            splashFactory: NoSplash.splashFactory,
          ),
        ),
      ),
    ),
  );

  void _addInterval() {
    // TODO: Navigate to add fee interval screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add interval feature coming soon')),
    );
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

  Widget _buildFeeMinField() => TextField(
    controller: _feeMinController,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      hintText: 'Min fee',
      hintStyle: ThemeUtil.bodySmall.copyWith(color: ThemeUtil.textSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: ThemeUtil.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: ThemeUtil.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    style: ThemeUtil.bodySmall,
  );

  Widget _buildFeeMaxField() => TextField(
    controller: _feeMaxController,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      hintText: 'Max fee',
      hintStyle: ThemeUtil.bodySmall.copyWith(color: ThemeUtil.textSecondary),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: ThemeUtil.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: ThemeUtil.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    style: ThemeUtil.bodySmall,
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
    // TODO: Implement edit functionality
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
    // TODO: Navigate to fee optimization screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to Fee Optimization...'),
        backgroundColor: ThemeUtil.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
      'Delete Fee Intervals',
      'Are you sure you want to delete $count selected interval${count > 1 ? 's' : ''}?',
    );

    if (confirmed == true) {
      setState(() {
        _feeIntervals.removeWhere((item) => _selectedIds.contains(item.id));
        _selectedIds.clear();
      });
    }
  }
}
