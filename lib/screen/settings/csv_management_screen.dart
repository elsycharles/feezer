import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../util/csv_util.dart';
import '../../util/navigation_util.dart';
import '../../util/theme_util.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/app_toast.dart';
import '../../widget/surface_card.dart';
import '../../widget/interactive_surface.dart';
import '../../l10n/app_localizations.dart';
import '../../provider/locale_provider.dart';
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: custom.AppBar(
        title: AppLocalizations.of(context).importExportData,
        menuExcludeRoutes: [NavigationUtil.csvManagementRoute],
        borderRadius: 16,
        elevation: 2,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(context),
                  Global.gapLg,
                  _buildSection(
                    context,
                    AppLocalizations.of(context).dataManagement,
                    Icons.import_export,
                    [
                      _buildActionTile(
                        context,
                        AppLocalizations.of(context).importData,
                        AppLocalizations.of(context).importDataDescription,
                        Icons.file_upload_outlined,
                        _importCsv,
                      ),
                      _buildActionTile(
                        context,
                        AppLocalizations.of(context).exportData,
                        AppLocalizations.of(context).exportDataDescription,
                        Icons.file_download_outlined,
                        _exportCsv,
                      ),
                    ],
                  ),
                  Global.gapLg,
                  _buildTemplatesSection(context),
                ],
              ),
            ),
            if (_isProcessing)
              Container(
                color: colorScheme.surface.withValues(alpha: 0.8),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SurfaceCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: colorScheme.onPrimaryContainer,
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
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Global.gapSm,
                Text(
                  AppLocalizations.of(context).csvImportExportDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
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

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              Global.gapSm,
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SurfaceCard(
          padding: Global.padMd,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveSurface(
      onTap: _isProcessing ? null : onTap,
      borderRadius: BorderRadius.zero,
      builder: (context, hovered, pressed) => ListTile(
        leading: Icon(icon, color: colorScheme.onSurface),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: colorScheme.onSurfaceVariant,
        ),
        enabled: !_isProcessing,
      ),
    );
  }

  Widget _buildTemplatesSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.description_outlined, size: 20, color: colorScheme.primary),
              Global.gapSm,
              Text(
                AppLocalizations.of(context).templates,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: _buildTemplateTile(
            context,
            AppLocalizations.of(context).downloadCombinedTemplate,
            AppLocalizations.of(context).csvTemplateForCombined,
            Icons.merge_type,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.onSurface, size: 22),
              Global.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
                onPressed: _isProcessing ? null : _previewTemplate,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text(AppLocalizations.of(context).preview),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ThemeUtil.primaryColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Global.radiusSm),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _isProcessing ? null : _downloadTemplate,
                icon: const Icon(Icons.download_outlined, size: 18),
                label: Text(AppLocalizations.of(context).download),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Global.radiusSm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _importCsv() async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      if (file.bytes == null && file.path == null) {
        if (mounted) {
          AppToast.error(context, AppLocalizations.of(context).failedToReadFile);
        }
        return;
      }

      setState(() => _isProcessing = true);

      // Read file content
      String csvContent;
      if (file.bytes != null) {
        csvContent = String.fromCharCodes(file.bytes!);
      } else {
        csvContent = await File(file.path!).readAsString();
      }

      // Import data (auto-detect type)
      final importResult = await CsvUtil.importFromCsv(csvContent);

      setState(() => _isProcessing = false);

      if (!mounted) return;

      // Show result
      if (importResult.success) {
        _showImportResultDialog(importResult);
      } else {
        AppToast.error(context, importResult.message ?? AppLocalizations.of(context).importFailed);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        AppToast.error(context, '${AppLocalizations.of(context).importFailed}: ${e.toString()}');
      }
    }
  }

  Future<void> _exportCsv() async {
    try {
      setState(() => _isProcessing = true);

      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      final locale = localeProvider.locale?.languageCode ?? 'en';

      final exportResult = await CsvUtil.exportToCsv(locale: locale);

      setState(() => _isProcessing = false);

      if (!mounted) return;

      if (exportResult.success) {
        AppToast.success(
          context,
          exportResult.message ?? AppLocalizations.of(context).exportSuccessful,
        );
      } else {
        AppToast.error(
          context,
          exportResult.message ?? AppLocalizations.of(context).exportFailed,
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        AppToast.error(
          context,
          '${AppLocalizations.of(context).exportFailed}: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      final locale = localeProvider.locale?.languageCode ?? 'en';

      final template = CsvUtil.getImportTemplate(locale);

      // Save template file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'template_combined_$timestamp.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(template);

      // Share template
      await Share.shareXFiles([XFile(file.path)]);

      if (mounted) {
        AppToast.success(
          context,
          AppLocalizations.of(context).templateDownloaded,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          '${AppLocalizations.of(context).failedToDownloadTemplate}: ${e.toString()}',
        );
      }
    }
  }

  void _showImportResultDialog(CsvResult result) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildResultHeader(result, colorScheme),
              const SizedBox(height: 16),
              _buildResultContent(result, theme, colorScheme),
              const SizedBox(height: 24),
              _buildResultActions(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultHeader(CsvResult result, ColorScheme colorScheme) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: result.success
              ? Colors.green.withValues(alpha: 0.1)
              : colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          result.success ? Icons.check_circle : Icons.error,
          color: result.success ? Colors.green : colorScheme.error,
          size: 24,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          result.success
              ? AppLocalizations.of(context).importSuccessful
              : AppLocalizations.of(context).importFailed,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  Widget _buildResultContent(CsvResult result, ThemeData theme, ColorScheme colorScheme) => Column(
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
        _buildResultItem(
          context,
          Icons.business,
          AppLocalizations.of(context).providersImported(result.providersCount),
          Colors.blue,
        ),
      if (result.feeIntervalsCount > 0)
        _buildResultItem(
          context,
          Icons.attach_money,
          AppLocalizations.of(context).feeIntervalsImported(result.feeIntervalsCount),
          Colors.green,
        ),
      if (result.errors.isNotEmpty) ...[
        const SizedBox(height: 16),
        Container(
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
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).errorsEncountered(result.errors.length),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.orange,
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
                    children: result.errors.map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• $error',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );

  Widget _buildResultActions(BuildContext context, ColorScheme colorScheme) => Row(
    children: [
      Expanded(
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
      ),
    ],
  );

  Widget _buildResultItem(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          Global.gapSm,
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewHeader(ColorScheme colorScheme) => Row(
    children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.description,
          color: colorScheme.primary,
          size: 24,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          AppLocalizations.of(context).templatePreview,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );

  Widget _buildPreviewContent(String template, ColorScheme colorScheme) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CSV Content Preview:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPreviewActions(BuildContext context, ColorScheme colorScheme, String template) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: ThemeUtil.primaryColor),
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
                side: BorderSide(color: ThemeUtil.primaryColor),
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
            _downloadTemplate();
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

  Future<void> _previewTemplate() async {
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      final locale = localeProvider.locale?.languageCode ?? 'en';

      final template = CsvUtil.getImportTemplate(locale);

      if (!mounted) return;

      final colorScheme = Theme.of(context).colorScheme;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPreviewHeader(colorScheme),
                const SizedBox(height: 16),
                _buildPreviewContent(template, colorScheme),
                const SizedBox(height: 24),
                _buildPreviewActions(context, colorScheme, template),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Failed to preview template: $e');
      }
    }
  }
}