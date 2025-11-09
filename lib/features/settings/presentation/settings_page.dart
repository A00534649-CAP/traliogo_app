import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/settings_service.dart';
import '../../../providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    final settingsService = ref.read(settingsServiceProvider.notifier);
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section (U12)
          _buildSectionCard(
            title: 'Cuenta',
            icon: Icons.person,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: authState.user?.avatarUrl != null
                      ? NetworkImage(authState.user!.avatarUrl!)
                      : null,
                  child: authState.user?.avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(authState.user?.displayName ?? 'Usuario'),
                subtitle: Text(authState.user?.email ?? ''),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditProfileDialog(context, ref),
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Verificación de identidad'),
                subtitle: Text(authState.isVerified ? 'Verificado' : 'No verificado'),
                trailing: Icon(
                  authState.isVerified ? Icons.check_circle : Icons.warning,
                  color: authState.isVerified ? Colors.green : Colors.orange,
                ),
                onTap: () => context.push('/verify'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Language Settings (U11)
          _buildSectionCard(
            title: 'Idiomas',
            icon: Icons.language,
            children: [
              ListTile(
                leading: const Icon(Icons.input),
                title: const Text('Idioma origen por defecto'),
                subtitle: Text(_getLanguageName(settings.defaultSourceLang)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showLanguageSelector(
                  context,
                  'Idioma origen',
                  settings.defaultSourceLang,
                  (lang) => settingsService.updateDefaultLanguages(lang, settings.defaultTargetLang),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.output),
                title: const Text('Idioma destino por defecto'),
                subtitle: Text(_getLanguageName(settings.defaultTargetLang)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showLanguageSelector(
                  context,
                  'Idioma destino',
                  settings.defaultTargetLang,
                  (lang) => settingsService.updateDefaultLanguages(settings.defaultSourceLang, lang),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // App Settings (U11)
          _buildSectionCard(
            title: 'Aplicación',
            icon: Icons.settings,
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Tema'),
                subtitle: Text(_getThemeName(settings.themeMode)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _showThemeSelector(context, settings.themeMode, settingsService),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.volume_up),
                title: const Text('Reproducir pronunciación automáticamente'),
                subtitle: const Text('Reproducir audio al completar traducciones'),
                value: settings.autoPlayPronunciation,
                onChanged: (value) => settingsService.updateAutoPlayPronunciation(value),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Notificaciones'),
                subtitle: const Text('Recibir notificaciones de la app'),
                value: settings.enableNotifications,
                onChanged: (value) => settingsService.updateNotifications(value),
              ),
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Tamaño de fuente'),
                subtitle: Text('${settings.fontSize.toInt()}px'),
                trailing: Slider(
                  value: settings.fontSize,
                  min: 12,
                  max: 20,
                  divisions: 8,
                  onChanged: (value) => settingsService.updateFontSize(value),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Admin Section (U14, U15) - Only for admin users
          if (authState.user?.role == 'admin') ...[
            _buildSectionCard(
              title: 'Administración',
              icon: Icons.admin_panel_settings,
              children: [
                ListTile(
                  leading: const Icon(Icons.health_and_safety),
                  title: const Text('Estado del sistema'),
                  subtitle: const Text('Monitorear salud del sistema'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.push('/admin/health'),
                ),
                ListTile(
                  leading: const Icon(Icons.flag),
                  title: const Text('Feature Flags'),
                  subtitle: const Text('Gestionar características del sistema'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => context.push('/admin/flags'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Actions (U13)
          _buildSectionCard(
            title: 'Acciones',
            icon: Icons.logout,
            children: [
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Ver historial completo'),
                subtitle: const Text('Traducciones y objetos reconocidos'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.push('/history'),
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Restablecer configuración'),
                subtitle: const Text('Volver a valores por defecto'),
                onTap: () => _showResetDialog(context, settingsService),
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                onTap: () => _showLogoutDialog(context, authNotifier),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryTeal),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.subtitle1),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    const languages = {
      'es': 'Español',
      'en': 'English',
      'fr': 'Français',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
    };
    return languages[code] ?? code;
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sistema';
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
    }
  }

  void _showLanguageSelector(BuildContext context, String title, String current, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'es', 'en', 'fr', 'de', 'it', 'pt'
          ].map((code) => ListTile(
            title: Text(_getLanguageName(code)),
            leading: Radio<String>(
              value: code,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  onSelect(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context, ThemeMode current, SettingsService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) => ListTile(
            title: Text(_getThemeName(mode)),
            leading: Radio<ThemeMode>(
              value: mode,
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  service.updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    // U12 implementation placeholder
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: const Text('Función de edición de perfil próximamente'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer configuración'),
        content: const Text('¿Estás seguro de que quieres restablecer toda la configuración a los valores por defecto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              service.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración restablecida')),
              );
            },
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthNotifier authNotifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              authNotifier.logout();
              Navigator.of(context).pop();
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}