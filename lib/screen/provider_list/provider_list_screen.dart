import 'package:flutter/material.dart';
import '../../model/provider_model.dart';
import '../../styles/global.dart';
import '../../util/theme_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/search_field.dart';
import '../../widget/confirmation_modal.dart';
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
    Provider(id: '1', name: 'Bank', description: 'Traditional banking services', iconName: 'account_balance'),
    Provider(id: '2', name: 'MVola', description: 'Mobile money transfer service', iconName: 'phone_android'),
    Provider(id: '3', name: 'Orange', description: 'Telecom financial services', iconName: 'mobile_friendly'),
    Provider(id: '4', name: 'Airtel', description: 'Mobile financial services', iconName: 'phone_android'),
  ];
  
  final _selectedIds = <String>{};

  List<Provider> get _filtered {
    final query = _searchController.text.toLowerCase();
    return query.isEmpty
        ? _providers
        : _providers.where((p) => p.name.toLowerCase().contains(query)).toList();
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const custom.AppBar(title: 'Providers'),
        body: Column(
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                )),
                child: child,
              ),
              child: _selectedIds.isNotEmpty
                  ? Column(
                      key: const ValueKey('selection-bar'),
                      children: [
                        Global.gapMd,
                        SelectionActionBar(
                          selectedCount: _selectedIds.length,
                          totalCount: _filtered.length,
                          onSelectAll: _selectAll,
                          onClearSelection: _clearSelection,
                          onDelete: _deleteSelected,
                          onEdit: _isSingleSelection ? _editSelected : null,
                          onDetails: _isSingleSelection ? _showSelectedDetails : null,
                        ),
                      ],
                    )
                  : SizedBox.shrink(key: const ValueKey('empty')),
            ),
            Global.gapMd,
            Expanded(
              child: _filtered.isEmpty
                  ? _empty()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final provider = _filtered[index];
                        return ProviderTile(
                          provider: provider,
                          isSelected: _selectedIds.contains(provider.id),
                          showSelection: _selectedIds.isNotEmpty,
                          onSelectionChanged: (selected) => _toggleSelection(provider.id, selected),
                          onLongPress: () => _startSelection(provider.id),
                          onTap: _selectedIds.isNotEmpty 
                              ? () => _toggleSelection(provider.id, !_selectedIds.contains(provider.id))
                              : () => _showProviderDetails(provider),
                        );
                      },
                    ),
            ),
            if (_selectedIds.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addProvider,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeUtil.primaryColor,
                      foregroundColor: ThemeUtil.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Add New Provider',
                      style: ThemeUtil.bodyLarge.copyWith(color: ThemeUtil.textLight),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  Widget _empty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: ThemeUtil.textSecondary),
            const SizedBox(height: 16),
            Text('No providers found', style: ThemeUtil.bodyMedium.copyWith(color: ThemeUtil.textSecondary)),
          ],
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