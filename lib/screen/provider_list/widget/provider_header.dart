import 'package:flutter/material.dart';
import '../../../styles/global.dart';
import '../../../util/theme_util.dart';

/// Optimized provider header
class ProviderHeader extends StatelessWidget {
  const ProviderHeader({super.key, required this.providerCount});

  final int providerCount;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'List of all providers',
              style: ThemeUtil.bodySmall,
            ),
            Global.gapSm,
            Text(
              '$providerCount Providers',
              style: ThemeUtil.titleLarge,
            ),
          ],
        ),
      );
}