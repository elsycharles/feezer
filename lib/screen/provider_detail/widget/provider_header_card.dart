import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/provider_model.dart';
import '../../../util/theme_util.dart';
import '../../../util/icon_util.dart';
import '../../../styles/global.dart';

/// Clean provider header card with optimize button
class ProviderHeaderCard extends StatefulWidget {
  final Provider provider;
  final VoidCallback? onOptimize;

  const ProviderHeaderCard({
    super.key,
    required this.provider,
    this.onOptimize,
  });

  @override
  State<ProviderHeaderCard> createState() => _ProviderHeaderCardState();
}

class _ProviderHeaderCardState extends State<ProviderHeaderCard> {
  bool _isOptimizing = false;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: ThemeUtil.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ThemeUtil.textSecondary.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Global.gapLg,
            _buildStats(),
          ],
        ),
      );

  Widget _buildHeader() => Row(
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(child: _buildProviderInfo()),
          _buildOptimizeButton(),
        ],
      );

  Widget _buildAvatar() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ThemeUtil.primaryColor,
              ThemeUtil.primaryColor.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeUtil.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          IconUtil.getIcon(widget.provider.iconName),
          color: ThemeUtil.textLight,
          size: 24,
        ),
      );

  Widget _buildProviderInfo() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.provider.name,
            style: ThemeUtil.titleLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          if (widget.provider.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              widget.provider.description,
              style: ThemeUtil.bodyMedium.copyWith(color: ThemeUtil.textSecondary),
            ),
          ],
        ],
      );

  Widget _buildStats() => _buildStatItem('Total Fee Intervals', '5', Icons.receipt_long);

  Widget _buildStatItem(String label, String value, IconData icon) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: ThemeUtil.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ThemeUtil.primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: ThemeUtil.primaryColor),
              const SizedBox(width: 8),
              Text(
                value,
                style: ThemeUtil.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: ThemeUtil.primaryColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: ThemeUtil.bodyMedium.copyWith(
                  color: ThemeUtil.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildOptimizeButton() => GestureDetector(
        onTap: _isOptimizing ? null : _optimizeFees,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: _isOptimizing ? null : LinearGradient(
                colors: [ThemeUtil.primaryColor, ThemeUtil.primaryColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            color: _isOptimizing ? ThemeUtil.textSecondary.withValues(alpha: 0.3) : null,
            borderRadius: BorderRadius.circular(25),
            boxShadow: _isOptimizing ? null : [
                BoxShadow(
                  color: ThemeUtil.primaryColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isOptimizing) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(ThemeUtil.textLight),
                  ),
                ),
                const SizedBox(width: 8),
              ] else ...[
                Icon(
                  Icons.auto_fix_high,
                  size: 16,
                  color: ThemeUtil.textLight,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                _isOptimizing ? 'Loading...' : 'Fee Optimizer',
                style: ThemeUtil.labelLarge.copyWith(
                  color: ThemeUtil.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );

  void _optimizeFees() async {
    if (_isOptimizing) return;
    
    HapticFeedback.lightImpact();
    setState(() => _isOptimizing = true);
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      setState(() => _isOptimizing = false);
      widget.onOptimize?.call();
    }
  }
}