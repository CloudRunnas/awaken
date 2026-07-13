class TranslationConfig {
  static const proxyUrl = String.fromEnvironment(
    'DEEPL_PROXY_URL',
    defaultValue: '',
  );

  static const appApiKey = String.fromEnvironment(
    'PHOENIX_TRANSLATION_API_KEY',
    defaultValue: '',
  );

  static bool get isConfigured => proxyUrl.isNotEmpty && appApiKey.isNotEmpty;
}
