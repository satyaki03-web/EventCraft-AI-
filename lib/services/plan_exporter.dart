import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../core/formatters.dart';
import '../models/budget_plan.dart';
import '../models/event_context.dart';
import '../models/ideas_result.dart';
import '../models/milestone.dart';
import '../models/vendor_item.dart';

/// Service to format and export event plan into Markdown with copy and share actions.
class PlanExporter {
  /// Build full Markdown document string
  static String buildMarkdownPlan({
    required EventContext context,
    required BudgetPlan budgetPlan,
    required List<Milestone> milestones,
    required List<VendorItem> vendors,
    IdeasResult? ideas,
  }) {
    final buffer = StringBuffer();
    final sym = context.currencySymbol;

    buffer.writeln('# EventCraft AI Plan: ${context.title}');
    buffer.writeln('**Generated on:** ${AppFormatters.formatShortDate(DateTime.now())}\n');

    buffer.writeln('## 📌 Event Details');
    buffer.writeln('- **Event Type:** ${context.eventType.displayName}');
    buffer.writeln('- **Event Date:** ${AppFormatters.formatShortDate(context.eventDate)}');
    buffer.writeln('- **Location:** ${context.city}');
    buffer.writeln('- **Guest Count:** ${context.guestCount} guests');
    buffer.writeln('- **Total Budget:** $sym${context.totalBudget.toStringAsFixed(0)} (${context.currencyCode})');
    buffer.writeln('- **Setting:** ${context.isOutdoor ? "Outdoor Venue" : "Indoor Venue"}');
    if (context.dietaryRequirements.isNotEmpty) {
      buffer.writeln('- **Dietary:** ${context.dietaryRequirements.join(", ")}');
    }
    buffer.writeln('- **Theme:** ${context.themePreference}\n');

    buffer.writeln('## 💰 Budget Breakdown');
    buffer.writeln('**Status:** ${budgetPlan.feasibilityStatus.displayName}');
    buffer.writeln('**Cost per Guest:** $sym${budgetPlan.costPerGuest.toStringAsFixed(0)}');
    buffer.writeln('**Planner Advice:** ${budgetPlan.advice}\n');

    buffer.writeln('| Category | Amount | Share | Notes |');
    buffer.writeln('| :--- | :--- | :--- | :--- |');
    for (final line in budgetPlan.lines) {
      final amtFormatted = AppFormatters.formatCurrency(line.amount, symbol: sym);
      buffer.writeln('| ${line.category} | $amtFormatted | ${line.percentage}% | ${line.note} |');
    }
    buffer.writeln('');

    buffer.writeln('## 📅 Timeline & Milestones');
    for (final m in milestones) {
      final dateStr = AppFormatters.formatShortDate(m.dueDate);
      buffer.writeln('- [ ] **[${m.timeFrameLabel}]** ${m.title} *($dateStr)*: ${m.description}');
    }
    buffer.writeln('');

    buffer.writeln('## 📋 Vendor Checklist');
    for (final v in vendors) {
      final statusCheck = v.isCompleted ? '[x]' : '[ ]';
      buffer.writeln('- $statusCheck **${v.name}** (${v.category}) — *${v.priority.displayName}*');
      if (v.questionsToAsk.isNotEmpty) {
        for (final q in v.questionsToAsk) {
          buffer.writeln('  - Question: "$q"');
        }
      }
    }
    buffer.writeln('');

    if (ideas != null) {
      buffer.writeln('## 💡 Gemini Creative Ideas');
      buffer.writeln('### Theme Concept');
      buffer.writeln('${ideas.themeSummary}\n');

      buffer.writeln('### Decor Highlights');
      for (final d in ideas.decorIdeas) {
        buffer.writeln('- $d');
      }
      buffer.writeln('');

      buffer.writeln('### Menu Highlights');
      for (final m in ideas.menuHighlights) {
        buffer.writeln('- $m');
      }
      buffer.writeln('');

      buffer.writeln('### Day-of Sample Schedule');
      for (final s in ideas.sampleDayOfSchedule) {
        buffer.writeln('- $s');
      }
      buffer.writeln('');
    }

    buffer.writeln('---\n*Created with EventCraft AI - GenAI Event Assistant*');

    return buffer.toString();
  }

  /// Copy markdown plan to clipboard
  static Future<void> copyToClipboard(String markdownText) async {
    await Clipboard.setData(ClipboardData(text: markdownText));
  }

  /// Share plan via system share modal
  static Future<void> sharePlan(String markdownText) async {
    await Share.share(markdownText, subject: 'EventCraft AI Plan');
  }
}
