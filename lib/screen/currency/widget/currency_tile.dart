import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/currency_model.dart';
import 'currency_card.dart';

/// Currency tile with subtle hover feedback
class CurrencyTile extends StatelessWidget {
  const CurrencyTile({
    super.key,
    required this.currency,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onLongPress,
    this.onTap,
  });

  final Currency currency;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: CurrencyCard(
      currency: currency,
      showCheckbox: isSelected,
      isSelected: isSelected,
      onSelectionChanged: onSelectionChanged,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
    ),
  );
}