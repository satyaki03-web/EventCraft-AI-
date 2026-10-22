/// Client-side rate limiter for AI calls. Enforces cooldown and max calls/minute.
class RateLimiter {
  final int cooldownSeconds;
  final int maxCallsPerMinute;

  DateTime? _lastCallTime;
  final List<DateTime> _recentCallTimes = [];

  RateLimiter({
    this.cooldownSeconds = 10,
    this.maxCallsPerMinute = 5,
  });

  /// Check if an AI call can proceed. Returns error message if blocked, null if permitted.
  String? checkRateLimit({DateTime Function()? nowProvider}) {
    final now = (nowProvider != null) ? nowProvider() : DateTime.now();

    // Check cooldown
    if (_lastCallTime != null) {
      final elapsed = now.difference(_lastCallTime!).inSeconds;
      if (elapsed < cooldownSeconds) {
        final waitSeconds = cooldownSeconds - elapsed;
        return 'Please wait $waitSeconds second(s) before requesting AI ideas again.';
      }
    }

    // Clean up call timestamps older than 60s
    _recentCallTimes.removeWhere((t) => now.difference(t).inSeconds >= 60);

    // Check max calls per minute
    if (_recentCallTimes.length >= maxCallsPerMinute) {
      return 'Rate limit reached (max $maxCallsPerMinute calls per minute). Please wait a moment.';
    }

    return null;
  }

  /// Record a successful call execution.
  void recordCall({DateTime Function()? nowProvider}) {
    final now = (nowProvider != null) ? nowProvider() : DateTime.now();
    _lastCallTime = now;
    _recentCallTimes.add(now);
  }

  void reset() {
    _lastCallTime = null;
    _recentCallTimes.clear();
  }
}
