import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'verify_reset_code_controller.dart';

class VerifyResetCodePage extends ConsumerStatefulWidget {
  final String email;

  const VerifyResetCodePage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends ConsumerState<VerifyResetCodePage> {
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
      ref.read(verifyResetCodeControllerProvider.notifier).verifyResetCode(
        email: widget.email,
        code: _codeController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(verifyResetCodeControllerProvider);

    ref.listen(verifyResetCodeControllerProvider, (previous, next) {
      if (next.state == VerifyResetCodeState.success && next.email != null && next.resetToken != null) {
        // Navigate to reset password page with token
        context.go('/reset-password?email=${Uri.encodeComponent(next.email!)}&token=${Uri.encodeComponent(next.resetToken!)}');
      } else if (next.state == VerifyResetCodeState.error && next.errorMessage != null) {
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
          'Verificar Código',
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
                // Red icon for password reset
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
                  'Ingresa el Código de Recuperación',
                  style: AppTextStyles.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Email info
                Text(
                  'Hemos enviado un código ROJO de 6 dígitos a:',
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: AppTextStyles.subtitle1.copyWith(
                    color: Colors.red,
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
                    color: Colors.red, // Red color for reset code
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
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
                    onPressed: state.state == VerifyResetCodeState.loading || _codeController.text.length != 6 
                        ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: state.state == VerifyResetCodeState.loading
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
                
                // Resend section
                Center(
                  child: Column(
                    children: [
                      const Text(
                        '¿No recibiste el código?',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: state.state == VerifyResetCodeState.loading 
                            ? null 
                            : () => _handleResendCode(),
                        child: Text(
                          'Reenviar código de recuperación',
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        'Código de Recuperación (ROJO):',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Revisa tu bandeja de entrada y carpeta de spam\n'
                        '• El código expira en 15 minutos\n'
                        '• Ingresa solo números, sin espacios\n'
                        '• Este código es diferente al código azul de verificación',
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

  void _handleResendCode() {
    // Navigate back to forgot password to send another code
    context.go('/forgot-password');
  }
}