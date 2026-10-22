import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_ai/models/enums.dart';
import 'package:eventcraft_ai/models/event_context.dart';
import 'package:eventcraft_ai/services/vendor_service.dart';

void main() {
  group('VendorService Tests', () {
    late VendorService service;

    setUp(() {
      service = VendorService();
    });

    test('Outdoor event includes generator and tent vendor items', () {
      final context = EventContext(
        eventType: EventType.wedding,
        title: 'Lawn Wedding',
        eventDate: DateTime.now().add(const Duration(days: 90)),
        guestCount: 200,
        totalBudget: 1000000,
        isOutdoor: true,
      );

      final items = service.generateVendorChecklist(context);
      final hasTent = items.any((i) => i.id == 'v_outdoor_tent');
      final hasGen = items.any((i) => i.id == 'v_outdoor_gen');

      expect(hasTent, isTrue);
      expect(hasGen, isTrue);
    });

    test('Jain dietary requirement adapts caterer item title', () {
      final context = EventContext(
        eventType: EventType.wedding,
        title: 'Jain Wedding',
        eventDate: DateTime.now().add(const Duration(days: 90)),
        guestCount: 200,
        totalBudget: 1000000,
        dietaryRequirements: const ['Jain'],
      );

      final items = service.generateVendorChecklist(context);
      final caterer = items.firstWhere((i) => i.id == 'v_w_caterer');

      expect(caterer.name.contains('Jain'), isTrue);
    });
  });
}
