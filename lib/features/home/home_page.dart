import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TrailoGo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/images/traliogo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Welcome to TrailoGo!',
                style: AppTextStyles.headline1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Hello, ${authState.user?.displayName ?? 'User'}!',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                authState.user?.email ?? '',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85, // Hace los cuadros más altos
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.camera_alt,
                    title: 'Reconocer Objetos',
                    subtitle: 'Usa la cámara para identificar objetos',
                    onTap: () => context.push('/objects'),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.translate,
                    title: 'Traducir Texto',
                    subtitle: 'Traduce texto manualmente',
                    onTap: () => context.push('/translations/manual'),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.document_scanner,
                    title: 'OCR Traducción',
                    subtitle: 'Traduce texto desde imágenes',
                    onTap: () => context.push('/translations/ocr'),
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.mic,
                    title: 'Voz a Texto',
                    subtitle: 'Traduce desde audio',
                    onTap: () => context.push('/translations/voice'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: AppColors.primaryTeal,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Authentication Complete!',
                        style: AppTextStyles.headline2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You have successfully logged in and your identity has been verified.',
                        style: AppTextStyles.body1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.lightTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.lightTeal.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: AppColors.primaryTeal,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Role: ${authState.user?.role ?? 'N/A'}',
                                  style: AppTextStyles.body1,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  color: AppColors.primaryTeal,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Verified: ${authState.isVerified ? 'Yes' : 'No'}',
                                  style: AppTextStyles.body1,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.subtitle2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context, ref);
              },
              child: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context, WidgetRef ref) {
    // Clear auth state
    ref.read(authProvider.notifier).logout();
    
    // Navigate to login and clear the navigation stack
    context.go('/login');
  }
}