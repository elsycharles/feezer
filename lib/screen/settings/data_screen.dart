import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../util/csv_util.dart';
import '../../widget/app_toast.dart';
import '../../widget/common.dart';

/// CSV import and export of providers and fee grids.
class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

enum _Busy { none, export, importFile, importText, template }

class _DataScreenState extends State<DataScreen> {
  _Busy _busy = _Busy.none;

  String get _locale => Localizations.localeOf(context).languageCode;

  Future<void> _run(_Busy kind, Future<void> Function() action) async {
    if (_busy != _Busy.none) return;
    setState(() => _busy = kind);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = _Busy.none);
    }
  }

  Future<void> _save(String content, String fileName) async {
    final l10n = AppLocalizations.of(context);
    try {
      final bytes = Uint8List.fromList(utf8.encode('﻿$content'));
      final uri = await FilePicker.saveFile(
        dialogTitle: l10n.chooseWhereToSave,
        fileName: fileName,
        mimeType: 'text/csv',
        bytes: bytes,
      );
      if (uri != null && mounted) {
        AppToast.success(context, l10n.fileSavedSuccessfully);
      }
    } catch (_) {
      if (mounted) AppToast.error(context, l10n.failedToSaveFile);
    }
  }

  Future<void> _export() => _run(_Busy.export, () async {
    final l10n = AppLocalizations.of(context);
    try {
      final export = await CsvUtil.buildExport(locale: _locale);
      if (!mounted) return;
      if (export.providers == 0) {
        AppToast.info(context, l10n.noDataToExport);
        return;
      }
      final date = DateTime.now().toIso8601String().substring(0, 10);
      await _save(export.csv, 'feezer_$date.csv');
    } catch (e) {
      if (mounted) AppToast.error(context, l10n.exportFailed('$e'));
    }
  });

  Future<void> _importFile() => _run(_Busy.importFile, () async {
    final l10n = AppLocalizations.of(context);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );
      if (files.isEmpty || !mounted) return;
      final content = CsvUtil.decodeBytes(await files.first.readAsBytes());
      await _import(content);
    } catch (e) {
      if (mounted) AppToast.error(context, l10n.importFailed('$e'));
    }
  });

  Future<void> _importText() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final text = await showAppSheet<String>(
      context,
      title: l10n.pasteCsv,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            minLines: 6,
            maxLines: 12,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            decoration: InputDecoration(
              hintText: CsvUtil.headers(_locale).join(','),
            ),
          ),
          Space.gapLg,
          AppButton(
            label: l10n.importData,
            icon: Icons.upload_rounded,
            onPressed: () => Navigator.of(sheetContext).pop(controller.text),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || !mounted) return;
    if (text.trim().isEmpty) {
      AppToast.warning(context, l10n.csvContentCannotBeEmpty);
      return;
    }
    await _run(_Busy.importText, () => _import(text));
  }

  Future<void> _import(String content) async {
    final l10n = AppLocalizations.of(context);
    final result = await CsvUtil.importFromCsv(content, l10n);
    if (!mounted) return;
    if (!result.success && result.errors.isEmpty) {
      AppToast.error(context, result.message ?? l10n.importFailed(''));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          result.success
              ? Icons.check_circle_rounded
              : Icons.error_outline_rounded,
          color: result.success
              ? dialogContext.palette.success
              : dialogContext.colors.error,
          size: 40,
        ),
        title: Text(
          result.success ? l10n.importSuccessful : l10n.importFailed(''),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.providersImported(result.providersCount)),
              Text(l10n.feeIntervalsImported(result.feeIntervalsCount)),
              if (result.errors.isNotEmpty) ...[
                Space.gapMd,
                Text(
                  l10n.errorsEncountered(result.errors.length),
                  style: dialogContext.text.titleSmall,
                ),
                Space.gapSm,
                for (final error in result.errors.take(20))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $error',
                      style: dialogContext.text.bodySmall,
                    ),
                  ),
                if (result.errors.length > 20)
                  Text('…', style: dialogContext.text.bodySmall),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 44)),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _template() => _run(
    _Busy.template,
    () => _save(CsvUtil.getImportTemplate(_locale), 'feezer_template.csv'),
  );

  void _showFormat() {
    final l10n = AppLocalizations.of(context);
    showAppSheet<void>(
      context,
      title: l10n.csvFormat,
      builder: (sheetContext) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.csvFormatHelp, style: sheetContext.text.bodyMedium),
          Space.gapLg,
          Container(
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: sheetContext.colors.surfaceContainer,
              borderRadius: BorderRadius.circular(Space.radiusSm),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                CsvUtil.getImportTemplate(_locale),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget block({
      required IconData icon,
      required String title,
      required String body,
      required List<Widget> actions,
    }) => SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: context.colors.onSurfaceVariant),
              Space.gapMd,
              Expanded(child: Text(title, style: context.text.titleMedium)),
            ],
          ),
          Space.gapSm,
          Text(body, style: context.text.bodySmall),
          Space.gapLg,
          ...actions,
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.importExportData)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Space.page,
          Space.sm,
          Space.page,
          Space.xxl,
        ),
        children: [
          block(
            icon: Icons.download_rounded,
            title: l10n.exportData,
            body: l10n.exportDataDescription,
            actions: [
              AppButton(
                label: l10n.exportData,
                icon: Icons.save_alt_rounded,
                loading: _busy == _Busy.export,
                onPressed: _export,
              ),
            ],
          ),
          Space.gapLg,
          block(
            icon: Icons.upload_rounded,
            title: l10n.importData,
            body: l10n.importDataDescription,
            actions: [
              AppButton(
                label: l10n.chooseCsvFile,
                icon: Icons.folder_open_rounded,
                loading: _busy == _Busy.importFile,
                onPressed: _importFile,
              ),
              Space.gapSm,
              AppButton(
                label: l10n.pasteCsv,
                icon: Icons.content_paste_rounded,
                style: AppButtonStyle.outlined,
                loading: _busy == _Busy.importText,
                onPressed: _importText,
              ),
            ],
          ),
          Space.gapLg,
          block(
            icon: Icons.table_chart_outlined,
            title: l10n.csvTemplate,
            body: l10n.csvTemplateDescription,
            actions: [
              AppButton(
                label: l10n.downloadTemplate,
                icon: Icons.file_download_outlined,
                style: AppButtonStyle.tonal,
                loading: _busy == _Busy.template,
                onPressed: _template,
              ),
              Space.gapSm,
              AppButton(
                label: l10n.csvFormat,
                icon: Icons.visibility_outlined,
                style: AppButtonStyle.text,
                onPressed: _showFormat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
