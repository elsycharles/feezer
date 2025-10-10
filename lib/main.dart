import 'package:fee_minimizer/util/constant_util.dart';
import 'package:fee_minimizer/util/route_util.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/provider/theme_provider.dart';
import 'package:fee_minimizer/provider/locale_provider.dart';
import 'package:fee_minimizer/l10n/app_localizations.dart';
import 'package:fee_minimizer/l10n/localization_delegate.dart';
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

  runApp(MyApp(themeProvider: themeProvider, localeProvider: localeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LocaleProvider localeProvider;

  const MyApp({
    super.key,
    required this.themeProvider,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp.router(
            title: ConstantUtil.appName,
            routerConfig: AppRouter.router,
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
