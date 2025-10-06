import 'package:flutter/material.dart';
import '../util/theme_util.dart';
import '../util/extensions.dart';
import '../styles/global.dart';

/// Reusable search field with icon
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.controller,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) => Container(
    height: Global.buttonHeight,
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
      borderRadius: Global.borderMd,
      border: Border.all(color: context.colorScheme.outlineVariant),
    ),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: ThemeUtil.bodyMedium.copyWith(color: context.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: ThemeUtil.bodyMedium.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: context.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    ),
  );
}
