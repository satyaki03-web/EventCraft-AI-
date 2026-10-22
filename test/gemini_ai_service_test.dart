import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:eventcraft_ai/models/enums.dart';
import 'package:eventcraft_ai/models/event_context.dart';
import 'package:eventcraft_ai/services/gemini_ai_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('GeminiAiService Tests', () {
    late MockHttpClient mockClient;

    setUp(() {
      mockClient = MockHttpClient();
      registerFallbackValue(Uri());
    });

    test('GeminiAiService parses valid JSON response correctly', () async {
      final sampleResponseJson = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text': jsonEncode({
                    'themeSummary': 'Royal Gold Theme',
                    'decorIdeas': ['Marigold Arch'],
                    'menuHighlights': ['Paneer Tikka'],
                    'interactiveActivities': ['Trivia'],
                    'entertainmentOptions': ['DJ'],
                    'returnGiftIdeas': ['Candles'],
                    'sampleDayOfSchedule': ['10:00 AM Setup'],
                  })
                }
              ]
            }
          }
        ]
      };

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(jsonEncode(sampleResponseJson), 200));

      final service = GeminiAiService(
        client: mockClient,
        apiKey: 'test_key',
        model: 'gemini-3.6-flash',
      );

      final context = EventContext(
        eventType: EventType.wedding,
        title: 'Test Wedding',
        eventDate: DateTime.now().add(const Duration(days: 90)),
        guestCount: 100,
        totalBudget: 500000,
      );

      final result = await service.generateIdeas(context);

      expect(result.themeSummary, equals('Royal Gold Theme'));
      expect(result.decorIdeas.first, equals('Marigold Arch'));
      expect(result.isFallback, isFalse);
    });

    test('GeminiAiService throws exception on non-200 HTTP response', () async {
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      final service = GeminiAiService(
        client: mockClient,
        apiKey: 'test_key',
      );

      final context = EventContext(
        eventType: EventType.wedding,
        title: 'Test Wedding',
        eventDate: DateTime.now().add(const Duration(days: 90)),
        guestCount: 100,
        totalBudget: 500000,
      );

      expect(() => service.generateIdeas(context), throwsA(isA<Exception>()));
    });
  });
}
