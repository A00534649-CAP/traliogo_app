import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/objects_api.dart';
import '../../../../api/models/object_models.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_provider.dart';

enum ObjectsHistoryState {
  initial,
  loading,
  loaded,
  error,
}

class ObjectsHistoryStateData {
  final ObjectsHistoryState state;
  final List<ObjectOut> objects;
  final String? errorMessage;

  const ObjectsHistoryStateData({
    required this.state,
    this.objects = const [],
    this.errorMessage,
  });

  ObjectsHistoryStateData copyWith({
    ObjectsHistoryState? state,
    List<ObjectOut>? objects,
    String? errorMessage,
  }) {
    return ObjectsHistoryStateData(
      state: state ?? this.state,
      objects: objects ?? this.objects,
      errorMessage: errorMessage,
    );
  }
}

class ObjectsHistoryController extends StateNotifier<ObjectsHistoryStateData> {
  final ObjectsApi _objectsApi;
  final AuthNotifier _authNotifier;

  ObjectsHistoryController(this._objectsApi, this._authNotifier)
      : super(const ObjectsHistoryStateData(state: ObjectsHistoryState.initial));

  Future<void> loadHistory() async {
    final currentUser = _authNotifier.state.user;
    if (currentUser == null) {
      state = state.copyWith(
        state: ObjectsHistoryState.error,
        errorMessage: 'Usuario no autenticado',
      );
      return;
    }

    debugPrint('OBJECTS_HISTORY: Loading objects history...');
    state = state.copyWith(state: ObjectsHistoryState.loading);

    try {
      final objects = await _objectsApi.listObjects();
      
      // Filter by current user
      final userObjects = objects.where((obj) => obj.userId == currentUser.id).toList();
      
      debugPrint('OBJECTS_HISTORY: Loaded ${userObjects.length} objects');
      
      state = state.copyWith(
        state: ObjectsHistoryState.loaded,
        objects: userObjects,
      );
    } catch (e) {
      debugPrint('OBJECTS_HISTORY ERROR: $e');
      state = state.copyWith(
        state: ObjectsHistoryState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> deleteObject(String objectId) async {
    debugPrint('OBJECTS_HISTORY: Deleting object $objectId...');
    
    try {
      await _objectsApi.deleteObject(objectId);
      
      // Remove from local state
      final updatedObjects = state.objects.where((obj) => obj.id != objectId).toList();
      
      state = state.copyWith(
        objects: updatedObjects,
      );
      
      debugPrint('OBJECTS_HISTORY: Object deleted successfully');
    } catch (e) {
      debugPrint('OBJECTS_HISTORY DELETE ERROR: $e');
      state = state.copyWith(
        state: ObjectsHistoryState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    if (state.state == ObjectsHistoryState.error) {
      state = state.copyWith(state: ObjectsHistoryState.loaded, errorMessage: null);
    }
  }
}

final objectsHistoryControllerProvider = StateNotifierProvider<ObjectsHistoryController, ObjectsHistoryStateData>((ref) {
  final objectsApi = ref.watch(objectsApiProvider);
  final authNotifier = ref.read(authProvider.notifier);
  
  return ObjectsHistoryController(objectsApi, authNotifier);
});