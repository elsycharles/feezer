import 'package:flutter/material.dart' hide BottomSheet;

import '../../../model/provider_model.dart';
import '../../../styles/global.dart';
import '../../../util/icon_util.dart';
import '../../../util/theme_util.dart';
import '../../../widget/bottom_sheet.dart';
import '../../../widget/icon_picker.dart';
import '../../../widget/primary_button.dart';

/// Clean provider editor
class ProviderEditBottomSheet extends StatefulWidget {
  const ProviderEditBottomSheet({
    super.key,
    required this.provider,
    required this.onSave,
  });

  final Provider provider;
  final Function(Provider) onSave;

  static Future<void> show(
    BuildContext context,
    Provider provider,
    Function(Provider) onSave,
  ) => BottomSheet.show(
    context,
    'Edit Provider',
    ProviderEditBottomSheet(provider: provider, onSave: onSave),
  );

  @override
  State<ProviderEditBottomSheet> createState() => _State();
}

class _State extends State<ProviderEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(
    text: widget.provider.name,
  );
  late final _descController = TextEditingController(
    text: widget.provider.description,
  );
  late String _selectedIcon = widget.provider.iconName;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      children: [
        _field('Provider Name', _nameController, Icons.business),
        Global.gapLg,
        _field('Description', _descController, Icons.description, lines: 4),
        Global.gapLg,
        _iconField(),
        Global.gapXl,
        PrimaryButton(text: 'Save Changes', onPressed: _save),
      ],
    ),
  );

  Widget _field(
    String label,
    TextEditingController controller,
    IconData icon, {
    int lines = 1,
  }) => TextFormField(
    controller: controller,
    maxLines: lines,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: ThemeUtil.primaryColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: ThemeUtil.surfaceLight,
    ),
    validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
  );

  Widget _iconField() => GestureDetector(
    onTap: _showIconPicker,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: ThemeUtil.textSecondary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: ThemeUtil.surfaceLight,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ThemeUtil.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              IconUtil.getIcon(_selectedIcon),
              color: ThemeUtil.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tap to change icon',
              style: ThemeUtil.bodyMedium.copyWith(
                color: ThemeUtil.textSecondary,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _showIconPicker() => IconPicker.show(
    context: context,
    selected: _selectedIcon,
    onSelected: (icon) => setState(() => _selectedIcon = icon),
  );

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider(
        id: widget.provider.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        iconName: _selectedIcon,
        creationDatetime: widget.provider.creationDatetime,
      );
      Navigator.pop(context);
      widget.onSave(provider);
    }
  }
}
