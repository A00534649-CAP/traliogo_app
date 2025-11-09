import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class PronunciationService {
  Future<void> speak(String text, String languageCode) async {
    debugPrint('PRONUNCIATION: Speaking "$text" in $languageCode');
    
    // Simulate TTS delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    debugPrint('PRONUNCIATION: Speech completed');
  }

  Future<void> stop() async {
    debugPrint('PRONUNCIATION: Stopping speech');
  }

  bool get isAvailable => true;
  
  List<String> get supportedLanguages => [
    'es', 'en', 'fr', 'de', 'it', 'pt'
  ];
}

final pronunciationServiceProvider = Provider<PronunciationService>((ref) {
  return PronunciationService();
});