import 'package:flutter/material.dart' hide BottomSheet;

import '../../../model/provider_model.dart';
import '../../../styles/global.dart';
import '../../../widget/bottom_sheet.dart';
import '../../../widget/form_field.dart' as custom_form;
import '../../../widget/icon_selector_field.dart';
import '../../../widget/loading_widgets.dart';
import '../../../util/theme_util.dart';

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
  bool _isLoading = false;
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
        custom_form.FormField(
          label: 'Provider Name',
          controller: _nameController,
          icon: Icons.business,
          required: true,
        ),
        Global.gapLg,
        custom_form.FormField(
          label: 'Description',
          controller: _descController,
          icon: Icons.description,
          maxLines: 4,
          required: true,
        ),
        Global.gapLg,
        IconSelectorField(
          selectedIcon: _selectedIcon,
          onChanged: (icon) => setState(() => _selectedIcon = icon),
        ),
        Global.gapXl,
        LoadingButton(
          text: 'Save Changes',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _save,
        ),
      ],
    ),
  );



  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final provider = Provider(
          id: widget.provider.id,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          iconName: _selectedIcon,
          creationDatetime: widget.provider.creationDatetime,
        );
        
        // Simulate async operation
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          Navigator.pop(context);
          widget.onSave(provider);
          ThemeUtil.showSuccessToast('Provider updated successfully', context: context);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
