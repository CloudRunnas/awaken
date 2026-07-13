import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:phoenix/src/beginning/utilities/global_variables.dart';
import 'package:phoenix/src/beginning/utilities/translation/deepl_languages.dart';
import 'package:phoenix/src/beginning/utilities/translation/translation_cache.dart';
import 'package:phoenix/src/beginning/utilities/translation/translation_config.dart';

class TranslationResult {
  final String translated;
  final String? detectedSourceLanguage;

  const TranslationResult({
    required this.translated,
    this.detectedSourceLanguage,
  });
}

enum TranslationFailure {
  notConfigured,
  isolation,
  rateLimited,
  unauthorized,
  network,
  invalidResponse,
}

class TranslationException implements Exception {
  final TranslationFailure failure;
  final String message;

  const TranslationException(this.failure, this.message);

  @override
  String toString() => message;
}

class TranslationService {
  TranslationService._();

  static final TranslationService inst = TranslationService._();

  String get targetLangCode =>
      musicBox.get('translationTargetLang') as String? ?? 'DE';

  DeeplLanguage get targetLanguage => deeplLanguageByCode(targetLangCode);

  bool get isEnabled => TranslationConfig.isConfigured;

  bool get isBlockedByIsolation => musicBox.get('isolation') ?? false;

  Future<TranslationResult> translate(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const TranslationException(
        TranslationFailure.invalidResponse,
        'Leerer Text',
      );
    }

    if (isBlockedByIsolation) {
      throw const TranslationException(
        TranslationFailure.isolation,
        'Isolation-Modus aktiv — keine Übersetzungen.',
      );
    }

    if (!isEnabled) {
      throw const TranslationException(
        TranslationFailure.notConfigured,
        'Übersetzungs-Proxy ist nicht konfiguriert.',
      );
    }

    final target = targetLangCode;
    final cached = TranslationCache.get(trimmed, target);
    if (cached != null && cached.translated.isNotEmpty) {
      return TranslationResult(
        translated: cached.translated,
        detectedSourceLanguage: cached.detectedSourceLanguage,
      );
    }

    final response = await http
        .post(
          Uri.parse(TranslationConfig.proxyUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Phoenix-Api-Key': TranslationConfig.appApiKey,
          },
          body: jsonEncode({
            'text': trimmed,
            'target_lang': target,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 429) {
      throw const TranslationException(
        TranslationFailure.rateLimited,
        'Tageslimit erreicht (2000 Anfragen/Tag).',
      );
    }
    if (response.statusCode == 401) {
      throw const TranslationException(
        TranslationFailure.unauthorized,
        'Übersetzungs-API nicht autorisiert.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TranslationException(
        TranslationFailure.network,
        'Übersetzung fehlgeschlagen (${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const TranslationException(
        TranslationFailure.invalidResponse,
        'Ungültige Server-Antwort.',
      );
    }

    final translations = decoded['translations'];
    if (translations is! List || translations.isEmpty) {
      throw const TranslationException(
        TranslationFailure.invalidResponse,
        'Keine Übersetzung erhalten.',
      );
    }

    final first = translations.first;
    if (first is! Map<String, dynamic>) {
      throw const TranslationException(
        TranslationFailure.invalidResponse,
        'Ungültiges Übersetzungsformat.',
      );
    }

    final translated = first['text'] as String? ?? '';
    final detected = first['detected_source_language'] as String?;

    final result = TranslationResult(
      translated: translated,
      detectedSourceLanguage: detected,
    );

    await TranslationCache.put(
      trimmed,
      target,
      TranslationCacheEntry(
        translated: translated,
        detectedSourceLanguage: detected,
      ),
    );

    return result;
  }
}
