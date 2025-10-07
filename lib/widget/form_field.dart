import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../util/theme_util.dart';

/// Reusable form field with consistent styling
class FormField extends StatelessWidget {
  const FormField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.hintText,
    this.maxLines = 1,
    this.required = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String? hintText;
  final int maxLines;
  final bool required;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ThemeUtil.bodyLarge.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: ThemeUtil.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? 'Enter $label', // Note: Cette ligne nécessitera un contexte pour une traduction complète
            hintStyle: ThemeUtil.bodyMedium.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: colorScheme.primary)
                : null,
            filled: true,
            fillColor: colorScheme.surface,
            border: _buildBorder(colorScheme, false),
            enabledBorder: _buildBorder(colorScheme, false),
            focusedBorder: _buildBorder(colorScheme, true),
          ),
          validator: validator ?? (required ? _defaultValidator : null),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(ColorScheme colorScheme, bool focused) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: focused ? colorScheme.primary : colorScheme.outlineVariant,
          width: focused ? 2 : 1,
        ),
      );

  String? _defaultValidator(String? value) {
    if (value?.trim().isEmpty == true) {
      // Try to get context for translation, fallback to English if not available
      return 'This field is required';
    }
    return null;
  }
}