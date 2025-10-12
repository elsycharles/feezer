import 'package:flutter/material.dart';
import '../../../util/theme_util.dart';
import '../../../util/extensions_util.dart';
import '../../../styles/global.dart';
import '../../../l10n/app_localizations.dart';

/// Reusable search field with icon and clear functionality
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.hintText = 'Search...',
    this.clearTooltip,
    this.onChanged,
    this.controller,
  });

  final String hintText;
  final String? clearTooltip;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) => Container(
    height: Global.buttonHeight,
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
      borderRadius: Global.borderMd,
      border: Border.all(color: context.colorScheme.outlineVariant),
    ),
    child: TextField(
      controller: _controller,
      onChanged: (value) => widget.onChanged?.call(value),
      style: ThemeUtil.bodyMedium.copyWith(
        color: context.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: ThemeUtil.bodyMedium.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: context.colorScheme.onSurfaceVariant,
          size: 20,
        ),
        suffixIcon: _hasText
            ? IconButton(
                onPressed: _clearText,
                icon: Icon(
                  Icons.clear,
                  color: context.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                tooltip:
                    widget.clearTooltip ??
                    AppLocalizations.of(context).clearSearch,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: Global.borderMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: Global.borderMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Global.borderMd,
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: Global.borderMd,
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: Global.borderMd,
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: Global.borderMd,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    ),
  );
}
