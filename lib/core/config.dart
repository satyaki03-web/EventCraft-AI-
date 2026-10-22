/// Environment configuration read via `--dart-define`.
class AppConfig {
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-3.6-flash',
  );

  static const String aiProxyUrl = String.fromEnvironment(
    'AI_PROXY_URL',
    defaultValue: '',
  );

  static bool get hasApiKey => geminiApiKey.isNotEmpty;
  static bool get hasProxyUrl => aiProxyUrl.isNotEmpty;
}
