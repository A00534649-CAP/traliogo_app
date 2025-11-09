import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'login_verification_controller.dart';

class LoginVerificationPage extends ConsumerStatefulWidget {
  final String email;

  const LoginVerificationPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<LoginVerificationPage> createState() => _LoginVerificationPageState();
}

class _LoginVerificationPageState extends ConsumerState<LoginVerificationPage> {
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
      ref.read(loginVerificationControllerProvider.notifier).verifyCodeAndLogin(
        email: widget.email,
        code: _codeController.text,
      );
    }
  }

  void _resendCode() {
    ref.read(loginVerificationControllerProvider.notifier).sendLoginVerificationCode(
      email: widget.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginVerificationControllerProvider);

    ref.listen<LoginVerificationStateData>(
      loginVerificationControllerProvider,
      (previous, current) {
        if (current.state == LoginVerificationState.success) {
          // Navigate to home after successful verification
          context.go('/home');
        } else if (current.state == LoginVerificationState.error && current.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(current.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          // Clear error after showing
          Future.delayed(const Duration(milliseconds: 100), () {
            ref.read(loginVerificationControllerProvider.notifier).clearError();
          });
        }
      },
    );

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
          'Verificación de Login',
          style: AppTextStyles.headline2,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            
            // Header
            const Text(
              'Ingresa el Código de Verificación',
              style: AppTextStyles.headline1,
            ),
            const SizedBox(height: 16),
            
            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.lightTeal.withOpacity(0.3),
                ),
              ),
              child: Text(
                'Hemos enviado un código de 6 dígitos a ${widget.email}. '
                'Revisa tu bandeja de entrada e ingresa el código a continuación.',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 32),
            
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
                onPressed: state.state == LoginVerificationState.loading || _codeController.text.length != 6 
                    ? null : _verifyCode,
                child: state.state == LoginVerificationState.loading
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
            
            const SizedBox(height: 24),
            
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
                    onPressed: state.state == LoginVerificationState.loading ? null : _resendCode,
                    child: Text(
                      state.canResend 
                        ? 'Reenviar código de verificación'
                        : 'Reenviar código (${state.remainingAttempts} intentos restantes)',
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (state.blockedTimeRemaining != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Bloqueado por ${state.blockedTimeRemaining} minutos',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Help text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consejos:',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Revisa tu bandeja de entrada y carpeta de spam\n'
                    '• El código expira en 15 minutos\n'
                    '• Ingresa solo números, sin espacios',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}