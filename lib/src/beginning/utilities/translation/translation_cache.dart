import 'package:phoenix/src/beginning/utilities/global_variables.dart';

class TranslationCacheEntry {
  final String translated;
  final String? detectedSourceLanguage;

  const TranslationCacheEntry({
    required this.translated,
    this.detectedSourceLanguage,
  });

  Map<String, dynamic> toJson() => {
        'translated': translated,
        'detectedSourceLanguage': detectedSourceLanguage,
      };

  factory TranslationCacheEntry.fromJson(Map<dynamic, dynamic> json) {
    return TranslationCacheEntry(
      translated: json['translated'] as String? ?? '',
      detectedSourceLanguage: json['detectedSourceLanguage'] as String?,
    );
  }
}

class TranslationCache {
  static String _key(String text, String targetLang) =>
      '$targetLang::${text.hashCode}::${text.length}';

  static TranslationCacheEntry? get(String text, String targetLang) {
    final store = musicBox.get('translationCache');
    if (store is! Map) return null;
    final raw = store[_key(text, targetLang)];
    if (raw is! Map) return null;
    return TranslationCacheEntry.fromJson(raw);
  }

  static Future<void> put(
    String text,
    String targetLang,
    TranslationCacheEntry entry,
  ) async {
    final store = Map<dynamic, dynamic>.from(
      musicBox.get('translationCache') ?? {},
    );
    store[_key(text, targetLang)] = entry.toJson();
    await musicBox.put('translationCache', store);
  }
}
