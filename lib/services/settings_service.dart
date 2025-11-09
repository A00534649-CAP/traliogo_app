import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class AppSettings {
  final String defaultSourceLang;
  final String defaultTargetLang;
  final ThemeMode themeMode;
  final bool autoPlayPronunciation;
  final bool enableNotifications;
  final double fontSize;

  const AppSettings({
    this.defaultSourceLang = 'es',
    this.defaultTargetLang = 'en',
    this.themeMode = ThemeMode.system,
    this.autoPlayPronunciation = false,
    this.enableNotifications = true,
    this.fontSize = 14.0,
  });

  AppSettings copyWith({
    String? defaultSourceLang,
    String? defaultTargetLang,
    ThemeMode? themeMode,
    bool? autoPlayPronunciation,
    bool? enableNotifications,
    double? fontSize,
  }) {
    return AppSettings(
      defaultSourceLang: defaultSourceLang ?? this.defaultSourceLang,
      defaultTargetLang: defaultTargetLang ?? this.defaultTargetLang,
      themeMode: themeMode ?? this.themeMode,
      autoPlayPronunciation: autoPlayPronunciation ?? this.autoPlayPronunciation,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class SettingsService extends StateNotifier<AppSettings> {
  SettingsService() : super(const AppSettings());

  Future<void> loadSettings() async {
    // Simulate loading from shared_preferences
    await Future.delayed(const Duration(milliseconds: 100));
    // In real implementation, load from SharedPreferences
  }

  Future<void> updateDefaultLanguages(String sourceLang, String targetLang) async {
    state = state.copyWith(
      defaultSourceLang: sourceLang,
      defaultTargetLang: targetLang,
    );
    await _saveSettings();
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _saveSettings();
  }

  Future<void> updateAutoPlayPronunciation(bool enabled) async {
    state = state.copyWith(autoPlayPronunciation: enabled);
    await _saveSettings();
  }

  Future<void> updateNotifications(bool enabled) async {
    state = state.copyWith(enableNotifications: enabled);
    await _saveSettings();
  }

  Future<void> updateFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize);
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    // Simulate saving to shared_preferences
    await Future.delayed(const Duration(milliseconds: 50));
    // In real implementation, save to SharedPreferences
  }

  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await _saveSettings();
  }
}

final settingsServiceProvider = StateNotifierProvider<SettingsService, AppSettings>((ref) {
  return SettingsService();
});