import 'package:fee_minimizer/util/constante_util.dart';
import 'package:fee_minimizer/util/route_util.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: ConstanteUtil.appName,
      routerConfig: AppRouter.router,
      theme: ThemeUtil.lightTheme,
      darkTheme: ThemeUtil.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}