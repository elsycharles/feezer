import 'package:flutter/material.dart';

import '../../model/provider_model.dart';
import '../../styles/global.dart';
import '../../util/icon_util.dart';
import '../../util/theme_util.dart';
import '../../widget/app_bar.dart' as custom;
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
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: ThemeUtil.backgroundLight,
        appBar: custom.AppBar(
          title: 'New Provider',
          leading: IconButton(
            onPressed: Navigator.of(context).pop,
            icon: const Icon(Icons.arrow_back, color: ThemeUtil.textPrimary),
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
                      _buildHeader(),
                      Global.gapXl,
                      _buildNameField(),
                      Global.gapLg,
                      _buildDescriptionField(),
                      Global.gapLg,
                      _buildIconField(),
                    ],
                  ),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      );

  Widget _buildHeader() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Provider',
            style: ThemeUtil.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new financial service provider to your list',
            style: ThemeUtil.bodyMedium.copyWith(
              color: ThemeUtil.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      );

  Widget _buildNameField() => _buildField(
        'Provider Name',
        _nameController,
        Icons.business,
        'Enter provider name',
        required: true,
      );

  Widget _buildDescriptionField() => _buildField(
        'Description',
        _descriptionController,
        Icons.description,
        'Enter description',
        lines: 4,
        required: true,
      );

  Widget _buildIconField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Icon',
            style: ThemeUtil.bodyLarge,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _showIconPicker,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: ThemeUtil.textSecondary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(16),
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
                      'Tap to select icon',
                      style: ThemeUtil.bodyMedium.copyWith(color: ThemeUtil.textSecondary),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: ThemeUtil.textSecondary),
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
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: ThemeUtil.bodyLarge,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            textInputAction: lines > 1 ? TextInputAction.newline : TextInputAction.next,
            keyboardType: lines > 1 ? TextInputType.multiline : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ThemeUtil.bodyMedium.copyWith(color: ThemeUtil.textSecondary),
              prefixIcon: Icon(icon, color: ThemeUtil.primaryColor),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: lines > 1 ? 16 : 12,
              ),
              border: _inputBorder(),
              enabledBorder: _inputBorder(),
              focusedBorder: _inputBorder(focused: true),
              errorBorder: _inputBorder(error: true),
              filled: true,
              fillColor: ThemeUtil.surfaceLight,
            ),
            maxLines: lines,
            minLines: lines > 1 ? 2 : 1,
            validator: required ? _validateRequired : null,
          ),
        ],
      );

  OutlineInputBorder _inputBorder({bool focused = false, bool error = false}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: error
              ? ThemeUtil.error
              : focused
                  ? ThemeUtil.primaryColor
                  : ThemeUtil.textSecondary.withValues(alpha: 0.2),
          width: focused ? 2 : 1,
        ),
      );

  String? _validateRequired(String? value) =>
      value?.trim().isEmpty == true ? 'This field is required' : null;

  Widget _buildActions() => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).padding.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: ThemeUtil.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: ThemeUtil.textPrimary.withValues(alpha: 0.05),
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
                  foregroundColor: WidgetStateProperty.all(ThemeUtil.textSecondary),
                  overlayColor: ThemeUtil.interactiveOverlay(ThemeUtil.textSecondary),
                  side: WidgetStateProperty.all(
                    BorderSide(color: ThemeUtil.textSecondary.withValues(alpha: 0.3)),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
                  splashFactory: NoSplash.splashFactory,
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: PrimaryButton(
                text: 'Create Provider',
                onPressed: _create,
              ),
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
}