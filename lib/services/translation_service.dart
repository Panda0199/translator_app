import 'dart:async';

import 'package:translator/translator.dart' as google_translator;
import 'package:translator_app/models/translation_result.dart';

class TranslationService {
  final google_translator.GoogleTranslator _translator =
      google_translator.GoogleTranslator();

  final Map<String, String> _translationCache = <String, String>{};

  static const Duration _translationTimeout = Duration(seconds: 12);
  static const int _maxInputCharacters = 700;
  static const int _maxCacheItems = 80;

  Future<TranslationResult> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final input = text.trim();

    if (input.isEmpty) {
      return TranslationResult.failure('Please enter text to translate');
    }

    if (input.length > _maxInputCharacters) {
      return TranslationResult.failure(
        'Text is too long. Please translate less than $_maxInputCharacters characters at once.',
      );
    }

    if (targetLang == 'auto') {
      return TranslationResult.failure('Please choose a target language');
    }

    if (sourceLang != 'auto' && sourceLang == targetLang) {
      return TranslationResult.failure(
        'Source and target languages cannot be the same',
      );
    }

    final cacheKey = _buildCacheKey(
      text: input,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    final cachedTranslation = _translationCache[cacheKey];
    if (cachedTranslation != null) {
      return TranslationResult.success(cachedTranslation);
    }

    try {
      final result = await (sourceLang == 'auto'
              ? _translator.translate(input, to: targetLang)
              : _translator.translate(
                  input,
                  from: sourceLang,
                  to: targetLang,
                ))
          .timeout(_translationTimeout);

      final translatedText = result.text.trim();

      if (translatedText.isEmpty) {
        return TranslationResult.failure('Translation returned empty result');
      }

      _saveToCache(cacheKey, translatedText);
      return TranslationResult.success(translatedText);
    } on TimeoutException {
      return TranslationResult.failure(
        'Translation took too long. Check your internet connection and try again.',
      );
    } catch (_) {
      return TranslationResult.failure(
        'Translation failed. Check your internet connection and try again.',
      );
    }
  }

  String _buildCacheKey({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) {
    return '$sourceLang|$targetLang|${text.toLowerCase()}';
  }

  void _saveToCache(String key, String value) {
    if (_translationCache.length >= _maxCacheItems) {
      _translationCache.remove(_translationCache.keys.first);
    }

    _translationCache[key] = value;
  }

  static Map<String, String> getSupportedLanguages() {
    return {
      'auto': 'Auto detect',
      'en': 'English',
      'et': 'Estonian',
      'bn': 'Bengali',
      'az': 'Azerbaijani',
      'ru': 'Russian',
      'de': 'German',
      'fr': 'French',
      'es': 'Spanish',
      'it': 'Italian',
      'pt': 'Portuguese',
      'tr': 'Turkish',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh-cn': 'Chinese Simplified',
    };
  }

  static Map<String, String> getTargetLanguages() {
    final languages = Map<String, String>.from(getSupportedLanguages());
    languages.remove('auto');
    return languages;
  }
}
