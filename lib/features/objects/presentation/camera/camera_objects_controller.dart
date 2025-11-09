import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/objects_api.dart';
import '../../../../api/models/object_models.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_provider.dart';

enum CameraObjectsState {
  initial,
  capturing,
  recognizing,
  success,
  error,
}

class CameraObjectsStateData {
  final CameraObjectsState state;
  final String? errorMessage;
  final ObjectOut? recognizedObject;

  const CameraObjectsStateData({
    required this.state,
    this.errorMessage,
    this.recognizedObject,
  });

  CameraObjectsStateData copyWith({
    CameraObjectsState? state,
    String? errorMessage,
    ObjectOut? recognizedObject,
  }) {
    return CameraObjectsStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      recognizedObject: recognizedObject ?? this.recognizedObject,
    );
  }
}

class CameraObjectsController extends StateNotifier<CameraObjectsStateData> {
  final ObjectsApi _objectsApi;
  final AuthNotifier _authNotifier;

  CameraObjectsController(this._objectsApi, this._authNotifier)
      : super(const CameraObjectsStateData(state: CameraObjectsState.initial));

  String _getDefaultImageUrl() {
    return 'https://via.placeholder.com/400x300.png?text=Captured+Object';
  }

  Future<void> captureAndRecognize() async {
    final currentUser = _authNotifier.state.user;
    if (currentUser == null) {
      state = state.copyWith(
        state: CameraObjectsState.error,
        errorMessage: 'Usuario no autenticado',
      );
      return;
    }

    debugPrint('CAMERA_OBJECTS: Starting capture and recognition...');
    state = state.copyWith(state: CameraObjectsState.capturing);

    try {
      // Simulate camera capture
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('CAMERA_OBJECTS: Image captured, starting recognition...');
      
      state = state.copyWith(state: CameraObjectsState.recognizing);
      
      // Simulate object recognition
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate simulated recognition result
      final objectNames = [
        'traffic sign', 'car', 'tree', 'building', 'person', 
        'bicycle', 'street light', 'bench', 'dog', 'cat'
      ];
      final randomObject = objectNames[DateTime.now().millisecond % objectNames.length];
      final confidence = 0.85 + (DateTime.now().millisecond % 15) / 100; // 0.85-0.99
      
      debugPrint('CAMERA_OBJECTS: Recognition completed: $randomObject (${(confidence * 100).toStringAsFixed(1)}%)');
      
      // Create object in backend
      final objectCreate = ObjectCreate(
        userId: currentUser.id,
        objectName: randomObject,
        confidence: confidence,
        imageUrl: _getDefaultImageUrl(),
      );
      
      debugPrint('CAMERA_OBJECTS: Saving to backend...');
      final createdObject = await _objectsApi.createObject(objectCreate);
      
      debugPrint('CAMERA_OBJECTS: Object saved successfully! ID: ${createdObject.id}');
      
      state = state.copyWith(
        state: CameraObjectsState.success,
        recognizedObject: createdObject,
      );
    } catch (e) {
      debugPrint('CAMERA_OBJECTS ERROR: $e');
      state = state.copyWith(
        state: CameraObjectsState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearResult() {
    state = const CameraObjectsStateData(state: CameraObjectsState.initial);
  }

  void clearError() {
    if (state.state == CameraObjectsState.error) {
      state = state.copyWith(state: CameraObjectsState.initial, errorMessage: null);
    }
  }
}

final cameraObjectsControllerProvider = StateNotifierProvider<CameraObjectsController, CameraObjectsStateData>((ref) {
  final objectsApi = ref.watch(objectsApiProvider);
  final authNotifier = ref.read(authProvider.notifier);
  
  return CameraObjectsController(objectsApi, authNotifier);
});