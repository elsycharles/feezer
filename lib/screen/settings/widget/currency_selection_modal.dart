import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/currency_provider.dart';
import '../../../model/currency_model.dart';
import '../../../widget/interactive_surface.dart';
import '../../../l10n/app_localizations.dart';
import '../../../util/database_util.dart';
import '../../../util/constant_util.dart';

/// Currency selection modal with radio buttons
class CurrencySelectionModal extends StatefulWidget {
  const CurrencySelectionModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CurrencySelectionModal(),
    );
  }

  @override
  State<CurrencySelectionModal> createState() => _CurrencySelectionModalState();
}

class _CurrencySelectionModalState extends State<CurrencySelectionModal> {
  final List<Currency> _currencies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
  }

  Future<void> _loadCurrencies() async {
    final db = DatabaseUtil();
    final currencyMaps = await db.query(ConstantUtil.tableCurrencies);
    final loadedCurrencies = currencyMaps.map((map) => Currency.fromMap(map)).toList();

    if (mounted) {
      setState(() {
        _currencies.addAll(loadedCurrencies);
        _isLoading = false;
      });
    }
  }

  void _changeCurrency(BuildContext context, Currency currency) {
    final currencyProvider = context.read<CurrencyProvider>();
    currencyProvider.setSelectedCurrency(currency);
    // Do not close modal automatically
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar - tap to close
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text(
                l10n.currencies,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Currency options
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              Consumer<CurrencyProvider>(
                builder: (context, currencyProvider, child) {
                  return Column(
                    children: [
                      // System default option (Ariary)
                      _buildCurrencyOption(
                        context,
                        'Ariary (Ar)', // Always show Ariary as the system default
                        currencyProvider.selectedCurrency == null || currencyProvider.selectedCurrency?.code == 'MGA',
                        () {
                          final currencyProvider = context.read<CurrencyProvider>();
                          currencyProvider.clearSelectedCurrency();
                        },
                        icon: Icons.settings_brightness,
                      ),

                      // Currency options (excluding Ariary since it's the system default)
                      ..._currencies.where((currency) => currency.code != 'MGA').map((currency) => _buildCurrencyOption(
                        context,
                        currency.displayName,
                        currencyProvider.selectedCurrency?.id == currency.id,
                        () => _changeCurrency(context, currency),
                        icon: Icons.currency_exchange,
                      )),
                    ],
                  );
                },
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(
    BuildContext context,
    String primaryText,
    bool isSelected,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveSurface(
      onTap: onTap,
      builder: (context, hovered, pressed) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            // Icon
            if (icon != null) ...[
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
            ],

            // Text
            Expanded(
              child: Text(
                primaryText,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),

            // Radio button indicator
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}