import 'package:flutter/material.dart';

import '../../model/provider_model.dart';
import '../../styles/global.dart';
import '../../util/icon_util.dart';
import '../../util/theme_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/icon_picker.dart';
import '../../widget/primary_button.dart';

/// Clean screen for creating new providers
class NewProviderScreen extends StatefulWidget {
  const NewProviderScreen({super.key, this.onProviderAdded});

  final Function(Provider)? onProviderAdded;

  @override
  State<NewProviderScreen> createState() => _State();
}

class _State extends State<NewProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController();
  late final _descriptionController = TextEditingController();
  String _selectedIcon = 'business';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: 'New Provider',
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(colorScheme),
                    Global.gapXl,
                    _buildNameField(colorScheme),
                    Global.gapLg,
                    _buildDescriptionField(colorScheme),
                    Global.gapLg,
                    _buildIconField(colorScheme),
                  ],
                ),
              ),
            ),
            _buildActions(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Create New Provider',
        style: ThemeUtil.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Add a new financial service provider to your list',
        style: ThemeUtil.bodyMedium.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.4,
        ),
      ),
    ],
  );

  Widget _buildNameField(ColorScheme colorScheme) =>
      _buildField(
    'Provider Name',
    _nameController,
    Icons.business,
    'Enter provider name',
    colorScheme: colorScheme,
    required: true,
  );

  Widget _buildDescriptionField(ColorScheme colorScheme) =>
      _buildField(
    'Description',
    _descriptionController,
    Icons.description,
    'Enter description',
    colorScheme: colorScheme,
    lines: 4,
    required: true,
  );

  Widget _buildIconField(ColorScheme colorScheme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Icon',
        style: ThemeUtil.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: _showIconPicker,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.surface,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  IconUtil.getIcon(_selectedIcon),
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tap to select icon',
                  style: ThemeUtil.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
    String hint, {
    int lines = 1,
    bool required = false,
    ColorScheme? colorScheme,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: ThemeUtil.bodyLarge.copyWith(
          color: (colorScheme ?? Theme.of(context).colorScheme).onSurface,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        textInputAction: lines > 1
            ? TextInputAction.newline
            : TextInputAction.next,
        keyboardType: lines > 1 ? TextInputType.multiline : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: ThemeUtil.bodyMedium.copyWith(
            color: (colorScheme ?? Theme.of(context).colorScheme)
        .onSurface
                .withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            icon,
            color: (colorScheme ?? Theme.of(context).colorScheme).primary,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: lines > 1 ? 16 : 12,
          ),
          border: _inputBorder(colorScheme: colorScheme),
          enabledBorder: _inputBorder(colorScheme: colorScheme),
          focusedBorder: _inputBorder(focused: true, colorScheme: colorScheme),
          errorBorder: _inputBorder(error: true, colorScheme: colorScheme),
          filled: true,
          fillColor:
              (colorScheme ?? Theme.of(context).colorScheme).surface,
        ),
        maxLines: lines,
        minLines: lines > 1 ? 2 : 1,
        validator: required ? _validateRequired : null,
      ),
    ],
  );

  OutlineInputBorder _inputBorder({
    bool focused = false,
    bool error = false,
    ColorScheme? colorScheme,
  }) {
    final scheme = colorScheme ?? Theme.of(context).colorScheme;
  final baseColor = error
    ? scheme.error
    : focused
      ? scheme.primary
      : scheme.outlineVariant;

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: baseColor,
        width: focused ? 2 : 1,
      ),
    );
  }

  String? _validateRequired(String? value) =>
      value?.trim().isEmpty == true ? 'This field is required' : null;

  Widget _buildActions(ColorScheme colorScheme) =>
      Container(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.of(context).padding.bottom + 20,
    ),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: Navigator.of(context).pop,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(
                colorScheme.onSurfaceVariant,
              ),
              overlayColor: ThemeUtil.interactiveOverlay(
                colorScheme.onSurfaceVariant,
              ),
              side: WidgetStateProperty.all(
                BorderSide(
                  color: colorScheme.outlineVariant,
                ),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 16),
              ),
              splashFactory: NoSplash.splashFactory,
            ),
            child: Text(
              'Cancel',
              style: ThemeUtil.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: PrimaryButton(text: 'Create Provider', onPressed: _create),
        ),
      ],
    ),
  );

  void _create() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final provider = Provider(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        iconName: _selectedIcon,
        creationDatetime: now,
      );
      widget.onProviderAdded?.call(provider);
      Navigator.pop(context);
    }
  }

  void _showIconPicker() => IconPicker.show(
    context: context,
    selected: _selectedIcon,
    onSelected: (icon) => setState(() => _selectedIcon = icon),
  );
}
