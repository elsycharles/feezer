import 'package:flutter/material.dart' hide BottomSheet;

import '../../../model/provider_model.dart';
import '../../../styles/global.dart';
import '../../../util/icon_util.dart';
import '../../../util/theme_util.dart';
import '../../../widget/bottom_sheet.dart';
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
  ) =>
      BottomSheet.show(
        context,
        'Edit Provider',
        ProviderEditBottomSheet(provider: provider, onSave: onSave),
      );

  @override
  State<ProviderEditBottomSheet> createState() => _State();
}

class _State extends State<ProviderEditBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.provider.name);
  late final _descController = TextEditingController(text: widget.provider.description);
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
  }) =>
      TextFormField(
        controller: controller,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ThemeUtil.primaryColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: ThemeUtil.backgroundLight,
        ),
        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
      );

  Widget _iconField() => GestureDetector(
        onTap: _showIconPicker,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: ThemeUtil.textSecondary.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
            color: ThemeUtil.backgroundLight,
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
                  style: ThemeUtil.bodyMedium.copyWith(color: ThemeUtil.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Icon',
                style: ThemeUtil.titleSmall,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: IconUtil.availableIcons.length,
                  itemBuilder: (_, i) {
                    final iconName = IconUtil.availableIcons[i];
                    final isSelected = iconName == _selectedIcon;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedIcon = iconName);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ThemeUtil.primaryColor.withValues(alpha: 0.1)
                              : ThemeUtil.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: ThemeUtil.primaryColor, width: 2)
                              : null,
                        ),
                        child: Icon(
                          IconUtil.getIcon(iconName),
                          color: isSelected ? ThemeUtil.primaryColor : ThemeUtil.textSecondary,
                        ),
                      ),
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