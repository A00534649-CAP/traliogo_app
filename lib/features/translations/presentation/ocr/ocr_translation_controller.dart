import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/translations_api.dart';
import '../../../../api/models/translation_models.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_provider.dart';

enum OcrTranslationState {
  initial,
  capturing,
  extracting,
  translating,
  success,
  saving,
  saved,
  error,
}

class OcrTranslationStateData {
  final OcrTranslationState state;
  final String? errorMessage;
  final String? extractedText;
  final String? translatedText;
  final TranslationOut? savedTranslation;

  const OcrTranslationStateData({
    required this.state,
    this.errorMessage,
    this.extractedText,
    this.translatedText,
    this.savedTranslation,
  });

  OcrTranslationStateData copyWith({
    OcrTranslationState? state,
    String? errorMessage,
    String? extractedText,
    String? translatedText,
    TranslationOut? savedTranslation,
  }) {
    return OcrTranslationStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      extractedText: extractedText ?? this.extractedText,
      translatedText: translatedText ?? this.translatedText,
      savedTranslation: savedTranslation ?? this.savedTranslation,
    );
  }
}

class OcrTranslationController extends StateNotifier<OcrTranslationStateData> {
  final TranslationsApi _translationsApi;
  final AuthNotifier _authNotifier;

  OcrTranslationController(this._translationsApi, this._authNotifier)
      : super(const OcrTranslationStateData(state: OcrTranslationState.initial));

  final List<String> _sampleTexts = [
    'Hello world',
    'Bienvenidos a TrailoGo',
    'Welcome to our restaurant',
    'Salida de emergencia',
    'No smoking',
    'Prohibido fumar',
    'Open 24 hours',
    'Abierto las 24 horas',
  ];

  Future<void> captureAndTranslate(String sourceLang, String targetLang) async {
    final currentUser = _authNotifier.state.user;
    if (currentUser == null) {
      state = state.copyWith(
        state: OcrTranslationState.error,
        errorMessage: 'Usuario no autenticado',
      );
      return;
    }

    debugPrint('OCR_TRANSLATION: Starting capture and OCR translation...');
    state = state.copyWith(state: OcrTranslationState.capturing);

    try {
      // Simulate image capture
      await Future.delayed(const Duration(seconds: 1));
      
      debugPrint('OCR_TRANSLATION: Image captured, extracting text...');
      state = state.copyWith(state: OcrTranslationState.extracting);
      
      // Simulate OCR text extraction
      await Future.delayed(const Duration(seconds: 2));
      
      final extractedText = _sampleTexts[DateTime.now().millisecond % _sampleTexts.length];
      debugPrint('OCR_TRANSLATION: Text extracted: "$extractedText"');
      
      state = state.copyWith(
        state: OcrTranslationState.translating,
        extractedText: extractedText,
      );
      
      // Simulate translation
      await Future.delayed(const Duration(seconds: 1));
      
      final translatedText = _simulateTranslation(extractedText, sourceLang, targetLang);
      debugPrint('OCR_TRANSLATION: Translation completed: "$translatedText"');
      
      state = state.copyWith(
        state: OcrTranslationState.success,
        translatedText: translatedText,
      );
    } catch (e) {
      debugPrint('OCR_TRANSLATION ERROR: $e');
      state = state.copyWith(
        state: OcrTranslationState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String _simulateTranslation(String text, String sourceLang, String targetLang) {
    final translations = {
      'Hello world': 'Hola mundo',
      'Bienvenidos a TrailoGo': 'Welcome to TrailoGo',
      'Welcome to our restaurant': 'Bienvenidos a nuestro restaurante',
      'Salida de emergencia': 'Emergency exit',
      'No smoking': 'Prohibido fumar',
      'Prohibido fumar': 'No smoking',
      'Open 24 hours': 'Abierto las 24 horas',
      'Abierto las 24 horas': 'Open 24 hours',
    };
    
    return translations[text] ?? '[${targetLang.toUpperCase()}] $text';
  }

  Future<void> saveTranslation() async {
    final currentUser = _authNotifier.state.user;
    if (currentUser == null || state.extractedText == null || state.translatedText == null) {
      state = state.copyWith(
        state: OcrTranslationState.error,
        errorMessage: 'No hay traducción para guardar',
      );
      return;
    }

    debugPrint('OCR_TRANSLATION: Saving to history...');
    state = state.copyWith(state: OcrTranslationState.saving);

    try {
      final translationCreate = TranslationCreate(
        userId: currentUser.id,
        sourceText: state.extractedText!,
        targetText: state.translatedText!,
        sourceLanguage: 'auto',
        targetLanguage: 'es',
        type: 'image',
      );

      final savedTranslation = await _translationsApi.createTranslation(translationCreate);
      
      debugPrint('OCR_TRANSLATION: Saved successfully! ID: ${savedTranslation.id}');
      
      state = state.copyWith(
        state: OcrTranslationState.saved,
        savedTranslation: savedTranslation,
      );
    } catch (e) {
      debugPrint('OCR_TRANSLATION SAVE ERROR: $e');
      state = state.copyWith(
        state: OcrTranslationState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearResult() {
    state = const OcrTranslationStateData(state: OcrTranslationState.initial);
  }

  void clearError() {
    if (state.state == OcrTranslationState.error) {
      state = state.copyWith(state: OcrTranslationState.initial, errorMessage: null);
    }
  }
}

final ocrTranslationControllerProvider = StateNotifierProvider<OcrTranslationController, OcrTranslationStateData>((ref) {
  final translationsApi = ref.watch(translationsApiProvider);
  final authNotifier = ref.read(authProvider.notifier);
  
  return OcrTranslationController(translationsApi, authNotifier);
});