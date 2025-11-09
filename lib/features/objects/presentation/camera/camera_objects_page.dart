import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../api/models/object_models.dart';
import 'camera_objects_controller.dart';

class CameraObjectsPage extends ConsumerWidget {
  const CameraObjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraObjectsControllerProvider);
    final cameraController = ref.read(cameraObjectsControllerProvider.notifier);

    ref.listen(cameraObjectsControllerProvider, (previous, next) {
      if (next.state == CameraObjectsState.error && next.errorMessage != null) {
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
        title: const Text('Reconocer Objetos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/objects/history'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                ),
                child: _buildCameraPreview(cameraState),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildControls(context, cameraState, cameraController),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraObjectsStateData cameraState) {
    if (cameraState.state == CameraObjectsState.success && cameraState.recognizedObject != null) {
      return _buildRecognitionResult(cameraState.recognizedObject!);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          cameraState.state == CameraObjectsState.capturing
              ? Icons.camera
              : cameraState.state == CameraObjectsState.recognizing
                  ? Icons.auto_awesome
                  : Icons.camera_alt_outlined,
          size: 80,
          color: cameraState.state == CameraObjectsState.capturing ||
                  cameraState.state == CameraObjectsState.recognizing
              ? AppColors.primaryTeal
              : Colors.grey[400],
        ),
        const SizedBox(height: 16),
        Text(
          _getStateMessage(cameraState.state),
          style: AppTextStyles.subtitle1,
          textAlign: TextAlign.center,
        ),
        if (cameraState.state == CameraObjectsState.capturing ||
            cameraState.state == CameraObjectsState.recognizing) ...[
          const SizedBox(height: 16),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
          ),
        ],
      ],
    );
  }

  Widget _buildRecognitionResult(ObjectOut object) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
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
              Icons.check_circle,
              size: 60,
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Objeto Reconocido',
            style: AppTextStyles.headline2.copyWith(
              color: AppColors.primaryTeal,
            ),
          ),
          const SizedBox(height: 16),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Objeto:', style: AppTextStyles.body1),
                    Text(
                      object.objectName,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Confianza:', style: AppTextStyles.body1),
                    Text(
                      '${(object.confidence * 100).toStringAsFixed(1)}%',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context,
    CameraObjectsStateData cameraState,
    CameraObjectsController cameraController,
  ) {
    final isProcessing = cameraState.state == CameraObjectsState.capturing ||
        cameraState.state == CameraObjectsState.recognizing;

    return Column(
      children: [
        if (cameraState.state == CameraObjectsState.success) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => cameraController.clearResult(),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Nuevo'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/objects/history'),
                  icon: const Icon(Icons.history),
                  label: const Text('Historial'),
                ),
              ),
            ],
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : () => cameraController.captureAndRecognize(),
              icon: Icon(
                isProcessing ? Icons.hourglass_empty : Icons.camera_alt,
              ),
              label: Text(
                isProcessing ? 'Procesando...' : 'Capturar y Reconocer',
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.lightTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.lightTeal.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Apunta la cámara hacia un objeto y presiona el botón para reconocerlo.',
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStateMessage(CameraObjectsState state) {
    switch (state) {
      case CameraObjectsState.initial:
        return 'Listo para capturar';
      case CameraObjectsState.capturing:
        return 'Capturando imagen...';
      case CameraObjectsState.recognizing:
        return 'Reconociendo objeto...';
      case CameraObjectsState.success:
        return '¡Reconocimiento exitoso!';
      case CameraObjectsState.error:
        return 'Error en el reconocimiento';
    }
  }
}