import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../model/fee_operation.dart';
import '../../theme/app_theme.dart';
import '../../util/csv_util.dart';
import '../../util/grid_labels.dart';
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
              Text(
                l10n.importedProvidersAndFees(
                  result.providersCount,
                  result.feeIntervalsCount,
                ),
              ),
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
    final columns = CsvUtil.headers(_locale);
    showAppSheet<void>(
      context,
      title: l10n.csvFormat,
      builder: (sheetContext) {
        const mono = TextStyle(fontFamily: 'monospace', fontSize: 13);
        Widget value(String key, String label) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(child: Text(key, style: mono)),
              Text(label, style: sheetContext.text.bodySmall),
            ],
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.csvFormatRows, style: sheetContext.text.bodyMedium),
            Space.gapLg,
            // Values of the operation and fee type columns.
            SectionLabel(columns[7]),
            for (final operation in FeeOperation.values)
              value(operation.key, GridLabels.operation(l10n, operation)),
            Space.gapLg,
            SectionLabel(columns[6]),
            value('fixed', l10n.fixedAmount),
            value('percentage', l10n.percentage),
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
                  style: mono.copyWith(fontSize: 12.5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Actions show a spinner while they run.
    Widget status(_Busy kind) => _busy == kind
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          )
        : const SizedBox.shrink();

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
          MenuGroup(
            children: [
              MenuRow(
                icon: Icons.save_alt_rounded,
                title: l10n.exportData,
                trailing: status(_Busy.export),
                onTap: _export,
              ),
            ],
          ),
          Space.gapXl,
          SectionLabel(l10n.importData),
          MenuGroup(
            children: [
              MenuRow(
                icon: Icons.folder_open_rounded,
                title: l10n.chooseCsvFile,
                trailing: status(_Busy.importFile),
                onTap: _importFile,
              ),
              MenuRow(
                icon: Icons.content_paste_rounded,
                title: l10n.pasteCsv,
                trailing: status(_Busy.importText),
                onTap: _importText,
              ),
            ],
          ),
          Space.gapXl,
          SectionLabel(l10n.csvTemplate),
          MenuGroup(
            children: [
              MenuRow(
                icon: Icons.file_download_outlined,
                title: l10n.downloadTemplate,
                trailing: status(_Busy.template),
                onTap: _template,
              ),
              MenuRow(
                icon: Icons.table_chart_outlined,
                title: l10n.csvFormat,
                trailing: const SizedBox.shrink(),
                onTap: _showFormat,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
