import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../model/provider_model.dart';
import '../../styles/global.dart';
import '../../util/theme_util.dart';
import '../../util/extensions_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/form_field.dart' as custom_form;
import '../../widget/icon_selector_field.dart';
import '../../widget/loading_button.dart';
import '../../widget/app_toast.dart';
import '../../sandbox/util/database_util.dart';
import '../../sandbox/util/constant_util.dart';

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
      title: AppLocalizations.of(context).newProvider,
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
        AppLocalizations.of(context).createNewProvider,
        style: ThemeUtil.titleLarge.copyWith(
          color: context.colorScheme.onSurface,
        ),
      ),
      Global.gapSm,
      Text(
        AppLocalizations.of(context).addNewFinancialServiceProvider,
        style: ThemeUtil.bodyMedium.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.4,
        ),
      ),
    ],
  );

  Widget _buildNameField() => custom_form.FormField(
    label: AppLocalizations.of(context).providerName,
    controller: _nameController,
    icon: Icons.business,
    hintText: AppLocalizations.of(context).enterProviderName,
    required: true,
    validator: (value) => value?.trim().isEmpty == true
        ? AppLocalizations.of(context).thisFieldIsRequired
        : null,
  );

  Widget _buildDescriptionField() => custom_form.FormField(
  label: AppLocalizations.of(context).description,
  controller: _descriptionController,
  icon: Icons.description,
  hintText: AppLocalizations.of(context).enterDescription,
  maxLines: 4,
  required: false,
  validator: null,
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
          child: LoadingButton(
            text: AppLocalizations.of(context).cancel,
            onPressed: () => GoRouter.of(context).pop(),
            isLoading: false,
            isOutlined: true,
          ),
        ),
        Global.gapMd,
        Expanded(
          flex: 2,
          child: LoadingButton(
            text: AppLocalizations.of(context).createProvider,
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
      final now = DateTime.now();
      final provider = Provider(
        id: now.millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        iconName: _selectedIcon,
        creationDatetime: now,
      );
      final db = DatabaseUtil();
      await db.insert(ConstantUtil.tableProviders, Provider.toMap(provider));
      widget.onProviderAdded?.call(provider);
      if (mounted) {
        AppToast.success(
          context,
          AppLocalizations.of(context).providerCreatedSuccessfully,
        );
        GoRouter.of(context).pop(provider);
      }
    }
  }
}
