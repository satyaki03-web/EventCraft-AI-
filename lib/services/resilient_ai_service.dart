import '../core/config.dart';
import '../models/event_context.dart';
import '../models/ideas_result.dart';
import 'ai_service.dart';
import 'fallback_ai_service.dart';
import 'gemini_ai_service.dart';
import 'lru_cache.dart';
import 'rate_limiter.dart';

/// Resilient AI Service wrapping Gemini + Fallback with LRU cache and Rate Limiter.
class ResilientAiService implements AiService {
  final AiService _geminiService;
  final AiService _fallbackService;
  final LruCache<String, IdeasResult> _cache;
  final RateLimiter _rateLimiter;

  ResilientAiService({
    AiService? geminiService,
    AiService? fallbackService,
    LruCache<String, IdeasResult>? cache,
    RateLimiter? rateLimiter,
  })  : _geminiService = geminiService ?? GeminiAiService(),
        _fallbackService = fallbackService ?? FallbackAiService(),
        _cache = cache ?? LruCache<String, IdeasResult>(),
        _rateLimiter = rateLimiter ?? RateLimiter();

  @override
  Future<IdeasResult> generateIdeas(EventContext context) async {
    final cacheKey = context.cacheKey;

    // 1. Return from LRU Cache if available
    final cached = _cache.get(cacheKey);
    if (cached != null) {
      return cached;
    }

    // 2. Check key or proxy presence
    if (!AppConfig.hasApiKey && !AppConfig.hasProxyUrl) {
      final fallbackResult = await _fallbackService.generateIdeas(context);
      _cache.put(cacheKey, fallbackResult);
      return fallbackResult;
    }

    // 3. Check Rate Limit
    final limitError = _rateLimiter.checkRateLimit();
    if (limitError != null) {
      final fallbackResult = await _fallbackService.generateIdeas(context);
      _cache.put(cacheKey, fallbackResult);
      return fallbackResult;
    }

    // 4. Try Gemini call with fallback on error
    try {
      _rateLimiter.recordCall();
      final result = await _geminiService.generateIdeas(context);
      _cache.put(cacheKey, result);
      return result;
    } catch (_) {
      // Return seamless fallback on network error, timeout, bad status, or malformed json
      final fallbackResult = await _fallbackService.generateIdeas(context);
      _cache.put(cacheKey, fallbackResult);
      return fallbackResult;
    }
  }

  @override
  Future<String> askPlanner(EventContext context, String question) async {
    if (!AppConfig.hasApiKey && !AppConfig.hasProxyUrl) {
      return _fallbackService.askPlanner(context, question);
    }

    try {
      return await _geminiService.askPlanner(context, question);
    } catch (_) {
      return await _fallbackService.askPlanner(context, question);
    }
  }

  void clearCache() => _cache.clear();
}
