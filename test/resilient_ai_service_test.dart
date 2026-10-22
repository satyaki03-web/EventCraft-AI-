import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:eventcraft_ai/models/enums.dart';
import 'package:eventcraft_ai/models/event_context.dart';
import 'package:eventcraft_ai/services/ai_service.dart';
import 'package:eventcraft_ai/services/fallback_ai_service.dart';
import 'package:eventcraft_ai/services/resilient_ai_service.dart';

class MockGeminiService extends Mock implements AiService {}

void main() {
  group('ResilientAiService Tests', () {
    late MockGeminiService mockGemini;
    late FallbackAiService fallbackService;

    setUp(() {
      mockGemini = MockGeminiService();
      fallbackService = FallbackAiService();
    });

    test('Seamlessly returns fallback result when Gemini throws exception', () async {
      final context = EventContext(
        eventType: EventType.wedding,
        title: 'Resilient Test Event',
        eventDate: DateTime.now().add(const Duration(days: 90)),
        guestCount: 150,
        totalBudget: 800000,
      );

      when(() => mockGemini.generateIdeas(any()))
          .thenThrow(Exception('Network disconnected'));

      final resilientService = ResilientAiService(
        geminiService: mockGemini,
        fallbackService: fallbackService,
      );

      final result = await resilientService.generateIdeas(context);

      expect(result.isFallback, isTrue);
      expect(result.themeSummary, isNotEmpty);
    });
  });
}
