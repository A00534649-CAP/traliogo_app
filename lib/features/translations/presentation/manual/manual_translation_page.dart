import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'manual_translation_controller.dart';

class ManualTranslationPage extends ConsumerStatefulWidget {
  const ManualTranslationPage({super.key});

  @override
  ConsumerState<ManualTranslationPage> createState() => _ManualTranslationPageState();
}

class _ManualTranslationPageState extends ConsumerState<ManualTranslationPage> {
  final _sourceController = TextEditingController();
  String _sourceLang = 'es';
  String _targetLang = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'es', 'name': 'Español'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'pt', 'name': 'Português'},
  ];

  @override
  void dispose() {
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(manualTranslationControllerProvider);
    final translationController = ref.read(manualTranslationControllerProvider.notifier);

    ref.listen(manualTranslationControllerProvider, (previous, next) {
      if (next.state == ManualTranslationState.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      } else if (next.state == ManualTranslationState.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Traducción guardada en el historial'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Traducción Manual'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/translations/history'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLanguageSelector(),
              const SizedBox(height: 24),
              _buildSourceTextCard(translationState, translationController),
              const SizedBox(height: 16),
              _buildSwapButton(),
              const SizedBox(height: 16),
              _buildTranslationCard(translationState, translationController),
              if (translationState.state == ManualTranslationState.translated ||
                  translationState.state == ManualTranslationState.saved) ...[
                const SizedBox(height: 24),
                _buildActionButtons(translationState, translationController),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Idioma origen:', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _sourceLang,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _languages.map((lang) {
                      return DropdownMenuItem(
                        value: lang['code'],
                        child: Text(lang['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sourceLang = value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Idioma destino:', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _targetLang,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _languages.map((lang) {
                      return DropdownMenuItem(
                        value: lang['code'],
                        child: Text(lang['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _targetLang = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceTextCard(ManualTranslationStateData translationState, ManualTranslationController translationController) {
    final isProcessing = translationState.state == ManualTranslationState.translating;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Texto a traducir:', style: AppTextStyles.subtitle2),
            const SizedBox(height: 12),
            TextField(
              controller: _sourceController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe el texto que quieres traducir...',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => translationController.clearError(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: isProcessing
                    ? null
                    : () => translationController.translateText(
                          sourceText: _sourceController.text,
                          sourceLang: _sourceLang,
                          targetLang: _targetLang,
                        ),
                icon: Icon(
                  isProcessing ? Icons.hourglass_empty : Icons.translate,
                ),
                label: Text(
                  isProcessing ? 'Traduciendo...' : 'Traducir',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwapButton() {
    return Center(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryTeal.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryTeal.withOpacity(0.3)),
        ),
        child: IconButton(
          onPressed: () {
            setState(() {
              final temp = _sourceLang;
              _sourceLang = _targetLang;
              _targetLang = temp;
            });
          },
          icon: const Icon(
            Icons.swap_vert,
            color: AppColors.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationCard(ManualTranslationStateData translationState, ManualTranslationController translationController) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Traducción:', style: AppTextStyles.subtitle2),
                const Spacer(),
                if (translationState.translatedText != null) ...[
                  IconButton(
                    onPressed: () {
                      // TODO: Implement TTS (U8)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función de pronunciación próximamente')),
                      );
                    },
                    icon: const Icon(Icons.volume_up),
                    iconSize: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 100),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: translationState.translatedText != null
                    ? AppColors.lightTeal.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: translationState.translatedText != null
                      ? AppColors.lightTeal.withOpacity(0.3)
                      : Colors.grey[300]!,
                ),
              ),
              child: translationState.state == ManualTranslationState.translating
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryTeal),
                      ),
                    )
                  : Text(
                      translationState.translatedText ?? 'La traducción aparecerá aquí...',
                      style: AppTextStyles.body1.copyWith(
                        color: translationState.translatedText != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ManualTranslationStateData translationState, ManualTranslationController translationController) {
    final isSaving = translationState.state == ManualTranslationState.saving;
    final isSaved = translationState.state == ManualTranslationState.saved;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              translationController.clearTranslation();
              _sourceController.clear();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Nueva'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSaving || isSaved
                ? null
                : () => translationController.saveTranslation(
                      sourceText: _sourceController.text,
                      translatedText: translationState.translatedText!,
                      sourceLang: _sourceLang,
                      targetLang: _targetLang,
                    ),
            icon: Icon(
              isSaved
                  ? Icons.check
                  : isSaving
                      ? Icons.hourglass_empty
                      : Icons.save,
            ),
            label: Text(
              isSaved
                  ? 'Guardado'
                  : isSaving
                      ? 'Guardando...'
                      : 'Guardar',
            ),
          ),
        ),
      ],
    );
  }
}