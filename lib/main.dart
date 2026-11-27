import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'data/default_data.dart';
import 'l10n/app_localizations.dart';
import 'l10n/localization_delegate.dart';
import 'model/provider_model.dart' as model;
import 'provider/locale_provider.dart';
import 'provider/theme_provider.dart';
import 'screen/home/home_shell.dart';
import 'screen/onboarding/onboarding_screen.dart';
import 'screen/providers/provider_detail_screen.dart';
import 'screen/settings/data_screen.dart';
import 'screen/settings/help_screen.dart';
import 'screen/settings/terms_screen.dart';
import 'screen/splash/launch_splash.dart';
import 'theme/app_theme.dart';
import 'util/constant_util.dart';
import 'util/navigation_util.dart';
import 'util/preference_util.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The launch animation shows from the first frame; the app gets ready
  // meanwhile, then appears below it.
  runApp(
    LaunchSplash<Startup>(
      ready: Startup.load(),
      builder: (context, startup) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: startup.theme),
          ChangeNotifierProvider.value(value: startup.locale),
        ],
        child: FeezerApp(initialRoute: startup.initialRoute),
      ),
    ),
  );
}

/// What the app needs before its first screen.
class Startup {
  const Startup(this.theme, this.locale, this.initialRoute);

  final ThemeProvider theme;
  final LocaleProvider locale;
  final String initialRoute;

  /// Reads the preferences and installs the bundled fee grids. A failure
  /// never blocks the launch: the app opens with what it has.
  static Future<Startup> load() async {
    final theme = ThemeProvider();
    final locale = LocaleProvider();
    Future<void> safely(Future<void> Function() task, String what) async {
      try {
        await task();
      } catch (e) {
        debugPrint('Startup: $what failed: $e');
      }
    }

    await Future.wait([
      safely(theme.initializeTheme, 'theme'),
      safely(locale.initializeLocale, 'language'),
      safely(DefaultData.ensureSeeded, 'fee grids'),
    ]);
    var firstLaunch = false;
    await safely(() async {
      firstLaunch = await PreferenceUtil.isFirstLaunch();
    }, 'first launch');
    return Startup(
      theme,
      locale,
      firstLaunch ? NavigationUtil.onboardingRoute : NavigationUtil.homeRoute,
    );
  }
}

class FeezerApp extends StatelessWidget {
  const FeezerApp({super.key, required this.initialRoute});

  final String initialRoute;

  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    Widget? page;
    switch (settings.name) {
      case NavigationUtil.homeRoute:
        page = HomeShell(key: NavigationUtil.shellKey);
      case NavigationUtil.onboardingRoute:
        page = const OnboardingScreen();
      case NavigationUtil.providerDetailRoute:
        final provider = settings.arguments;
        if (provider is model.Provider) {
          page = ProviderDetailScreen(provider: provider);
        }
      case NavigationUtil.dataRoute:
        page = const DataScreen();
      case NavigationUtil.helpRoute:
        page = const HelpScreen();
      case NavigationUtil.termsRoute:
        page = const TermsScreen();
    }
    return page == null
        ? null
        : MaterialPageRoute<void>(builder: (_) => page!, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select<ThemeProvider, ThemeMode>(
      (p) => p.flutterThemeMode,
    );
    final locale = context.select<LocaleProvider, Locale?>((p) => p.locale);
    return MaterialApp(
      title: ConstantUtil.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        builder: (_) => HomeShell(key: NavigationUtil.shellKey),
        settings: settings,
      ),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
        FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.3),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
