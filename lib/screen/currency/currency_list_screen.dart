import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../model/currency_model.dart';
import '../../styles/global.dart';
import '../../util/navigation_util.dart';
import '../../widget/app_bar.dart' as custom;
import 'widget/search_field.dart';
import '../../widget/search_empty_state.dart';
import '../../widget/app_toast.dart';
import '../../widget/app_loading.dart';
import '../../widget/loading_button.dart';
import '../../util/extensions_util.dart';
import '../../util/theme_util.dart';
import 'widget/currency_header.dart';
import 'widget/currency_tile.dart';
import 'widget/currency_edit_bottom_sheet.dart';
import '../../widget/selection_action_bar.dart';
import '../../util/database_util.dart';
import '../../util/constant_util.dart';
import '../../widget/refreshable_screen.dart';

/// Clean currency list screen
class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen({super.key});

  @override
  State<CurrencyListScreen> createState() => _State();
}

class _State extends State<CurrencyListScreen> {
  final _searchController = TextEditingController();
  final _currencies = <Currency>[];
  final _selectedIds = <String>{};
  bool _isLoading = true;

  List<Currency> get _filtered {
    final query = _searchController.text.toLowerCase();
    return query.isEmpty
        ? _currencies
        : _currencies
              .where((c) => c.name.toLowerCase().contains(query) ||
                           c.code.toLowerCase().contains(query) ||
                           c.symbol.toLowerCase().contains(query))
              .toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    setState(() => _isLoading = true);
    final db = DatabaseUtil();
    final currencyMaps = await db.query(ConstantUtil.tableCurrencies);
    final loadedCurrencies = currencyMaps.map((map) => Currency.fromMap(map)).toList();
    if (mounted) {
      setState(() {
        _currencies
          ..clear()
          ..addAll(loadedCurrencies);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addCurrency() async {
    await NavigationUtil.pushTo(context, NavigationUtil.newCurrencyRoute);
    // Always reload currencies after returning from new currency screen
    await _loadCurrencies();
  }

  void _editCurrency(Currency currency) async {
    await CurrencyEditBottomSheet.show(
      context,
      currency,
      _updateCurrency,
    );
  }

  void _updateCurrency(Currency updatedCurrency) async {
    try {
      final db = DatabaseUtil();
      await db.update(
        ConstantUtil.tableCurrencies,
        updatedCurrency.toMap(),
        where: '${ConstantUtil.columnId} = ?',
        whereArgs: [updatedCurrency.id],
      );

      if (mounted) {
        await _loadCurrencies();
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, AppLocalizations.of(context).failedToUpdateCurrency);
      }
    }
  }

  void _deleteCurrencies() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmationDialog(
        title: AppLocalizations.of(context).deleteCurrencies,
        message: AppLocalizations.of(context).confirmDeleteCurrencies(count),
        confirmText: AppLocalizations.of(context).delete,
        cancelText: AppLocalizations.of(context).cancel,
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);

      final db = DatabaseUtil();
      for (final id in _selectedIds) {
        await db.delete(
          ConstantUtil.tableCurrencies,
          where: '${ConstantUtil.columnId} = ?',
          whereArgs: [id],
        );
      }

      if (mounted) {
        AppToast.success(
          context,
          AppLocalizations.of(context).currencyDeletedSuccessfully,
        );
        setState(() {
          _selectedIds.clear();
          _isLoading = false;
        });
        await _loadCurrencies();
      }
    }
  }

  void _startSelection(String id) {
    setState(() {
      _selectedIds.clear();
      _selectedIds.add(id);
    });
  }

  void _toggleSelection(String id, [bool? selected]) {
    setState(() {
      if (selected ?? !_selectedIds.contains(id)) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  void _selectAll() {
    setState(() {
      _selectedIds.clear();
      _selectedIds.addAll(_filtered.map((c) => c.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: AppLocalizations.of(context).currencies,
        leading: null, // Will be handled by automaticallyImplyLeading
        automaticallyImplyLeading: ModalRoute.of(context)?.canPop ?? false,
        showMenuButton: true,
        menuExcludeRoutes: const [NavigationUtil.currenciesRoute],
      ),
      bottomNavigationBar: _selectedIds.isEmpty
          ? _buildAddCurrencyButton(context.colorScheme)
          : null,
      body: _isLoading
          ? const AppLoading()
          : SafeArea(
              child: RefreshableScreen(
                onRefresh: _loadCurrencies,
                child: Column(
                  children: [
                    Global.gapMd,
                    CurrencyHeader(
                      totalCount: _currencies.length,
                      filteredCount: _filtered.length,
                      selectedCount: _selectedIds.length,
                    ),
                    Global.gapLg,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SearchField(
                        controller: _searchController,
                        hintText: AppLocalizations.of(context).searchCurrencies,
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
                        onDelete: _deleteCurrencies,
                        onEdit: _selectedIds.length == 1 ? () => _editCurrency(_filtered.firstWhere((c) => c.id == _selectedIds.first)) : null,
                        margin: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  Global.gapMd,
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(
                            child: SearchEmptyState(
                              icon: Icons.currency_exchange,
                              title: _searchController.text.isEmpty
                                  ? AppLocalizations.of(context).noCurrenciesFound
                                  : AppLocalizations.of(context).noCurrenciesFound,
                              message: _searchController.text.isEmpty
                                  ? AppLocalizations.of(context).centralizeCurrencies
                                  : null,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final currency = _filtered[index];
                              return CurrencyTile(
                                currency: currency,
                                isSelected: _selectedIds.contains(currency.id),
                                showSelection: _selectedIds.isNotEmpty,
                                onSelectionChanged: (selected) =>
                                    _toggleSelection(currency.id, selected),
                                onLongPress: () => _startSelection(currency.id),
                                onTap: _selectedIds.isNotEmpty
                                    ? () => _toggleSelection(
                                      currency.id,
                                      !_selectedIds.contains(currency.id),
                                    )
                                  : () => _editCurrency(currency),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            ),
    );
  }

  Widget _buildAddCurrencyButton(ColorScheme colorScheme) => Container(
    color: colorScheme.surface,
    padding: const EdgeInsets.all(16),
    child: SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        child: LoadingButton(
          text: AppLocalizations.of(context).addNewCurrency,
          onPressed: _addCurrency,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    ),
  );
}

class _ConfirmationDialog extends StatelessWidget {
  const _ConfirmationDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(colorScheme),
            const SizedBox(height: 16),
            _buildMessage(colorScheme),
            const SizedBox(height: 24),
            _buildActions(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.warning_rounded, color: colorScheme.error, size: 24),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          title,
          style: ThemeUtil.titleLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  Widget _buildMessage(ColorScheme colorScheme) => Text(
    message,
    style: ThemeUtil.bodyMedium.copyWith(
      color: colorScheme.onSurfaceVariant,
    ),
    textAlign: TextAlign.center,
  );

  Widget _buildActions(BuildContext context, ColorScheme colorScheme) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: colorScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            cancelText,
            style: ThemeUtil.labelLarge.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: colorScheme.error,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            confirmText,
            style: ThemeUtil.labelLarge.copyWith(
              color: colorScheme.onError,
            ),
          ),
        ),
      ),
    ],
  );
}