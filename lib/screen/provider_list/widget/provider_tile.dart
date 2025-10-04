import 'package:flutter/material.dart';
import '../../../styles/global.dart';
import '../../../util/theme_util.dart';

/// Individual tile for each provider with action icons
class ProviderTile extends StatelessWidget {
  final String title;
  final String? logoPath;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProviderTile({
    super.key,
    required this.title,
    this.logoPath,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeUtil.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ThemeUtil.textPrimary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ThemeUtil.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: _buildLogo(),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ThemeUtil.textPrimary,
              ),
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: Icons.edit,
                color: ThemeUtil.primaryColor,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.close,
                color: ThemeUtil.error,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  

  Widget _buildLogo() {
    // Provider-specific icons or fallback
    IconData icon;
    switch (title.toLowerCase()) {
      case 'bank':
        icon = Icons.account_balance;
        break;
      case 'mvola':
      case 'orange':
      case 'airtel':
        icon = Icons.phone_android;
        break;
      default:
        icon = Icons.business;
    }

    return Icon(
      icon,
      color: ThemeUtil.textLight,
      size: 24,
    );
  }
}

/// Private widget for action buttons
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
        ),
        child: Icon(
          icon,
          color: color,
          size: Global.iconSm,
        ),
      ),
    );
  }
}