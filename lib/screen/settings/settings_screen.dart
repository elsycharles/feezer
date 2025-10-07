import 'package:flutter/material.dart';
import '../../widget/app_bar.dart' as custom;
import '../../widget/app_toast.dart';
import '../../widget/confirmation_modal.dart';
import '../../widget/surface_card.dart';
import '../../widget/interactive_surface.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const custom.AppBar(
        title: 'Paramètres',
        showSettingsButton: false, // Don't show settings button on settings page
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              context,
              'Général',
              [
                _buildSettingTile(
                  context,
                  'Notifications',
                  'Gérer les notifications de l\'application',
                  Icons.notifications_outlined,
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingTile(
                  context,
                  'Thème',
                  'Clair, sombre ou automatique',
                  Icons.palette_outlined,
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingTile(
                  context,
                  'Langue',
                  'Français',
                  Icons.language_outlined,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Données',
              [
                _buildSettingTile(
                  context,
                  'Exporter les données',
                  'Sauvegarder vos fournisseurs et frais',
                  Icons.file_download_outlined,
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingTile(
                  context,
                  'Importer les données',
                  'Restaurer depuis une sauvegarde',
                  Icons.file_upload_outlined,
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingTile(
                  context,
                  'Réinitialiser',
                  'Effacer toutes les données',
                  Icons.delete_outline,
                  onTap: () => _showResetConfirmation(context),
                  textColor: colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'À propos',
              [
                _buildSettingTile(
                  context,
                  'Version',
                  '1.0.0',
                  Icons.info_outline,
                  showArrow: false,
                ),
                _buildSettingTile(
                  context,
                  'Aide et support',
                  'FAQ et contact',
                  Icons.help_outline,
                  onTap: () => _showComingSoon(context),
                ),
                _buildSettingTile(
                  context,
                  'Conditions d\'utilisation',
                  'Termes et politique de confidentialité',
                  Icons.description_outlined,
                  onTap: () => _showComingSoon(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SurfaceCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
    bool showArrow = true,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InteractiveSurface(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      builder: (context, hovered, pressed) => ListTile(
        leading: Icon(
          icon,
          color: textColor ?? colorScheme.onSurface,
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: textColor ?? colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: showArrow
            ? Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
        enabled: onTap != null,
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    AppToast.info(context, 'Fonctionnalité à venir dans une prochaine version');
  }

  void _showResetConfirmation(BuildContext context) async {
    final confirmed = await ConfirmationModal.show(
      context,
      'Réinitialiser les données',
      'Cette action effacera définitivement toutes vos données (fournisseurs, frais, etc.). Cette action est irréversible.',
      confirmText: 'Réinitialiser',
      cancelText: 'Annuler',
    );
    
    if (confirmed == true && context.mounted) {
      _showComingSoon(context);
    }
  }
}