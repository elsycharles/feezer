import 'package:fee_minimizer/util/constant_util.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/provider/theme_provider.dart';
import 'package:fee_minimizer/provider/locale_provider.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:fee_minimizer/l10n/localization_delegate.dart';
import 'package:fee_minimizer/screen/provider_list/provider_list_screen.dart';
import 'package:fee_minimizer/screen/onboarding/onboarding_screen.dart';
import 'package:fee_minimizer/screen/settings/settings_screen.dart';
import 'package:fee_minimizer/screen/new_provider/new_provider_screen.dart';
import 'package:fee_minimizer/screen/provider_detail/provider_detail_screen.dart';
import 'package:fee_minimizer/screen/optimize_fee/optimize_fee_screen.dart';
import 'package:fee_minimizer/screen/fee_interval/new_fee_interval_screen.dart';
import 'package:fee_minimizer/model/provider_model.dart' as model;
import 'package:fee_minimizer/model/fee_interval_model.dart';
import 'package:fee_minimizer/util/preference_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final themeProvider = ThemeProvider();
  final localeProvider = LocaleProvider();

  await Future.wait([
    themeProvider.initializeTheme(),
    localeProvider.initializeLocale(),
  ]);

  // Check if first launch
  final isFirstLaunch = await PreferenceUtil.isFirstLaunch();

  runApp(MyApp(
    themeProvider: themeProvider,
    localeProvider: localeProvider,
    initialRoute: isFirstLaunch ? '/onboarding' : '/',
  ));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;
  final String initialRoute;

  const MyApp({
    super.key,
    required this.themeProvider,
    required this.localeProvider,
    required this.initialRoute,
  });

  Map<String, WidgetBuilder> get routes => {
    '/': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as model.Provider?;
      return OptimizeFeeScreen(defaultProvider: args);
    },
    '/onboarding': (_) => const OnboardingScreen(),
    '/providers': (_) => const ProviderListScreen(),
    '/settings': (_) => const SettingsScreen(),
    '/provider': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as model.Provider?;
      if (args != null) {
        return ProviderDetailScreen(provider: args);
      }
      return ProviderDetailScreen(
        provider: model.Provider(
          id: 'unknown',
          name: 'Loading...',
          description: 'Loading provider details...',
          iconName: 'business',
        ),
      );
    },
  };

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/new-provider':
        return MaterialPageRoute<model.Provider>(
          builder: (_) => const NewProviderScreen(),
          settings: settings,
        );
      case '/new-fee-interval':
        return MaterialPageRoute<FeeInterval>(
          builder: (_) => const NewFeeIntervalScreen(),
          settings: settings,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            title: ConstantUtil.appName,
            routes: routes,
            initialRoute: initialRoute,
            theme: ThemeUtil.lightTheme,
            darkTheme: ThemeUtil.darkTheme,
            themeMode: themeProvider.flutterThemeMode,
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              FallbackMaterialLocalizationsDelegate(),
              GlobalWidgetsLocalizations.delegate,
              FallbackCupertinoLocalizationsDelegate(),
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
