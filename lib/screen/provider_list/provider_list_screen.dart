import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../model/provider_model.dart';
import '../../styles/global.dart';
import '../../util/navigation_util.dart';
import '../../widget/app_bar.dart' as custom;
import 'widget/search_field.dart';
import '../../widget/confirmation_modal.dart';
import '../../widget/search_empty_state.dart';
import '../../widget/app_toast.dart';
import '../../widget/app_loading.dart';
import '../../widget/loading_button.dart';
import 'widget/provider_header.dart';
import 'widget/provider_tile.dart';
import 'widget/provider_edit_bottom_sheet.dart';
import '../../widget/selection_action_bar.dart';
import '../../util/database_util.dart';
import '../../util/constant_util.dart';
import '../../widget/refreshable_screen.dart';

/// Clean provider list screen
class ProviderListScreen extends StatefulWidget {
  const ProviderListScreen({super.key});

  @override
  State<ProviderListScreen> createState() => _State();
}

class _State extends State<ProviderListScreen> {
  final _searchController = TextEditingController();
  final _providers = <Provider>[];
  final _selectedIds = <String>{};
  bool _isLoading = true;

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
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() => _isLoading = true);
    final db = DatabaseUtil();
    final providerMaps = await db.query(ConstantUtil.tableProviders);
    final loadedProviders = providerMaps
        .map((map) => Provider.fromMap(map))
        .toList();
    if (mounted) {
      setState(() {
        _providers
          ..clear()
          ..addAll(loadedProviders);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addProvider() async {
    await NavigationUtil.pushTo(context, NavigationUtil.newProviderRoute);
    // Always reload providers after returning from new provider screen
    await _loadProviders();
  }

  Widget _buildProviderSliver() => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    sliver: _filtered.isEmpty
        ? SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: SearchEmptyState(
                icon: Icons.search_off,
                title: AppLocalizations.of(context).noProvidersFound,
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
        // When selection mode is active, clear it instead of popping the route
        if (!didPop && _selectedIds.isNotEmpty) {
          setState(() => _selectedIds.clear());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: custom.AppBar(
          title: AppLocalizations.of(context).providers,
          menuExcludeRoutes: [NavigationUtil.providersRoute],
        ),
        bottomNavigationBar: _selectedIds.isEmpty
            ? _buildAddProviderButton(colorScheme)
            : null,
        body: SafeArea(
          child: RefreshableScreen(
            onRefresh: _loadProviders,
            child: Column(
              children: [
                Global.gapMd,
                ProviderHeader(providerCount: _providers.length),
                Global.gapLg,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(
                    hintText: AppLocalizations.of(context).searchProviders,
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
                      margin: EdgeInsets.zero,
                    ),
                  ),
                ],
                Global.gapMd,
                Expanded(
                  child: _isLoading
                      ? const AppLoading.overlay()
                      : CustomScrollView(
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
        child: LoadingButton(
          text: AppLocalizations.of(context).addNewProvider,
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
    final l10n = AppLocalizations.of(context);
    final message = count == 1
        ? '${l10n.deleteThisProvider}\n\n${l10n.deleteProviderWarning}'
        : '${l10n.deleteProvidersCount(count)}\n\n${l10n.deleteProviderWarning}';

    final confirmed = await ConfirmationModal.show(
      context,
      count > 1 ? l10n.deleteProviders : l10n.deleteProvider,
      message,
    );

    if (confirmed == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const AppLoading.overlay(),
      );
      final db = DatabaseUtil();
      for (final id in _selectedIds) {
        await db.database.then((database) async {
          // First delete all fee intervals associated with this provider
          await database.delete(
            ConstantUtil.tableFeeIntervals,
            where: '${ConstantUtil.columnProviderId} = ?',
            whereArgs: [int.tryParse(id)],
          );
          // Then delete the provider
          await database.delete(
            ConstantUtil.tableProviders,
            where: '${ConstantUtil.columnId} = ?',
            whereArgs: [int.tryParse(id)],
          );
        });
      }
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        Navigator.of(context).pop();
        AppToast.success(context, l10n.providerDeletedSuccessfully(count));
        await _loadProviders();
        setState(() => _selectedIds.clear());
      }
    }
  }

  void _editProvider(Provider provider) async {
    final db = DatabaseUtil();
    await db.database.then((database) {
      database.update(
        ConstantUtil.tableProviders,
        Provider.toMap(provider),
        where: '${ConstantUtil.columnId} = ?',
        whereArgs: [int.tryParse(provider.id)],
      );
    });
    await _loadProviders();
  }

  void _showProviderDetails(Provider provider) {
    NavigationUtil.pushTo(
      context,
      NavigationUtil.providerDetailRoute,
      extra: provider,
    );
  }
}

// All test data removed. Provider list is now fully dynamic from DB.
