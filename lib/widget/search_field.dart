import 'package:flutter/material.dart';
import '../util/theme_util.dart';

/// Reusable search field with icon
class SearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchField({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: ThemeUtil.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ThemeUtil.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: ThemeUtil.bodyMedium,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: ThemeUtil.bodyMedium.copyWith(color: ThemeUtil.textSecondary),
          prefixIcon: Icon(
            Icons.search,
            color: ThemeUtil.textSecondary,
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
}