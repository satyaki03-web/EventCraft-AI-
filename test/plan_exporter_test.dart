import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_ai/models/enums.dart';
import 'package:eventcraft_ai/models/event_context.dart';
import 'package:eventcraft_ai/services/budget_service.dart';
import 'package:eventcraft_ai/services/plan_exporter.dart';
import 'package:eventcraft_ai/services/timeline_service.dart';
import 'package:eventcraft_ai/services/vendor_service.dart';

void main() {
  group('PlanExporter Tests', () {
    test('buildMarkdownPlan generates valid markdown with headers and tables', () {
      final context = EventContext(
        eventType: EventType.birthday,
        title: 'Maya 10th Birthday',
        eventDate: DateTime(2026, 12, 1),
        guestCount: 50,
        totalBudget: 50000,
        city: 'Delhi',
      );

      final budgetPlan = BudgetService().calculateBudget(context);
      final milestones = TimelineService().generateTimeline(context);
      final vendors = VendorService().generateVendorChecklist(context);

      final markdown = PlanExporter.buildMarkdownPlan(
        context: context,
        budgetPlan: budgetPlan,
        milestones: milestones,
        vendors: vendors,
      );

      expect(markdown, contains('# EventCraft AI Plan: Maya 10th Birthday'));
      expect(markdown, contains('## 💰 Budget Breakdown'));
      expect(markdown, contains('## 📅 Timeline & Milestones'));
      expect(markdown, contains('## 📋 Vendor Checklist'));
    });
  });
}
