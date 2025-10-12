import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../../util/csv_util.dart';
import '../../util/navigation_util.dart';
import '../../util/theme_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/app_toast.dart';
import '../../widget/surface_card.dart';
import '../../widget/interactive_surface.dart';
import '../../l10n/app_localizations.dart';
import '../../provider/locale_provider.dart';
import '../../provider/currency_provider.dart';
import '../../styles/global.dart';

class CsvManagementScreen extends StatefulWidget {
  const CsvManagementScreen({super.key});

  @override
  State<CsvManagementScreen> createState() => _CsvManagementScreenState();
}

class _CsvManagementScreenState extends State<CsvManagementScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: AppLocalizations.of(context).importExportData,
        menuExcludeRoutes: [NavigationUtil.csvManagementRoute],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoCard(),
                  Global.gapLg,
                  _DataManagementSection(
                    isProcessing: _isProcessing,
                    onImport: _showImportDialog,
                    onExport: _exportCsv,
                  ),
                  Global.gapLg,
                  _TemplatesSection(
                    isProcessing: _isProcessing,
                    onPreview: _previewTemplate,
                    onDownload: _downloadTemplate,
                  ),
                ],
              ),
            ),
            if (_isProcessing) _LoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Future<void> _showImportDialog() async {
    await showDialog(
      context: context,
      builder: (dialogContext) => _ImportDialog(
        onFileImport: (file) => _importCsvFromFile(file),
        onTextImport: (text) => _importFromText(text),
      ),
    );
  }

  Future<void> _importCsvFromFile(PlatformFile file) async {
    try {
      if (file.bytes == null && file.path == null) {
        if (mounted) {
          /* Lines 85-86 omitted */
        }
        return;
      }

      setState(() => _isProcessing = true);

      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );
      final localizations = AppLocalizations.of(context);

      // Lire le contenu du fichier
      final csvContent = file.bytes != null
          ? String.fromCharCodes(file.bytes!)
          : await File(file.path!).readAsString();

      final importResult = await CsvUtil.importFromCsv(
        csvContent,
        currencyProvider,
        createCsvLocalizations(localizations),
      );

      setState(() => _isProcessing = false);

      if (!mounted) return;

      if (importResult.success) {
        _showImportResultDialog(importResult);
      } else {
        AppToast.error(
          context,
          importResult.message ?? AppLocalizations.of(context).importFailed(''),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        AppToast.error(
          context,
          '${AppLocalizations.of(context).importFailed}: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _importFromText(String csvText) async {
    if (csvText.trim().isEmpty) {
      if (mounted) {
        AppToast.error(
          context,
          AppLocalizations.of(context).csvContentCannotBeEmpty,
        );
      }
      return;
    }

    final localizations = AppLocalizations.of(context);

    try {
      setState(() => _isProcessing = true);

      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );
      final importResult = await CsvUtil.importFromCsv(
        csvText,
        currencyProvider,
        createCsvLocalizations(localizations),
      );

      setState(() => _isProcessing = false);

      if (!mounted) return;

      if (importResult.success) {
        _showImportResultDialog(importResult);
      } else {
        AppToast.error(
          context,
          importResult.message ?? localizations.importFailed(''),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        AppToast.error(
          context,
          '${localizations.importFailed}: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _exportCsv() async {
    final localizations = AppLocalizations.of(context);

    try {
      setState(() => _isProcessing = true);

      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final locale = localeProvider.locale?.languageCode ?? 'en';
      final currencyProvider = Provider.of<CurrencyProvider>(
        context,
        listen: false,
      );

      final exportResult = await CsvUtil.exportToCsv(
        locale: locale,
        currencyProvider: currencyProvider,
        localizations: createCsvLocalizations(localizations),
      );

      setState(() => _isProcessing = false);

      if (!mounted) return;

      if (exportResult.success && exportResult.filePath != null) {
        await _saveFileToUserLocation(
          exportResult.filePath!,
          'fee_minimizer_export_${DateTime.now().millisecondsSinceEpoch}.csv',
        );
      } else {
        AppToast.error(
          context,
          exportResult.message ?? localizations.exportFailed(''),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        AppToast.error(
          context,
          '${localizations.exportFailed}: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _downloadTemplate() async {
    final localizations = AppLocalizations.of(context);

    try {
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final locale = localeProvider.locale?.languageCode ?? 'en';

      final template = CsvUtil.getImportTemplate(locale);

      // Create temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${directory.path}/template_$timestamp.csv');
      await tempFile.writeAsString(template);

      // Save with suggested name
      await _saveFileToUserLocation(
        tempFile.path,
        'fee_minimizer_template.csv',
      );
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          '${localizations.failedToDownloadTemplate}: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _saveFileToUserLocation(
    String sourceFilePath,
    String suggestedName,
  ) async {
    final localizations = AppLocalizations.of(context);

    try {
      // Get localized string before async operation
      final chooseWhereToSaveText = localizations.chooseWhereToSave;

      // Read source file
      final sourceFile = File(sourceFilePath);
      final bytes = await sourceFile.readAsBytes();

      // Save with FilePicker (handles permissions automatically)
      final result = await FilePicker.platform.saveFile(
        dialogTitle: chooseWhereToSaveText,
        fileName: suggestedName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
        bytes: bytes, // IMPORTANT: Passer les bytes sur mobile
      );

      if (result != null) {
        if (mounted) {
          AppToast.success(context, localizations.fileSavedSuccessfully);
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          '${localizations.failedToSaveFile}: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _previewTemplate() async {
    final localizations = AppLocalizations.of(context);

    try {
      final localeProvider = Provider.of<LocaleProvider>(
        context,
        listen: false,
      );
      final locale = localeProvider.locale?.languageCode ?? 'en';

      final template = CsvUtil.getImportTemplate(locale);

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (context) =>
            _PreviewDialog(template: template, onDownload: _downloadTemplate),
      );
    } catch (e) {
      if (mounted) {
        AppToast.error(context, localizations.failedToPreviewTemplate);
      }
    }
  }

  void _showImportResultDialog(CsvResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ImportResultDialog(result: result),
    );
  }
}

// ============================================================================
// REUSABLE COMPONENTS
// ============================================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SurfaceCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          Global.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).csvImportExportInfo,
                  style: ThemeUtil.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).csvImportExportDescription,
                  style: ThemeUtil.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DataManagementSection extends StatelessWidget {
  const _DataManagementSection({
    required this.isProcessing,
    required this.onImport,
    required this.onExport,
  });

  final bool isProcessing;
  final VoidCallback onImport;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.import_export,
                size: 20,
                color: ThemeUtil.primaryColor,
              ),
              Global.gapSm,
              Text(
                AppLocalizations.of(context).dataManagement,
                style: ThemeUtil.titleMedium.copyWith(
                  color: ThemeUtil.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SurfaceCard(
          padding: Global.padMd,
          child: Column(
            children: [
              _ActionTile(
                title: AppLocalizations.of(context).importData,
                subtitle: AppLocalizations.of(context).importDataDescription,
                icon: Icons.file_upload_outlined,
                onTap: isProcessing ? null : onImport,
              ),
              _ActionTile(
                title: AppLocalizations.of(context).exportData,
                subtitle: AppLocalizations.of(context).exportDataDescription,
                icon: Icons.file_download_outlined,
                onTap: isProcessing ? null : onExport,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveSurface(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      builder: (context, hovered, pressed) => ListTile(
        leading: Icon(icon, color: ThemeUtil.primaryColor),
        title: Text(
          title,
          style: ThemeUtil.bodyLarge.copyWith(color: colorScheme.onSurface),
        ),
        subtitle: Text(
          subtitle,
          style: ThemeUtil.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
        ),
        enabled: onTap != null,
      ),
    );
  }
}

class _TemplatesSection extends StatelessWidget {
  const _TemplatesSection({
    required this.isProcessing,
    required this.onPreview,
    required this.onDownload,
  });

  final bool isProcessing;
  final VoidCallback onPreview;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 20,
                color: ThemeUtil.primaryColor,
              ),
              Global.gapSm,
              Text(
                AppLocalizations.of(context).templates,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ThemeUtil.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: _TemplateTile(
            isProcessing: isProcessing,
            onPreview: onPreview,
            onDownload: onDownload,
          ),
        ),
      ],
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.isProcessing,
    required this.onPreview,
    required this.onDownload,
  });

  final bool isProcessing;
  final VoidCallback onPreview;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.merge_type, color: colorScheme.onSurface, size: 22),
            Global.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).downloadCombinedTemplate,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).csvTemplateForCombined,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: isProcessing ? null : onPreview,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: Text(AppLocalizations.of(context).preview),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ThemeUtil.getPrimaryColor(context)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Global.radiusSm),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: isProcessing ? null : onDownload,
              icon: const Icon(Icons.download_outlined, size: 18),
              label: Text(AppLocalizations.of(context).download),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Global.radiusSm),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface.withValues(alpha: 0.8),
      child: Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
    );
  }
}

// ============================================================================
// DIALOGUES
// ============================================================================

class _ImportDialog extends StatefulWidget {
  const _ImportDialog({required this.onFileImport, required this.onTextImport});

  final void Function(PlatformFile) onFileImport;
  final void Function(String) onTextImport;

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  bool _useTextInput = false;
  String _csvText = '';
  bool _isImporting = false;
  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 600,
          minWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogHeader(
                  icon: Icons.import_export,
                  title: AppLocalizations.of(context).importData,
                ),
                const SizedBox(height: 24),
                _ImportModeToggle(
                  useTextInput: _useTextInput,
                  onToggle: (value) => setState(() => _useTextInput = value),
                ),
                const SizedBox(height: 24),
                _ImportContent(
                  useTextInput: _useTextInput,
                  selectedFile: _selectedFile,
                  onTextChanged: (value) => _csvText = value,
                  onFileSelected: _selectFile,
                ),
                const SizedBox(height: 24),
                _ImportActions(
                  isImporting: _isImporting,
                  canImport: _useTextInput
                      ? _csvText.trim().isNotEmpty
                      : _selectedFile != null,
                  onCancel: () => Navigator.of(context).pop(),
                  onImport: _handleImport,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          AppLocalizations.of(context).failedToSelectFile,
        );
      }
    }
  }

  Future<void> _handleImport() async {
    setState(() => _isImporting = true);

    try {
      Navigator.of(context).pop();
      if (_useTextInput) {
        widget.onTextImport(_csvText);
      } else {
        if (_selectedFile != null) {
          widget.onFileImport(_selectedFile!);
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          AppLocalizations.of(context).importFailed(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: ThemeUtil.titleLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImportModeToggle extends StatelessWidget {
  const _ImportModeToggle({required this.useTextInput, required this.onToggle});

  final bool useTextInput;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              icon: Icons.file_upload_outlined,
              label: AppLocalizations.of(context).file,
              isSelected: !useTextInput,
              onTap: () => onToggle(false),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ToggleOption(
              icon: Icons.edit_note_outlined,
              label: AppLocalizations.of(context).text,
              isSelected: useTextInput,
              onTap: () => onToggle(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? ThemeUtil.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? ThemeUtil.textLight
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: ThemeUtil.bodyMedium.copyWith(
                color: isSelected
                    ? ThemeUtil.textLight
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportContent extends StatelessWidget {
  const _ImportContent({
    required this.useTextInput,
    required this.selectedFile,
    required this.onTextChanged,
    required this.onFileSelected,
  });

  final bool useTextInput;
  final PlatformFile? selectedFile;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onFileSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: useTextInput
          ? _TextInputField(onChanged: onTextChanged)
          : _FileUploadArea(
              selectedFile: selectedFile,
              onFileSelected: onFileSelected,
            ),
    );
  }
}

class _TextInputField extends StatelessWidget {
  const _TextInputField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      key: const ValueKey('text_input'),
      maxLines: 10,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).pasteCsvContentHere,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.all(16),
      ),
      style: ThemeUtil.bodyMedium.copyWith(color: colorScheme.onSurface),
      onChanged: onChanged,
    );
  }
}

class _FileUploadArea extends StatelessWidget {
  const _FileUploadArea({
    required this.selectedFile,
    required this.onFileSelected,
  });

  final PlatformFile? selectedFile;
  final VoidCallback onFileSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onFileSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: selectedFile != null
              ? ThemeUtil.success.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedFile != null
                ? ThemeUtil.success
                : colorScheme.outline.withValues(alpha: 0.3),
            width: selectedFile != null ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (selectedFile != null) ...[
              Icon(Icons.check_circle, size: 48, color: ThemeUtil.success),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).fileSelected,
                style: ThemeUtil.titleMedium.copyWith(
                  color: ThemeUtil.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        selectedFile!.name,
                        style: ThemeUtil.bodyMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatFileSize(selectedFile!.size),
                      style: ThemeUtil.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Icon(
                Icons.file_upload_outlined,
                size: 48,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).clickImportToSelectFile,
                style: ThemeUtil.bodyMedium.copyWith(
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  AppLocalizations.of(context).csvFilesOnly,
                  style: ThemeUtil.bodySmall.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _ImportActions extends StatelessWidget {
  const _ImportActions({
    required this.isImporting,
    required this.canImport,
    required this.onCancel,
    required this.onImport,
  });

  final bool isImporting;
  final bool canImport;
  final VoidCallback onCancel;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isImporting ? null : onCancel,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.outline),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).cancel,
              style: ThemeUtil.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FilledButton(
            onPressed: canImport && !isImporting ? onImport : null,
            style: FilledButton.styleFrom(
              backgroundColor: canImport && !isImporting
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.12),
              foregroundColor: canImport && !isImporting
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withValues(alpha: 0.38),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: colorScheme.onSurface.withValues(
                alpha: 0.12,
              ),
              disabledForegroundColor: colorScheme.onSurface.withValues(
                alpha: 0.38,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isImporting
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Center(
                      key: ValueKey('text'),
                      child: Text(
                        AppLocalizations.of(context).importData,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImportResultDialog extends StatelessWidget {
  const _ImportResultDialog({required this.result});

  final CsvResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ResultHeader(success: result.success),
            const SizedBox(height: 16),
            _ResultContent(result: result),
            const SizedBox(height: 24),
            _ResultActions(),
          ],
        ),
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({required this.success});

  final bool success;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: success
                ? ThemeUtil.success.withValues(alpha: 0.1)
                : colorScheme.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? ThemeUtil.success : colorScheme.error,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            success
                ? AppLocalizations.of(context).importSuccessful
                : AppLocalizations.of(context).importFailed(''),
            style: ThemeUtil.titleMedium.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.result});

  final CsvResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.message != null) ...[
          Text(
            result.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (result.providersCount > 0)
          _ResultItem(
            icon: Icons.business,
            text: AppLocalizations.of(
              context,
            ).providersImported(result.providersCount),
            color: ThemeUtil.info,
          ),
        if (result.feeIntervalsCount > 0)
          _ResultItem(
            icon: Icons.attach_money,
            text: AppLocalizations.of(
              context,
            ).feeIntervalsImported(result.feeIntervalsCount),
            color: ThemeUtil.success,
          ),
        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ErrorsCard(errors: result.errors),
        ],
      ],
    );
  }
}

class _ResultItem extends StatelessWidget {
  const _ResultItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          Global.gapSm,
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _ErrorsCard extends StatelessWidget {
  const _ErrorsCard({required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: ThemeUtil.warning, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).errorsEncountered(errors.length),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: ThemeUtil.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: errors
                    .map(
                      (error) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $error',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultActions extends StatelessWidget {
  const _ResultActions();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Global.radiusSm),
          ),
        ),
        child: Text(AppLocalizations.of(context).confirm),
      ),
    );
  }
}

class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog({required this.template, required this.onDownload});

  final String template;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogHeader(
                  icon: Icons.description,
                  title: AppLocalizations.of(context).templatePreview,
                ),
                const SizedBox(height: 16),
                _PreviewContent(template: template),
                const SizedBox(height: 24),
                _PreviewActions(template: template, onDownload: onDownload),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewContent extends StatelessWidget {
  const _PreviewContent({required this.template});

  final String template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).csvContentPreview,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 300, // Fixed height for preview content
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              template,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: ThemeUtil.fontSizeLabelSmall,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewActions extends StatelessWidget {
  const _PreviewActions({required this.template, required this.onDownload});

  final String template;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Global.radiusSm),
                  ),
                ),
                child: Text(AppLocalizations.of(context).close),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: template));
                  if (context.mounted) {
                    AppToast.success(
                      context,
                      AppLocalizations.of(context).copiedToClipboard,
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 18),
                label: Text(AppLocalizations.of(context).copy),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Global.radiusSm),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              onDownload();
            },
            icon: const Icon(Icons.download, size: 18),
            label: Text(AppLocalizations.of(context).download),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Global.radiusSm),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
