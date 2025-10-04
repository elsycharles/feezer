import 'package:flutter/material.dart';
import 'package:fee_minimizer/util/constante_util.dart';
import 'package:fee_minimizer/styles/global.dart';

class AppTitle extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Color? color;
  
  const AppTitle({
    super.key, 
    this.title, 
    this.subtitle,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title ?? ConstanteUtil.appName,
          style: TextStyle(
            fontSize: Global.fontDisplay,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 1.2,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: Global.fontLg,
              color: color?.withValues(alpha: 0.7),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ],
    );
  }
}