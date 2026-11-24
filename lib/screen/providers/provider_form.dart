import 'package:flutter/material.dart';

import '../../data/provider_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../model/fee_operation.dart';
import '../../model/provider_model.dart';
import '../../theme/app_theme.dart';
import '../../util/grid_labels.dart';
import '../../util/icon_util.dart';
import '../../widget/app_toast.dart';
import '../../widget/common.dart';

/// Opens the grid form (operator + operation) in a bottom sheet. Returns the
/// saved grid.
Future<Provider?> showProviderForm(BuildContext context, {Provider? provider}) {
  final l10n = AppLocalizations.of(context);
  return showAppSheet<Provider>(
    context,
    title: provider == null ? l10n.newGrid : l10n.editGrid,
    builder: (_) => _ProviderForm(provider: provider),
  );
}

class _ProviderForm extends StatefulWidget {
  const _ProviderForm({this.provider});

  final Provider? provider;

  @override
  State<_ProviderForm> createState() => _ProviderFormState();
}

class _ProviderFormState extends State<_ProviderForm> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProviderRepository();
  late final _name = TextEditingController(text: widget.provider?.name ?? '');
  late final _description = TextEditingController(
    text: widget.provider?.description ?? '',
  );
  late String _icon = widget.provider?.iconName ?? 'phone_android';
  late FeeOperation? _operation = widget.provider == null
      ? FeeOperation.transferSame
      : widget.provider!.operation;
  List<Provider> _existing = const [];
  bool _saving = false;
  String? _duplicateError;

  bool get _isNew => widget.provider == null;

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
    _repository.getAll().then((grids) {
      if (mounted) setState(() => _existing = grids);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _onNameChanged() => setState(() => _duplicateError = null);

  /// Existing operators, to reuse their exact name and icon.
  List<Provider> get _operators {
    final seen = <String>{};
    return [
      for (final grid in _existing)
        if (seen.add(grid.operatorKey)) grid,
    ];
  }

  void _useOperator(Provider grid) {
    _name.text = grid.name;
    _name.selection = TextSelection.collapsed(offset: grid.name.length);
    setState(() => _icon = grid.iconName);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _duplicateError = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final name = _name.text.trim();
      final duplicate = await _repository.findByName(
        name,
        operation: _operation,
        excludeId: widget.provider?.id,
      );
      if (duplicate != null) {
        setState(() {
          _saving = false;
          _duplicateError = l10n.gridAlreadyExists(
            GridLabels.title(l10n, duplicate.name, duplicate.operation),
          );
        });
        return;
      }
      final base = widget.provider ?? Provider(id: '', name: name);
      final provider = base.copyWith(
        name: name,
        description: _description.text.trim(),
        iconName: _icon,
        operation: _operation,
      );
      final Provider saved;
      if (_isNew) {
        saved = await _repository.insert(provider);
      } else {
        await _repository.update(provider);
        saved = provider;
      }
      if (!mounted) return;
      AppToast.success(context, _isNew ? l10n.gridCreated : l10n.gridUpdated);
      Navigator.of(context).pop(saved);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppToast.error(context, l10n.failedToSaveChanges);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typed = _name.text.trim().toLowerCase();
    final suggestions = _operators
        .where((g) => g.operatorKey != typed)
        .toList();
    final branded = ProviderAvatar.brandColors(_name.text) != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.operatorName,
              hintText: l10n.providerNameHint,
            ),
            validator: (value) =>
                (value ?? '').trim().isEmpty ? l10n.thisFieldIsRequired : null,
          ),
          AnimatedSize(
            duration: Motion.medium,
            curve: Motion.curve,
            alignment: Alignment.topCenter,
            child: _isNew && suggestions.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: Space.md),
                    child: Wrap(
                      spacing: Space.sm,
                      runSpacing: Space.sm,
                      children: [
                        for (final grid in suggestions)
                          ChoicePill(
                            label: grid.name,
                            selected: false,
                            onTap: () => _useOperator(grid),
                            leading: ProviderAvatar(
                              name: grid.name,
                              iconName: grid.iconName,
                              size: 24,
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          Space.gapXl,
          Text(l10n.operationLabel, style: context.text.labelMedium),
          Space.gapSm,
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final operation in [...FeeOperation.values, null])
                ChoicePill(
                  label: GridLabels.operation(l10n, operation),
                  selected: operation == _operation,
                  onTap: () => setState(() {
                    _operation = operation;
                    _duplicateError = null;
                  }),
                ),
            ],
          ),
          AnimatedSize(
            duration: Motion.medium,
            curve: Motion.curve,
            alignment: Alignment.topCenter,
            child: _duplicateError == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: Space.md),
                    child: Text(
                      _duplicateError!,
                      style: context.text.bodySmall?.copyWith(
                        color: context.colors.error,
                      ),
                    ),
                  ),
          ),
          Space.gapXl,
          TextFormField(
            controller: _description,
            maxLines: 3,
            minLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.descriptionOptional),
          ),
          AnimatedSize(
            duration: Motion.medium,
            curve: Motion.curve,
            alignment: Alignment.topCenter,
            child: branded
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: Space.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.icon, style: context.text.labelMedium),
                        Space.gapSm,
                        Wrap(
                          spacing: Space.sm,
                          runSpacing: Space.sm,
                          children: [
                            for (final name in IconUtil.choices)
                              _IconChoice(
                                icon: IconUtil.getIcon(name),
                                selected: name == _icon,
                                onTap: () => setState(() => _icon = name),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
          Space.gapXl,
          AppButton(
            label: _isNew ? l10n.createGrid : l10n.saveChanges,
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(Space.radiusSm);
    return PressScale(
      scale: 0.92,
      child: AnimatedContainer(
        duration: Motion.medium,
        curve: Motion.curve,
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected ? colors.primaryContainer : colors.surfaceContainer,
          borderRadius: radius,
          border: Border.all(
            color: selected ? colors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Icon(
              icon,
              color: selected
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
