import 'package:fee_minimizer/util/constante_util.dart';
import 'package:fee_minimizer/util/route_util.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.initializeTheme();
  
  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  
  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeProvider,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: ConstanteUtil.appName,
            routerConfig: AppRouter.router,
            theme: ThemeUtil.lightTheme,
            darkTheme: ThemeUtil.darkTheme,
            themeMode: themeProvider.flutterThemeMode,
          );
        },
      ),
    );
  }
}
