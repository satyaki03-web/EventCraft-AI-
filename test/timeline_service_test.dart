import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_ai/models/enums.dart';
import 'package:eventcraft_ai/models/event_context.dart';
import 'package:eventcraft_ai/services/timeline_service.dart';

void main() {
  group('TimelineService Tests', () {
    final fixedNow = DateTime(2026, 10, 20);

    test('Timeline Service correctly flags Rush Mode when under 30 days', () {
      final service = TimelineService(nowProvider: () => fixedNow);
      final eventContext = EventContext(
        eventType: EventType.birthday,
        title: 'Quick Party',
        eventDate: fixedNow.add(const Duration(days: 15)),
        guestCount: 30,
        totalBudget: 25000,
      );

      expect(service.isRushMode(eventContext), isTrue);
    });

    test('Milestones are ordered chronologically by due date', () {
      final service = TimelineService(nowProvider: () => fixedNow);
      final eventContext = EventContext(
        eventType: EventType.wedding,
        title: 'Grand Wedding',
        eventDate: fixedNow.add(const Duration(days: 300)),
        guestCount: 300,
        totalBudget: 2000000,
      );

      final milestones = service.generateTimeline(eventContext);
      expect(milestones, isNotEmpty);

      for (int i = 0; i < milestones.length - 1; i++) {
        expect(
          milestones[i].dueDate.isBefore(milestones[i + 1].dueDate) ||
              milestones[i].dueDate.isAtSameMomentAs(milestones[i + 1].dueDate),
          isTrue,
        );
      }
    });
  });
}
