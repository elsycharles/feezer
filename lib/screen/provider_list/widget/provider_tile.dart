import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/provider_model.dart';
import '../../../widget/provider_card.dart';

/// Provider tile with subtle hover feedback
class ProviderTile extends StatelessWidget {
  const ProviderTile({
    super.key,
    required this.provider,
    required this.isSelected,
    required this.showSelection,
    required this.onSelectionChanged,
    required this.onLongPress,
    this.onTap,
  });

  final Provider provider;
  final bool isSelected;
  final bool showSelection;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onLongPress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: ProviderCard(
      provider: provider,
      showCheckbox: showSelection,
      isSelected: isSelected,
      onSelectionChanged: onSelectionChanged,
      showDescription: true,
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
