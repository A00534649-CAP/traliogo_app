import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'email_verification_controller.dart';

class EmailVerificationPage extends ConsumerStatefulWidget {
  final String email;
  
  const EmailVerificationPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _verifyCode() {
    if (_codeController.text.length == 6) {
      ref.read(emailVerificationControllerProvider.notifier).verifyCode(
        email: widget.email,
        code: _codeController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(emailVerificationControllerProvider);
    final verificationController = ref.read(emailVerificationControllerProvider.notifier);

    ref.listen(emailVerificationControllerProvider, (previous, next) {
      if (next.state == EmailVerificationState.success) {
        // Check if this success is from code verification
        if (next.successMessage?.contains('puedes iniciar sesión') == true) {
          // Show success message and navigate to login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Navigate to login after verification
          Future.delayed(const Duration(seconds: 2), () {
            context.go('/login');
          });
        } else {
          // Show success message for resend verification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage ?? '¡Código de verificación reenviado! Revisa tu email.'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (next.state == EmailVerificationState.error && next.errorMessage != null) {
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Verify Email'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.lightTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.lightTeal,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.email_outlined,
                    size: 50,
                    color: AppColors.lightTeal,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Ingresa el Código de Verificación',
                  style: AppTextStyles.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hemos enviado un código de 6 dígitos a:',
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Code input field
                TextField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primaryTeal, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 6) {
                      _verifyCode();
                    }
                  },
                  onSubmitted: (_) => _verifyCode(),
                ),
                
                const SizedBox(height: 24),
                
                // Verify button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: verificationState.state == EmailVerificationState.loading || _codeController.text.length != 6 
                        ? null : _verifyCode,
                    child: verificationState.state == EmailVerificationState.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Verificar Código'),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: verificationState.state == EmailVerificationState.loading
                        ? null
                        : () => _handleResendCode(),
                    icon: verificationState.state == EmailVerificationState.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      verificationState.state == EmailVerificationState.loading
                          ? 'Reenviando...'
                          : 'Reenviar Código',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      foregroundColor: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login),
                    label: const Text('Ir a Iniciar Sesión'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryTeal,
                      side: const BorderSide(color: AppColors.primaryTeal),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '¿No recibiste el código?',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Revisa tu carpeta de spam\n• El código expira en 15 minutos\n• Ingresa solo números, sin espacios',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.darkGrey,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleResendCode() {
    ref.read(emailVerificationControllerProvider.notifier).resendVerification(widget.email);
  }
}