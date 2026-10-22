import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventcraft_ai/app.dart';

void main() {
  testWidgets('InputScreen renders title and form fields correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const EventCraftApp());
    await tester.pumpAndSettle();

    expect(find.text('EventCraft AI Planner'), findsOneWidget);
    expect(find.text('Event Name / Title'), findsOneWidget);
    expect(find.text('Generate Event Plan'), findsOneWidget);
  });

  testWidgets('Form validation triggers on empty submission', (WidgetTester tester) async {
    await tester.pumpWidget(const EventCraftApp());
    await tester.pumpAndSettle();

    // Clear event title text
    final titleField = find.widgetWithText(TextFormField, 'Event Name / Title');
    await tester.enterText(titleField, '');

    final submitButton = find.text('Generate Event Plan');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter an event name'), findsOneWidget);
  });
}
