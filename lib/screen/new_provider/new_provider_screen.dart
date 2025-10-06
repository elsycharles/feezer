import 'package:flutter/material.dart';

import '../../model/provider_model.dart';
import '../../styles/global.dart';
import '../../util/theme_util.dart';
import '../../util/extensions.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/form_field.dart' as custom_form;
import '../../widget/icon_selector_field.dart';
import '../../widget/loading_button.dart';
import '../../widget/app_toast.dart';

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
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.theme.scaffoldBackgroundColor,
    appBar: custom.AppBar(
      title: 'New Provider',
      leading: IconButton(
        onPressed: context.pop,
        icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
      ),
    ),
    body: Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: Global.padLg,
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
      Text(
        'Create New Provider',
        style: ThemeUtil.titleLarge.copyWith(
          color: context.colorScheme.onSurface,
        ),
      ),
      Global.gapSm,
      Text(
        'Add a new financial service provider to your list',
        style: ThemeUtil.bodyMedium.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.4,
        ),
      ),
    ],
  );

  Widget _buildNameField() => custom_form.FormField(
    label: 'Provider Name',
    controller: _nameController,
    icon: Icons.business,
    hintText: 'Enter provider name',
    required: true,
  );

  Widget _buildDescriptionField() => custom_form.FormField(
    label: 'Description',
    controller: _descriptionController,
    icon: Icons.description,
    hintText: 'Enter description',
    maxLines: 4,
    required: true,
  );

  Widget _buildIconField() => IconSelectorField(
    selectedIcon: _selectedIcon,
    onChanged: (icon) => setState(() => _selectedIcon = icon),
  );

  Widget _buildActions() => Container(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      context.mediaQuery.padding.bottom + 20,
    ),
    decoration: BoxDecoration(
      color: context.colorScheme.surface,
      boxShadow: Global.shadowMd,
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: context.pop,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(
                context.colorScheme.onSurfaceVariant,
              ),
              overlayColor: ThemeUtil.interactiveOverlay(
                context.colorScheme.onSurfaceVariant,
              ),
              side: WidgetStateProperty.all(
                BorderSide(color: context.colorScheme.outlineVariant),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: Global.borderMd),
              ),
              padding: WidgetStateProperty.all(Global.padVerticalMd),
              splashFactory: NoSplash.splashFactory,
            ),
            child: Text(
              'Cancel',
              style: ThemeUtil.bodyMedium.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Global.gapMd,
        Expanded(
          flex: 2,
          child: LoadingButton(
            text: 'Create Provider',
            onPressed: _create,
            isLoading: _isCreating,
          ),
        ),
      ],
    ),
  );

  void _create() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isCreating = true);
      
      // Simulate creation process
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        final now = DateTime.now();
        final provider = Provider(
          id: now.millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          iconName: _selectedIcon,
          creationDatetime: now,
        );
        widget.onProviderAdded?.call(provider);
        AppToast.success(context, 'Provider created successfully');
        context.pop();
      }
    }
  }
}