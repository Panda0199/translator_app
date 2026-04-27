class Translation {
  final String id;
  final String originalText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;

  Translation({
    required this.id,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originalText': originalText,
      'translatedText': translatedText,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Translation.fromMap(Map<String, dynamic> map) {
    final rawTimestamp = map['timestamp'];
    final parsedTimestamp = DateTime.tryParse(rawTimestamp?.toString() ?? '');

    return Translation(
      id: map['id']?.toString() ?? '',
      originalText: map['originalText']?.toString() ?? '',
      translatedText: map['translatedText']?.toString() ?? '',
      sourceLanguage: map['sourceLanguage']?.toString() ?? '',
      targetLanguage: map['targetLanguage']?.toString() ?? '',
      timestamp: parsedTimestamp ?? DateTime.now(),
    );
  }
}
