import 'package:flutter/material.dart';
import '../../../model/currency_model.dart';
import '../../../util/theme_util.dart';
import '../../../styles/global.dart';
import '../../../widget/interactive_surface.dart';
import '../../../l10n/app_localizations.dart';

/// Reusable currency card widget for consistent styling
class CurrencyCard extends StatelessWidget {
  final Currency currency;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCheckbox;
  final bool isSelected;
  final ValueChanged<bool>? onSelectionChanged;
  final Widget? trailing;

  const CurrencyCard({
    super.key,
    required this.currency,
    this.onTap,
    this.onLongPress,
    this.showCheckbox = false,
    this.isSelected = false,
    this.onSelectionChanged,
    this.trailing,
  });

  String _formatRate(double rate) {
    // For very large numbers (> 1e15), use a more precise representation
    String valueStr;
    
    if (rate.abs() > 1e15) {
      // Use toStringAsFixed(0) for very large integers
      if (rate == rate.toInt()) {
        valueStr = rate.toInt().toString();
      } else {
        valueStr = rate.toStringAsFixed(0);
      }
    } else if (rate == rate.toInt()) {
      // For regular integers
      valueStr = rate.toInt().toString();
    } else {
      // For decimals - keep significant decimal digits
      String tempStr = rate.toString();
      if (tempStr.contains('.')) {
        List<String> parts = tempStr.split('.');
        String decimalPart = parts[1].replaceAll(RegExp(r'0+$'), '');
        if (decimalPart.isEmpty) {
          valueStr = parts[0];
        } else {
          valueStr = '${parts[0]}.$decimalPart';
        }
      } else {
        valueStr = tempStr;
      }
    }
    
    // Split integer and decimal parts
    List<String> parts = valueStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Format the integer part with spaces
    String formatted = '';
    int count = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        formatted = ' $formatted';
      }
      formatted = integerPart[i] + formatted;
      count++;
    }
    
    // Append the decimal part if it exists
    if (decimalPart.isNotEmpty) {
      formatted += '.$decimalPart';
    }
    
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InteractiveSurface(
      onTap: onTap,
      onLongPress: onLongPress,
      builder: (context, hovered, pressed) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _backgroundColor(colorScheme, hovered, pressed),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getBorderColor(colorScheme),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (showCheckbox) ...[
              Transform.scale(
                scale: 0.8,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onSelectionChanged != null
                      ? (value) => onSelectionChanged!(value ?? false)
                      : null,
                  visualDensity: VisualDensity.compact,
                  activeColor: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Currency icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  currency.symbol,
                  style: ThemeUtil.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            Global.gapMd,

            // Currency info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        currency.displayName,
                        style: ThemeUtil.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currency.code,
                          style: ThemeUtil.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppLocalizations.of(context).rateLabel} ${_formatRate(currency.rate)}',
                    style: ThemeUtil.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing widget (if no checkbox)
            if (!showCheckbox && trailing != null) ...[trailing!],
          ],
        ),
      ),
    );
  }

  Color _backgroundColor(ColorScheme colorScheme, bool hovered, bool pressed) {
    if (pressed) return colorScheme.surfaceContainerHighest;
    if (hovered) return colorScheme.surfaceContainerHigh;
    if (isSelected) return colorScheme.primary.withValues(alpha: 0.05);
    return colorScheme.surface;
  }

  Color _getBorderColor(ColorScheme colorScheme) {
    if (isSelected) return colorScheme.primary;
    return colorScheme.outlineVariant;
  }
}
