import 'package:flutter/material.dart';
import '../../model/provider_model.dart';
import '../../model/fee_interval_model.dart';
import '../../util/theme_util.dart';
import '../../styles/global.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/confirmation_modal.dart';
import 'widget/provider_header_card.dart';
import 'widget/fee_interval_tile.dart';
import 'widget/fee_interval_selection_action_bar.dart';

/// Provider details screen with fee intervals management
class ProviderDetailScreen extends StatefulWidget {
  final Provider provider;

  const ProviderDetailScreen({
    super.key,
    required this.provider,
  });

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  late List<FeeInterval> _feeIntervals;
  final Set<String> _selectedIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _feeIntervals = _generateMockIntervals();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ThemeUtil.backgroundLight,
        appBar: custom.AppBar(
          title: 'Provider details',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            _buildHeader(),
            _buildFeeIntervals(),
            _buildAddButton(),
          ],
        ),
      );

  Widget _buildSelectionBar() => FeeIntervalSelectionActionBar(
        selectedCount: _selectedIds.length,
        totalCount: _feeIntervals.length,
        onSelectAll: _selectAll,
        onClearSelection: _clearSelection,
        onDelete: _deleteSelectedIntervals,
        onEdit: _selectedIds.length == 1 ? () => _editSelectedInterval() : null,
      );

  Widget _buildHeader() => Container(
        margin: const EdgeInsets.all(16),
        child: ProviderHeaderCard(provider: widget.provider),
      );

  Widget _buildFeeIntervals() => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(),
            if (_selectedIds.isNotEmpty) ...[
              Global.gapMd,
              _buildSelectionBar(),
            ],
            Global.gapMd,
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _feeIntervals.length,
                itemBuilder: (context, index) {
                  final interval = _feeIntervals[index];
                  return FeeIntervalTile(
                    feeInterval: interval,
                    isSelected: _selectedIds.contains(interval.id),
                    showSelection: _selectedIds.isNotEmpty,
                    onTap: () => _onIntervalTap(interval),
                    onSelectionChanged: (selected) => _onSelectionChanged(interval.id, selected),
                    onLongPress: () => _onIntervalLongPress(interval),
                  );
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildSectionHeader() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text('Fee intervals', style: ThemeUtil.titleSmall),
      );

  Widget _buildAddButton() => Container(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addInterval,
            icon: const Icon(Icons.add),
            label: const Text('Add Fee Interval'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeUtil.primaryColor,
              foregroundColor: ThemeUtil.textLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
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
      _selectedIds.addAll(_feeIntervals.map((e) => e.id).whereType<String>());
    });
  }

  void _editInterval(FeeInterval interval) {
    // TODO: Implement edit functionality
    print('Edit interval: ${interval.id}');
  }

  void _editSelectedInterval() {
    if (_selectedIds.length == 1) {
      final interval = _feeIntervals.firstWhere((i) => i.id == _selectedIds.first);
      _editInterval(interval);
    }
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