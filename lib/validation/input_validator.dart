import '../core/constants.dart';

/// Clean, robust input validation and sanitization for form inputs and prompt safety.
class InputValidator {
  /// Sanitize plain user text: trim, strip control chars, cap max length, collapse whitespace.
  static String sanitizeText(String input, {int maxLength = 300}) {
    final trimmed = input.trim();
    // Remove control characters (0x00 - 0x1F, 0x7F)
    final cleaned = trimmed.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    // Collapse multiple whitespaces
    final collapsed = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    if (collapsed.length > maxLength) {
      return collapsed.substring(0, maxLength);
    }
    return collapsed;
  }

  /// Validate event title
  static String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an event name';
    }
    final sanitized = sanitizeText(value, maxLength: AppConstants.maxEventNameLength);
    if (sanitized.length < 2) {
      return 'Event name must be at least 2 characters';
    }
    return null;
  }

  /// Validate guest count
  static String? validateGuestCount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter expected guest count';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Guest count must be a positive integer';
    }
    if (parsed > AppConstants.maxGuestCount) {
      return 'Guest count exceeds maximum limit (${AppConstants.maxGuestCount})';
    }
    return null;
  }

  /// Validate total budget
  static String? validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your total budget';
    }
    final cleaned = value.replaceAll(RegExp(r'[,₹\$€£]'), '').trim();
    final parsed = double.tryParse(cleaned);
    if (parsed == null || parsed <= 0) {
      return 'Please enter a valid positive budget amount';
    }
    if (parsed > AppConstants.maxBudgetAmount) {
      return 'Budget amount exceeds supported maximum';
    }
    return null;
  }

  /// Validate city / location
  static String? validateCity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a city or location';
    }
    return null;
  }

  /// Check date sanity: event date must not be in the past
  static String? validateEventDate(DateTime? date, {DateTime Function()? nowProvider}) {
    if (date == null) {
      return 'Please select an event date';
    }
    final now = (nowProvider != null) ? nowProvider() : DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(date.year, date.month, date.day);
    if (eventDay.isBefore(today)) {
      return 'Event date cannot be in the past';
    }
    return null;
  }
}
