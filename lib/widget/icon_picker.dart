import 'package:flutter/material.dart';

import '../util/icon_util.dart';
import '../util/theme_util.dart';
import 'interactive_surface.dart';

class IconPicker {
  static Future<void> show({
    required BuildContext context,
    required String selected,
    required ValueChanged<String> onSelected,
    String title = 'Select Icon',
  }) => showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: ThemeUtil.titleSmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: IconUtil.availableIcons.length,
                itemBuilder: (dialogContext, index) {
                  final iconName = IconUtil.availableIcons[index];
                  return _IconOption(
                    iconName: iconName,
                    selected: iconName == selected,
                    onTap: () {
                      onSelected(iconName);
                      Navigator.of(dialogContext).pop();
                    },
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

class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.iconName,
    required this.selected,
    required this.onTap,
  });

  final String iconName;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InteractiveSurface(
    borderRadius: BorderRadius.circular(12),
    onTap: onTap,
    enableScale: false,
    builder: (_, hovered, pressed) {
      final color = ThemeUtil.interactiveSurfaceColor(
        selected
            ? ThemeUtil.primaryColor.withValues(alpha: 0.12)
            : ThemeUtil.surfaceLight,
        hovered: hovered,
        pressed: pressed,
      );
      final scale = pressed
          ? 0.95
          : selected
          ? 1.05
          : 1.0;
      return AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? ThemeUtil.primaryColor
                  : ThemeUtil.textSecondary.withValues(alpha: 0.12),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ThemeUtil.primaryColor.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              IconUtil.getIcon(iconName),
              color: selected
                  ? ThemeUtil.primaryColor
                  : ThemeUtil.textSecondary,
            ),
          ),
        ),
      );
    },
  );
}
