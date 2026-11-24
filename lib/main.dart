import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'data/app_database.dart';
import 'l10n/app_localizations.dart';
import 'l10n/localization_delegate.dart';
import 'model/currency_model.dart';
import 'model/fee_interval_model.dart';
import 'model/provider_model.dart' as model;
import 'provider/currency_provider.dart';
import 'provider/locale_provider.dart';
import 'provider/theme_provider.dart';
import 'screen/currency/currency_list_screen.dart';
import 'screen/currency/new_currency_screen.dart';
import 'screen/fee_interval/new_fee_interval_screen.dart';
import 'screen/help_support/help_support_screen.dart';
import 'screen/new_provider/new_provider_screen.dart';
import 'screen/onboarding/onboarding_screen.dart';
import 'screen/optimize_fee/optimize_fee_screen.dart';
import 'screen/provider_detail/provider_detail_screen.dart';
import 'screen/provider_list/provider_list_screen.dart';
import 'screen/settings/csv_management_screen.dart';
import 'screen/settings/settings_screen.dart';
import 'screen/terms_of_use/terms_of_use_screen.dart';
import 'util/constant_util.dart';
import 'util/navigation_util.dart';
import 'util/preference_util.dart';
import 'util/theme_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();
  final currencyProvider = CurrencyProvider();

  await Future.wait([
    themeProvider.initializeTheme(),
    localeProvider.initializeLocale(),
    currencyProvider.initializeCurrency(),
    AppDatabase.instance.seedDefaultData(),
  ]);
  final isFirstLaunch = await PreferenceUtil.isFirstLaunch();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: currencyProvider),
      ],
      child: FeezerApp(
        initialRoute: isFirstLaunch
            ? NavigationUtil.onboardingRoute
            : NavigationUtil.homeRoute,
      ),
    ),
  );
}

class FeezerApp extends StatelessWidget {
  const FeezerApp({super.key, required this.initialRoute});

  final String initialRoute;

  static final Map<String, WidgetBuilder> _routes = {
    NavigationUtil.homeRoute: (context) => OptimizeFeeScreen(
      defaultProvider:
          ModalRoute.of(context)?.settings.arguments as model.Provider?,
    ),
    NavigationUtil.onboardingRoute: (_) => const OnboardingScreen(),
    NavigationUtil.providersRoute: (_) => const ProviderListScreen(),
    NavigationUtil.settingsRoute: (_) => const SettingsScreen(),
    NavigationUtil.helpSupportRoute: (_) => const HelpSupportScreen(),
    NavigationUtil.termsOfUseRoute: (_) => const TermsOfUseScreen(),
    NavigationUtil.currenciesRoute: (_) => const CurrencyListScreen(),
    NavigationUtil.csvManagementRoute: (_) => const CsvManagementScreen(),
  };

  /// Routes that need arguments or return a typed result.
  static Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case NavigationUtil.providerDetailRoute:
        final provider = settings.arguments;
        if (provider is! model.Provider) return null;
        return MaterialPageRoute<void>(
          builder: (_) => ProviderDetailScreen(provider: provider),
          settings: settings,
        );
      case NavigationUtil.newProviderRoute:
        return MaterialPageRoute<model.Provider>(
          builder: (_) => const NewProviderScreen(),
          settings: settings,
        );
      case NavigationUtil.newFeeIntervalRoute:
        return MaterialPageRoute<FeeInterval>(
          builder: (_) =>
              NewFeeIntervalScreen(providerId: settings.arguments as String?),
          settings: settings,
        );
      case NavigationUtil.newCurrencyRoute:
        return MaterialPageRoute<Currency>(
          builder: (_) => const NewCurrencyScreen(),
          settings: settings,
        );
    }
    return null;
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
      routes: _routes,
      onGenerateRoute: _onGenerateRoute,
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        builder: (_) => const OptimizeFeeScreen(),
        settings: settings,
      ),
      initialRoute: initialRoute,
      navigatorObservers: [NavigationUtil.routeObserver],
      theme: ThemeUtil.lightTheme,
      darkTheme: ThemeUtil.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        FallbackMaterialLocalizationsDelegate(),
        GlobalWidgetsLocalizations.delegate,
        FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // The design uses fixed font sizes: keep the system text scale within
      // a range the layouts support instead of ignoring it.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(maxScaleFactor: 1.3),
          ),
          child: child!,
        );
      },
    );
  }
}
