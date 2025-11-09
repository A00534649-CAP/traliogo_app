import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/translations_api.dart';
import '../../../../api/models/translation_models.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_provider.dart';

enum ManualTranslationState {
  initial,
  translating,
  translated,
  saving,
  saved,
  error,
}

class ManualTranslationStateData {
  final ManualTranslationState state;
  final String? errorMessage;
  final String? translatedText;
  final TranslationOut? savedTranslation;

  const ManualTranslationStateData({
    required this.state,
    this.errorMessage,
    this.translatedText,
    this.savedTranslation,
  });

  ManualTranslationStateData copyWith({
    ManualTranslationState? state,
    String? errorMessage,
    String? translatedText,
    TranslationOut? savedTranslation,
  }) {
    return ManualTranslationStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      translatedText: translatedText ?? this.translatedText,
      savedTranslation: savedTranslation ?? this.savedTranslation,
    );
  }
}

class ManualTranslationController extends StateNotifier<ManualTranslationStateData> {
  final TranslationsApi _translationsApi;
  final AuthNotifier _authNotifier;

  ManualTranslationController(this._translationsApi, this._authNotifier)
      : super(const ManualTranslationStateData(state: ManualTranslationState.initial));

  final Map<String, String> _translationPairs = {
    // Spanish to English
    'hola': 'hello',
    'mundo': 'world',
    'casa': 'house',
    'carro': 'car',
    'comida': 'food',
    'agua': 'water',
    'gracias': 'thank you',
    'por favor': 'please',
    'buenas tardes': 'good afternoon',
    'buenos días': 'good morning',
    'buenas noches': 'good night',
    'cómo estás': 'how are you',
    'muy bien': 'very well',
    'de nada': 'you\'re welcome',
    'lo siento': 'I\'m sorry',
    'disculpe': 'excuse me',
    'no entiendo': 'I don\'t understand',
    'habla más despacio': 'speak more slowly',
    'cuánto cuesta': 'how much does it cost',
    'dónde está': 'where is',
    // English to Spanish
    'hello': 'hola',
    'world': 'mundo',
    'house': 'casa',
    'car': 'carro',
    'food': 'comida',
    'water': 'agua',
    'thank you': 'gracias',
    'please': 'por favor',
    'good morning': 'buenos días',
    'good afternoon': 'buenas tardes',
    'good night': 'buenas noches',
    'how are you': 'cómo estás',
    'very well': 'muy bien',
    'you\'re welcome': 'de nada',
    'I\'m sorry': 'lo siento',
    'excuse me': 'disculpe',
    'I don\'t understand': 'no entiendo',
    'speak more slowly': 'habla más despacio',
    'how much does it cost': 'cuánto cuesta',
    'where is': 'dónde está',
  };

  Future<void> translateText({
    required String sourceText,
    required String sourceLang,
    required String targetLang,
  }) async {
    if (sourceText.trim().isEmpty) {
      state = state.copyWith(
        state: ManualTranslationState.error,
        errorMessage: 'Por favor ingresa el texto a traducir',
      );
      return;
    }

    debugPrint('MANUAL_TRANSLATION: Translating "$sourceText" from $sourceLang to $targetLang');
    state = state.copyWith(state: ManualTranslationState.translating);

    try {
      // Simulate translation delay
      await Future.delayed(const Duration(seconds: 1));

      // Simple translation logic
      String translatedText = _performTranslation(sourceText.toLowerCase(), sourceLang, targetLang);
      
      debugPrint('MANUAL_TRANSLATION: Translation result: "$translatedText"');
      
      state = state.copyWith(
        state: ManualTranslationState.translated,
        translatedText: translatedText,
      );
    } catch (e) {
      debugPrint('MANUAL_TRANSLATION ERROR: $e');
      state = state.copyWith(
        state: ManualTranslationState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  String _performTranslation(String text, String sourceLang, String targetLang) {
    // Check if we have a direct translation
    if (_translationPairs.containsKey(text)) {
      return _translationPairs[text]!;
    }

    // Check word by word
    final words = text.split(' ');
    final translatedWords = words.map((word) {
      return _translationPairs[word.toLowerCase()] ?? word;
    }).toList();

    final result = translatedWords.join(' ');
    
    // If no translation found, provide a generic translation
    if (result == text) {
      if (sourceLang == 'es' && targetLang == 'en') {
        return '[EN] $text';
      } else if (sourceLang == 'en' && targetLang == 'es') {
        return '[ES] $text';
      }
    }
    
    return result;
  }

  Future<void> saveTranslation({
    required String sourceText,
    required String translatedText,
    required String sourceLang,
    required String targetLang,
  }) async {
    final currentUser = _authNotifier.state.user;
    if (currentUser == null) {
      state = state.copyWith(
        state: ManualTranslationState.error,
        errorMessage: 'Usuario no autenticado',
      );
      return;
    }

    debugPrint('MANUAL_TRANSLATION: Saving translation to history...');
    state = state.copyWith(state: ManualTranslationState.saving);

    try {
      final translationCreate = TranslationCreate(
        userId: currentUser.id,
        sourceText: sourceText,
        targetText: translatedText,
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
        type: 'text',
      );

      final savedTranslation = await _translationsApi.createTranslation(translationCreate);
      
      debugPrint('MANUAL_TRANSLATION: Translation saved successfully! ID: ${savedTranslation.id}');
      
      state = state.copyWith(
        state: ManualTranslationState.saved,
        savedTranslation: savedTranslation,
      );
    } catch (e) {
      debugPrint('MANUAL_TRANSLATION SAVE ERROR: $e');
      state = state.copyWith(
        state: ManualTranslationState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearTranslation() {
    state = const ManualTranslationStateData(state: ManualTranslationState.initial);
  }

  void clearError() {
    if (state.state == ManualTranslationState.error) {
      state = state.copyWith(state: ManualTranslationState.initial, errorMessage: null);
    }
  }
}

final manualTranslationControllerProvider = StateNotifierProvider<ManualTranslationController, ManualTranslationStateData>((ref) {
  final translationsApi = ref.watch(translationsApiProvider);
  final authNotifier = ref.read(authProvider.notifier);
  
  return ManualTranslationController(translationsApi, authNotifier);
});