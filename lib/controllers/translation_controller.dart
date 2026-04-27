import 'package:flutter/foundation.dart';
import 'package:translator_app/models/translation.dart';
import 'package:translator_app/services/firebase_service.dart';
import 'package:translator_app/services/translation_service.dart';
import 'package:uuid/uuid.dart';

class TranslationController extends ChangeNotifier {
  final TranslationService _translationService;
  final FirebaseService _firebaseService;
  final Uuid _uuid;

  TranslationController({
    TranslationService? translationService,
    FirebaseService? firebaseService,
    Uuid? uuid,
  })  : _translationService = translationService ?? TranslationService(),
        _firebaseService = firebaseService ?? FirebaseService(),
        _uuid = uuid ?? const Uuid();

  String _translatedText = '';
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'en';
  bool _isLoading = false;
  String? _errorMessage;
  String? _saveMessage;
  bool _isDisposed = false;
  int _activeRequestId = 0;

  String get translatedText => _translatedText;
  String get sourceLanguage => _sourceLanguage;
  String get targetLanguage => _targetLanguage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get saveMessage => _saveMessage;

  Map<String, String> get sourceLanguages =>
      TranslationService.getSupportedLanguages();

  Map<String, String> get targetLanguages =>
      TranslationService.getTargetLanguages();

  Future<void> translate(String inputText) async {
    if (_isLoading) return;

    final originalText = inputText.trim();
    final int requestId = ++_activeRequestId;

    _errorMessage = null;
    _saveMessage = null;
    _translatedText = '';
    _isLoading = true;
    _notifySafely();

    final result = await _translationService.translateText(
      text: originalText,
      sourceLang: _sourceLanguage,
      targetLang: _targetLanguage,
    );

    if (!_isCurrentRequest(requestId)) return;

    if (!result.success) {
      _errorMessage = result.errorMessage ?? 'Translation failed';
      _isLoading = false;
      _notifySafely();
      return;
    }

    final translatedText = result.translatedText ?? '';
    _translatedText = translatedText;
    _isLoading = false;
    _notifySafely();

    final translation = Translation(
      id: _uuid.v4(),
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: _sourceLanguage,
      targetLanguage: _targetLanguage,
      timestamp: DateTime.now(),
    );

    final saved = await _firebaseService.addTranslation(translation);

    if (!_isCurrentRequest(requestId)) return;

    _saveMessage = saved
        ? 'Saved to history'
        : 'Translated, but not saved to history. Check your internet connection or Firebase rules.';
    _notifySafely();
  }

  void setSourceLanguage(String? languageCode) {
    if (_isLoading) return;

    _sourceLanguage = languageCode ?? 'auto';
    _errorMessage = null;
    _saveMessage = null;
    _notifySafely();
  }

  void setTargetLanguage(String? languageCode) {
    if (_isLoading) return;

    _targetLanguage = languageCode ?? 'en';
    _errorMessage = null;
    _saveMessage = null;
    _notifySafely();
  }

  String? swapLanguages() {
    if (_isLoading) return null;

    if (_sourceLanguage == 'auto') {
      _errorMessage = 'Choose a source language before swapping';
      _saveMessage = null;
      _notifySafely();
      return null;
    }

    final oldSourceLanguage = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = oldSourceLanguage;

    final replacementInput = _translatedText.isNotEmpty ? _translatedText : null;
    _translatedText = '';
    _errorMessage = null;
    _saveMessage = null;
    _notifySafely();

    return replacementInput;
  }

  void clear() {
    if (_isLoading) return;

    _translatedText = '';
    _errorMessage = null;
    _saveMessage = null;
    _notifySafely();
  }

  bool _isCurrentRequest(int requestId) {
    return !_isDisposed && requestId == _activeRequestId;
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _activeRequestId++;
    _isDisposed = true;
    super.dispose();
  }
}
