import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../data/app_database.dart';
import '../../data/fee_table_service.dart';
import '../../l10n/app_localizations.dart';
import '../../provider/locale_provider.dart';
import '../../provider/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../../util/date_label.dart';
import '../../util/navigation_util.dart';
import '../../util/preference_util.dart';
import '../../widget/common.dart';
import '../../widget/feezer_logo.dart';
import '../providers/fee_update_flow.dart';
import 'language_picker.dart';

/// Settings tab.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _version;
  DateTime? _lastCheck;

  @override
  void initState() {
    super.initState();
    AppDatabase.changes.addListener(_loadLastCheck);
    _loadLastCheck();
    PackageInfo.fromPlatform()
        .then((info) {
          if (mounted) setState(() => _version = info.version);
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    AppDatabase.changes.removeListener(_loadLastCheck);
    super.dispose();
  }

  Future<void> _loadLastCheck() async {
    final date = await FeeTableService.lastCheck();
    if (mounted) setState(() => _lastCheck = date);
  }

  void _push(String route) => Navigator.of(context).pushNamed(route);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final current = localeProvider.currentSupportedLocale;
    final checked = _lastCheck;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.page,
            Space.xl,
            Space.page,
            Space.xxl,
          ),
          children: [
            Text(l10n.settings, style: context.text.headlineMedium),
            Space.gapXl,
            SectionLabel(l10n.appearance),
            SectionCard(
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<AppThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: AppThemeMode.light,
                      icon: const Icon(Icons.light_mode_outlined),
                      label: Text(l10n.light),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      icon: const Icon(Icons.dark_mode_outlined),
                      label: Text(l10n.dark),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.system,
                      icon: const Icon(Icons.brightness_auto_outlined),
                      label: Text(l10n.system),
                    ),
                  ],
                  selected: {themeProvider.themeMode},
                  onSelectionChanged: (value) =>
                      themeProvider.setThemeMode(value.first),
                ),
              ),
            ),
            Space.gapMd,
            MenuGroup(
              children: [
                MenuRow(
                  icon: Icons.translate_rounded,
                  title: l10n.language,
                  subtitle: current?.nativeName ?? l10n.system,
                  onTap: () => showLanguagePicker(context),
                ),
              ],
            ),
            Space.gapXl,
            SectionLabel(l10n.feesSection),
            MenuGroup(
              children: [
                MenuRow(
                  icon: Icons.sync_rounded,
                  title: l10n.updateFeesTitle,
                  subtitle: checked == null
                      ? l10n.feesNeverChecked
                      : l10n.feesCheckedOn(context.date(checked)),
                  onTap: () async {
                    await runFeeUpdate(context);
                    await _loadLastCheck();
                  },
                ),
                MenuRow(
                  icon: Icons.import_export_rounded,
                  title: l10n.importExportData,
                  subtitle: l10n.importExportSubtitle,
                  onTap: () => _push(NavigationUtil.dataRoute),
                ),
              ],
            ),
            Space.gapXl,
            SectionLabel(l10n.about),
            MenuGroup(
              children: [
                MenuRow(
                  icon: Icons.help_outline_rounded,
                  title: l10n.helpAndSupport,
                  subtitle: l10n.faqAndContact,
                  onTap: () => _push(NavigationUtil.helpRoute),
                ),
                MenuRow(
                  icon: Icons.description_outlined,
                  title: l10n.termsOfUse,
                  onTap: () => _push(NavigationUtil.termsRoute),
                ),
                MenuRow(
                  icon: Icons.replay_rounded,
                  title: l10n.replayIntroduction,
                  onTap: () => _push(NavigationUtil.onboardingRoute),
                ),
              ],
            ),
            Space.gapXxl,
            Column(
              children: [
                // Tap the logo to watch it assemble again.
                const AnimatedFeezerMark(size: 36),
                Space.gapSm,
                Text('Feezer', style: context.text.titleSmall),
                Text(
                  _version == null ? '' : l10n.versionLabel(_version!),
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
