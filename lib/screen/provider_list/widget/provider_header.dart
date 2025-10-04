import 'package:flutter/material.dart';
import '../../../styles/global.dart';
import '../../../util/theme_util.dart';

/// Header section with title and counter for the provider list
class ProviderHeader extends StatelessWidget {
  final int providerCount;

  const ProviderHeader({
    super.key,
    required this.providerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'List of all providers',
            style: TextStyle(
              fontSize: 14,
              color: ThemeUtil.textSecondary,
            ),
          ),
          Global.gapSm,
          Text(
            '$providerCount Providers',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: ThemeUtil.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}