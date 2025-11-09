import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgotPasswordState = ref.watch(forgotPasswordControllerProvider);
    final forgotPasswordController = ref.read(forgotPasswordControllerProvider.notifier);

    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      if (next.state == ForgotPasswordState.success && next.email != null) {
        // Navigate to verify reset code page
        context.go('/verify-reset-code?email=${Uri.encodeComponent(next.email!)}');
      } else if (next.state == ForgotPasswordState.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.lightGrey,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Recuperar Contraseña',
          style: AppTextStyles.headline2,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.red,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                const Text(
                  '¿Olvidaste tu contraseña?',
                  style: AppTextStyles.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Ingresa tu email y te enviaremos un código de verificación para restablecer tu contraseña.',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Form card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Ingresa tu email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Por favor ingresa un email válido';
                              }
                              return null;
                            },
                            onChanged: (_) => forgotPasswordController.clearError(),
                          ),
                          const SizedBox(height: 24),
                          
                          SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: forgotPasswordState.state == ForgotPasswordState.loading
                                  ? null
                                  : _handleSendResetCode,
                              icon: forgotPasswordState.state == ForgotPasswordState.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.send),
                              label: Text(
                                forgotPasswordState.state == ForgotPasswordState.loading
                                    ? 'Enviando...'
                                    : 'Enviar Código',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Back to login
                TextButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver al login'),
                ),

                const SizedBox(height: 32),

                // Help text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Importante:',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• El código de recuperación será de color ROJO\n'
                        '• Revisa tu bandeja de entrada y carpeta de spam\n'
                        '• El código expira en 15 minutos\n'
                        '• Solo puedes solicitar 3 códigos por minuto',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSendResetCode() {
    if (_formKey.currentState!.validate()) {
      ref.read(forgotPasswordControllerProvider.notifier).sendResetCode(
            _emailController.text.trim(),
          );
    }
  }
}