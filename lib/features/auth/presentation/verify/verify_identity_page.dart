import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../providers/auth_provider.dart';
import 'verify_identity_controller.dart';

class VerifyIdentityPage extends ConsumerStatefulWidget {
  const VerifyIdentityPage({super.key});

  @override
  ConsumerState<VerifyIdentityPage> createState() => _VerifyIdentityPageState();
}

class _VerifyIdentityPageState extends ConsumerState<VerifyIdentityPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verifyState = ref.watch(verifyIdentityControllerProvider);
    final verifyController = ref.read(verifyIdentityControllerProvider.notifier);
    final authState = ref.watch(authProvider);

    ref.listen(verifyIdentityControllerProvider, (previous, next) {
      if (next.state == VerifyState.success) {
        context.go('/home');
      } else if (next.state == VerifyState.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Identity'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            ref.read(authProvider.notifier).logout();
            context.go('/login');
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 60,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Verify Your Identity',
                  style: AppTextStyles.headline1,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hi ${authState.user?.displayName ?? 'User'}!',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter the verification code to continue using TrailoGo.',
                  style: AppTextStyles.body1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _codeController,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Verification Code',
                              hintText: 'Enter your code here',
                              prefixIcon: Icon(Icons.vpn_key_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the verification code';
                              }
                              return null;
                            },
                            onChanged: (_) => verifyController.clearError(),
                            onFieldSubmitted: (_) => _handleVerify(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: verifyState.state == VerifyState.loading
                                  ? null
                                  : _handleVerify,
                              child: verifyState.state == VerifyState.loading
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
                                  : const Text('Verify'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
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
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryTeal,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'For testing purposes, you can use any verification code.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleVerify() {
    if (_formKey.currentState!.validate()) {
      ref.read(verifyIdentityControllerProvider.notifier).verifyToken(
            _codeController.text.trim(),
          );
    }
  }
}