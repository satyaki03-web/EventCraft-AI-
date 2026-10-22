import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_ai/core/constants.dart';
import 'package:eventcraft_ai/models/enums.dart';
import 'package:eventcraft_ai/models/event_context.dart';
import 'package:eventcraft_ai/services/budget_service.dart';

void main() {
  group('BudgetService Tests', () {
    late BudgetService service;

    setUp(() {
      service = BudgetService();
    });

    test('Budget line amounts sum exactly to total budget and percentages sum to 100%', () {
      final context = EventContext(
        eventType: EventType.wedding,
        title: 'Test Wedding',
        eventDate: DateTime.now().add(const Duration(days: 90)),
        guestCount: 250,
        totalBudget: 1500000,
        city: 'Mumbai',
      );

      final plan = service.calculateBudget(context);

      final sumAmount = plan.lines.map((l) => l.amount).reduce((a, b) => a + b);
      final sumPct = plan.lines.map((l) => l.percentage).reduce((a, b) => a + b);

      expect(sumAmount, equals(1500000.0));
      expect(sumPct.round(), equals(100));
    });

    test('Feasibility evaluation marks tight budget correctly', () {
      final status = service.evaluateFeasibility(EventType.wedding, 900.0);
      expect(status, equals(FeasibilityStatus.tight));
    });

    test('Outdoor event increases venue/tent share', () {
      final indoorContext = EventContext(
        eventType: EventType.community,
        title: 'Indoor Rally',
        eventDate: DateTime.now().add(const Duration(days: 60)),
        guestCount: 100,
        totalBudget: 100000,
        isOutdoor: false,
      );

      final outdoorContext = indoorContext.copyWith(isOutdoor: true);

      final indoorPlan = service.calculateBudget(indoorContext);
      final outdoorPlan = service.calculateBudget(outdoorContext);

      final indoorStage = indoorPlan.lines.firstWhere((l) => l.category == 'Stage, Audio & Tent').percentage;
      final outdoorStage = outdoorPlan.lines.firstWhere((l) => l.category == 'Stage, Audio & Tent').percentage;

      expect(outdoorStage, greaterThan(indoorStage));
    });
  });
}
