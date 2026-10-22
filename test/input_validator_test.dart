import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_ai/validation/input_validator.dart';

void main() {
  group('InputValidator Tests', () {
    test('sanitizeText strips control characters and collapses whitespace', () {
      final input = '  Hello \x00 World \n\n Extra   spaces  ';
      final cleaned = InputValidator.sanitizeText(input);
      expect(cleaned, equals('Hello World Extra spaces'));
    });

    test('validateTitle rejects empty or whitespace title', () {
      expect(InputValidator.validateTitle(''), isNotNull);
      expect(InputValidator.validateTitle('   '), isNotNull);
      expect(InputValidator.validateTitle('Aarav Birthday'), isNull);
    });

    test('validateGuestCount rejects zero, negative, or non-integer', () {
      expect(InputValidator.validateGuestCount('0'), isNotNull);
      expect(InputValidator.validateGuestCount('-10'), isNotNull);
      expect(InputValidator.validateGuestCount('abc'), isNotNull);
      expect(InputValidator.validateGuestCount('150'), isNull);
    });

    test('validateEventDate rejects past date', () {
      final fixedNow = DateTime(2026, 10, 20);
      final pastDate = DateTime(2026, 10, 19);
      final futureDate = DateTime(2026, 10, 21);

      expect(
        InputValidator.validateEventDate(pastDate, nowProvider: () => fixedNow),
        isNotNull,
      );
      expect(
        InputValidator.validateEventDate(futureDate, nowProvider: () => fixedNow),
        isNull,
      );
    });
  });
}
