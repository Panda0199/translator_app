class TranslationResult {
  final bool success;
  final String? translatedText;
  final String? errorMessage;

  const TranslationResult._({
    required this.success,
    this.translatedText,
    this.errorMessage,
  });

  factory TranslationResult.success(String translatedText) {
    return TranslationResult._(
      success: true,
      translatedText: translatedText,
    );
  }

  factory TranslationResult.failure(String errorMessage) {
    return TranslationResult._(
      success: false,
      errorMessage: errorMessage,
    );
  }
}
