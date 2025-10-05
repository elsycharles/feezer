import 'package:flutter/material.dart';
import '../../model/provider_model.dart';
import '../../styles/global.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/search_field.dart';
import '../../widget/confirmation_modal.dart';
import '../../widget/search_empty_state.dart';
import '../../widget/primary_button.dart';
import '../provider_detail/provider_detail_screen.dart';
import '../new_provider/new_provider_screen.dart';
import 'widget/provider_header.dart';
import 'widget/provider_tile.dart';
import 'widget/provider_edit_bottom_sheet.dart';
import 'widget/selection_action_bar.dart';

/// Clean provider list screen
class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _State();
}

class _State extends State<ProviderListScreen> {
  final _searchController = TextEditingController();
  final _providers = <Provider>[
    Provider(
      id: '1',
      name: 'Bank',
      description: 'Traditional banking services',
      iconName: 'account_balance',
    ),
    Provider(
      id: '2',
      name: 'MVola',
      description: 'Mobile money transfer service',
      iconName: 'phone_android',
    ),
    Provider(
      id: '3',
      name: 'Orange',
      description: 'Telecom financial services',
      iconName: 'mobile_friendly',
    ),
    Provider(
      id: '4',
      name: 'Airtel',
      description: 'Mobile financial services',
      iconName: 'phone_android',
    ),
  ];

  final _selectedIds = <String>{};

  List<Provider> get _filtered {
    final query = _searchController.text.toLowerCase();
    return query.isEmpty
        ? _providers
        : _providers
              .where((p) => p.name.toLowerCase().contains(query))
              .toList();
  }

  bool get _isSingleSelection => _selectedIds.length == 1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addProvider() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewProviderScreen(
          onProviderAdded: (provider) {
            setState(() => _providers.add(provider));
          },
        ),
      ),
    );
  }

  Widget _buildProviderSliver() => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    sliver: _filtered.isEmpty
        ? SliverFillRemaining(
            hasScrollBody: false,
            child: const Center(
              child: SearchEmptyState(
                icon: Icons.search_off,
                title: 'No providers found',
              ),
            ),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final provider = _filtered[index];
              return ProviderTile(
                provider: provider,
                isSelected: _selectedIds.contains(provider.id),
                showSelection: _selectedIds.isNotEmpty,
                onSelectionChanged: (selected) =>
                    _toggleSelection(provider.id, selected),
                onLongPress: () => _startSelection(provider.id),
                onTap: _selectedIds.isNotEmpty
                    ? () => _toggleSelection(
                        provider.id,
                        !_selectedIds.contains(provider.id),
                      )
                    : () => _showProviderDetails(provider),
              );
            }, childCount: _filtered.length),
          ),
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: _selectedIds.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        // If we're in selection mode, clear it on back press instead of leaving the page/app
        if (!didPop && _selectedIds.isNotEmpty) {
          setState(() => _selectedIds.clear());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const custom.AppBar(title: 'Providers'),
        bottomNavigationBar:
            _selectedIds.isEmpty ? _buildAddProviderButton(colorScheme) : null,
        body: SafeArea(
          child: Column(
            children: [
              Global.gapMd,
              ProviderHeader(providerCount: _providers.length),
              Global.gapLg,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SearchField(
                  hintText: 'Search providers...',
                  controller: _searchController,
                ),
              ),
              if (_selectedIds.isNotEmpty) ...[
                Global.gapMd,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SelectionActionBar(
                    selectedCount: _selectedIds.length,
                    totalCount: _filtered.length,
                    onSelectAll: _selectAll,
                    onClearSelection: _clearSelection,
                    onDelete: _deleteSelected,
                    onEdit: _isSingleSelection ? _editSelected : null,
                    onDetails: _isSingleSelection ? _showSelectedDetails : null,
                  ),
                ),
              ],
              Global.gapMd,
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    _buildProviderSliver(),
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

  Widget _buildAddProviderButton(ColorScheme colorScheme) => Container(
    color: colorScheme.surface,
    padding: const EdgeInsets.all(16),
    child: SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: PrimaryButton(
          text: 'Add New Provider',
          onPressed: _addProvider,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    ),
  );

  // Selection methods
  void _startSelection(String id) {
    setState(() {
      _selectedIds.clear();
      _selectedIds.add(id);
    });
  }

  void _toggleSelection(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(_filtered.map((p) => p.id));
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  // Action methods
  void _editSelected() {
    if (_selectedIds.length == 1) {
      final provider = _providers.firstWhere((p) => p.id == _selectedIds.first);
      ProviderEditBottomSheet.show(context, provider, _editProvider);
    }
  }

  void _showSelectedDetails() {
    if (_selectedIds.length == 1) {
      final provider = _providers.firstWhere((p) => p.id == _selectedIds.first);
      _showProviderDetails(provider);
    }
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    final message = count == 1
        ? 'Delete this provider?'
        : 'Delete $count providers?';

    final confirmed = await ConfirmationModal.show(
      context,
      'Delete Provider${count > 1 ? 's' : ''}',
      message,
    );

    if (confirmed == true && mounted) {
      setState(() {
        _providers.removeWhere((p) => _selectedIds.contains(p.id));
        _selectedIds.clear();
      });
    }
  }

  void _editProvider(Provider provider) {
    setState(() {
      final index = _providers.indexWhere((p) => p.id == provider.id);
      if (index != -1) _providers[index] = provider;
    });
  }

  void _showProviderDetails(Provider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderDetailScreen(provider: provider),
      ),
    );
  }
}
