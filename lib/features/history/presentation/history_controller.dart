import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../api/translations_api.dart';
import '../../../api/objects_api.dart';
import '../../../api/models/translation_models.dart';
import '../../../api/models/object_models.dart';
import '../../../providers/api_providers.dart';
import '../../../providers/auth_provider.dart';

enum HistoryState {
  initial,
  loading,
  loaded,
  error,
}

class HistoryItem {
  final String id;
  final String type; // 'translation' or 'object'
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final dynamic data; // TranslationOut or ObjectOut

  const HistoryItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.data,
  });
}

class HistoryStateData {
  final HistoryState state;
  final List<HistoryItem> items;
  final String? errorMessage;

  const HistoryStateData({
    required this.state,
    this.items = const [],
    this.errorMessage,
  });

  HistoryStateData copyWith({
    HistoryState? state,
    List<HistoryItem>? items,
    String? errorMessage,
  }) {
    return HistoryStateData(
      state: state ?? this.state,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }
}

class HistoryController extends StateNotifier<HistoryStateData> {
  final TranslationsApi _translationsApi;
  final ObjectsApi _objectsApi;
  final AuthNotifier _authNotifier;

  HistoryController(this._translationsApi, this._objectsApi, this._authNotifier)
      : super(const HistoryStateData(state: HistoryState.initial));

  Future<void> loadHistory() async {
    final currentUser = _authNotifier.state.user;
    if (currentUser == null) {
      state = state.copyWith(
        state: HistoryState.error,
        errorMessage: 'Usuario no autenticado',
      );
      return;
    }

    debugPrint('HISTORY: Loading complete history...');
    state = state.copyWith(state: HistoryState.loading);

    try {
      // Load translations and objects in parallel
      final results = await Future.wait([
        _translationsApi.listTranslations(),
        _objectsApi.listObjects(),
      ]);

      final translations = results[0] as List<TranslationOut>;
      final objects = results[1] as List<ObjectOut>;

      // Filter by current user
      final userTranslations = translations.where((t) => t.userId == currentUser.id);
      final userObjects = objects.where((o) => o.userId == currentUser.id);

      // Convert to history items
      final historyItems = <HistoryItem>[];

      for (final translation in userTranslations) {
        historyItems.add(HistoryItem(
          id: translation.id,
          type: 'translation',
          title: translation.sourceText,
          subtitle: '${translation.sourceLanguage} → ${translation.targetLanguage}',
          createdAt: translation.createdAt,
          data: translation,
        ));
      }

      for (final object in userObjects) {
        historyItems.add(HistoryItem(
          id: object.id,
          type: 'object',
          title: object.objectName,
          subtitle: 'Confianza: ${(object.confidence * 100).toStringAsFixed(1)}%',
          createdAt: object.createdAt,
          data: object,
        ));
      }

      // Sort by creation date (newest first)
      historyItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('HISTORY: Loaded ${historyItems.length} items');

      state = state.copyWith(
        state: HistoryState.loaded,
        items: historyItems,
      );
    } catch (e) {
      debugPrint('HISTORY ERROR: $e');
      state = state.copyWith(
        state: HistoryState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> deleteItem(HistoryItem item) async {
    debugPrint('HISTORY: Deleting ${item.type} ${item.id}...');

    try {
      if (item.type == 'translation') {
        await _translationsApi.deleteTranslation(item.id);
      } else if (item.type == 'object') {
        await _objectsApi.deleteObject(item.id);
      }

      // Remove from local state
      final updatedItems = state.items.where((i) => i.id != item.id).toList();

      state = state.copyWith(items: updatedItems);

      debugPrint('HISTORY: Item deleted successfully');
    } catch (e) {
      debugPrint('HISTORY DELETE ERROR: $e');
      state = state.copyWith(
        state: HistoryState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    if (state.state == HistoryState.error) {
      state = state.copyWith(state: HistoryState.loaded, errorMessage: null);
    }
  }
}

final historyControllerProvider = StateNotifierProvider<HistoryController, HistoryStateData>((ref) {
  final translationsApi = ref.watch(translationsApiProvider);
  final objectsApi = ref.watch(objectsApiProvider);
  final authNotifier = ref.read(authProvider.notifier);
  
  return HistoryController(translationsApi, objectsApi, authNotifier);
});