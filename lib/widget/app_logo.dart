import 'package:flutter/material.dart';
import 'package:fee_minimizer/util/theme_util.dart';
import 'package:fee_minimizer/styles/global.dart';

class AppLogo extends StatelessWidget {
  final double? size;
  final Color? iconColor;
  
  const AppLogo({super.key, this.size, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size ?? Global.logoSize,
      height: size ?? Global.logoSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance_wallet,
        size: Global.iconXxl,
        color: iconColor ?? ThemeUtil.primaryColor,
      ),
    );
  }
}