import '../core/constants.dart';
import '../models/budget_plan.dart';
import '../models/enums.dart';
import '../models/event_context.dart';

/// Pure Dart deterministic rule engine for budget allocations.
class BudgetService {
  /// Calculate a complete, exact budget plan.
  BudgetPlan calculateBudget(EventContext context) {
    final totalBudget = context.totalBudget;
    final guestCount = context.guestCount > 0 ? context.guestCount : 1;
    final costPerGuest = totalBudget / guestCount;

    // 1. Get Base Splits per EventType
    final Map<String, int> rawSplits = {};
    switch (context.eventType) {
      case EventType.wedding:
        rawSplits.addAll(AppConstants.weddingBaseSplits);
        break;
      case EventType.birthday:
        rawSplits.addAll(AppConstants.birthdayBaseSplits);
        break;
      case EventType.community:
        rawSplits.addAll(AppConstants.communityBaseSplits);
        break;
    }

    // 2. Adjust splits based on context
    final Map<String, double> adjustedSplits = {};
    rawSplits.forEach((key, val) => adjustedSplits[key] = val.toDouble());

    // Rule A: Large guest count (> 200) raises catering demand
    if (guestCount > 200) {
      if (adjustedSplits.containsKey('Catering & Food')) {
        adjustedSplits['Catering & Food'] = adjustedSplits['Catering & Food']! + 5.0;
        _reduceOthers(adjustedSplits, 'Catering & Food', 5.0);
      } else if (adjustedSplits.containsKey('Catering & Cake')) {
        adjustedSplits['Catering & Cake'] = adjustedSplits['Catering & Cake']! + 5.0;
        _reduceOthers(adjustedSplits, 'Catering & Cake', 5.0);
      }
    }

    // Rule B: Outdoor event raises tent / weather contingency
    if (context.isOutdoor) {
      if (adjustedSplits.containsKey('Venue & Decor')) {
        adjustedSplits['Venue & Decor'] = adjustedSplits['Venue & Decor']! + 3.0;
        _reduceOthers(adjustedSplits, 'Venue & Decor', 3.0);
      } else if (adjustedSplits.containsKey('Stage, Audio & Tent')) {
        adjustedSplits['Stage, Audio & Tent'] = adjustedSplits['Stage, Audio & Tent']! + 4.0;
        _reduceOthers(adjustedSplits, 'Stage, Audio & Tent', 4.0);
      }
    }

    // Rule C: Feasibility evaluation
    final feasibility = evaluateFeasibility(context.eventType, costPerGuest);

    // Rule D: Tight budget shifts spending away from decor/entertainment toward food & mandatory venue
    if (feasibility == FeasibilityStatus.tight || feasibility == FeasibilityStatus.unrealistic) {
      if (adjustedSplits.containsKey('Decor & Theme')) {
        final dec = 3.0;
        adjustedSplits['Decor & Theme'] = (adjustedSplits['Decor & Theme']! - dec).clamp(5.0, 50.0);
        if (adjustedSplits.containsKey('Catering & Cake')) {
          adjustedSplits['Catering & Cake'] = adjustedSplits['Catering & Cake']! + dec;
        }
      }
    }

    // 3. Normalize splits so they sum to 100.0 exactly
    final totalAdjusted = adjustedSplits.values.reduce((a, b) => a + b);
    final Map<String, double> normalizedPercentages = {};
    adjustedSplits.forEach((k, v) {
      normalizedPercentages[k] = (v / totalAdjusted) * 100.0;
    });

    // 4. Round percentages and amounts using largest-remainder method so totals match exactly
    final lines = _allocateExactAmounts(totalBudget, normalizedPercentages, context.currencySymbol);

    // 5. Generate plain-language advice
    final advice = _generateAdvice(context, costPerGuest, feasibility);

    return BudgetPlan(
      totalBudget: totalBudget,
      currencySymbol: context.currencySymbol,
      costPerGuest: costPerGuest,
      feasibilityStatus: feasibility,
      advice: advice,
      lines: lines,
    );
  }

  /// Evaluate feasibility status based on thresholds per event type.
  FeasibilityStatus evaluateFeasibility(EventType type, double costPerGuest) {
    switch (type) {
      case EventType.wedding:
        if (costPerGuest >= AppConstants.weddingComfortableMin) {
          return FeasibilityStatus.comfortable;
        } else if (costPerGuest >= AppConstants.weddingTightMin) {
          return FeasibilityStatus.tight;
        } else {
          return FeasibilityStatus.unrealistic;
        }
      case EventType.birthday:
        if (costPerGuest >= AppConstants.birthdayComfortableMin) {
          return FeasibilityStatus.comfortable;
        } else if (costPerGuest >= AppConstants.birthdayTightMin) {
          return FeasibilityStatus.tight;
        } else {
          return FeasibilityStatus.unrealistic;
        }
      case EventType.community:
        if (costPerGuest >= AppConstants.communityComfortableMin) {
          return FeasibilityStatus.comfortable;
        } else if (costPerGuest >= AppConstants.communityTightMin) {
          return FeasibilityStatus.tight;
        } else {
          return FeasibilityStatus.unrealistic;
        }
    }
  }

  void _reduceOthers(Map<String, double> splits, String preserveKey, double amount) {
    final keysToReduce = splits.keys.where((k) => k != preserveKey && k != 'Contingency Fund').toList();
    if (keysToReduce.isEmpty) return;
    final perKeyReduction = amount / keysToReduce.length;
    for (final k in keysToReduce) {
      splits[k] = (splits[k]! - perKeyReduction).clamp(3.0, 60.0);
    }
  }

  /// Allocates integer minor units / largest remainder to ensure sum(amounts) == totalBudget exactly
  List<BudgetLine> _allocateExactAmounts(
    double totalBudget,
    Map<String, double> percentages,
    String currencySymbol,
  ) {
    final categoryList = percentages.keys.toList();
    final doubleBudget = totalBudget;

    // Convert total budget to minor integer units (rounded)
    final totalUnits = doubleBudget.round();
    final Map<String, int> integerAmounts = {};
    final Map<String, double> remainders = {};

    int currentSum = 0;
    for (final category in categoryList) {
      final floatAmount = (percentages[category]! / 100.0) * totalUnits;
      final intPart = floatAmount.floor();
      integerAmounts[category] = intPart;
      remainders[category] = floatAmount - intPart;
      currentSum += intPart;
    }

    int discrepancy = totalUnits - currentSum;
    if (discrepancy > 0) {
      // Sort categories by remainder descending
      final sortedByRemainder = categoryList.toList()
        ..sort((a, b) => remainders[b]!.compareTo(remainders[a]!));
      for (int i = 0; i < discrepancy && i < sortedByRemainder.length; i++) {
        integerAmounts[sortedByRemainder[i]] = integerAmounts[sortedByRemainder[i]]! + 1;
      }
    }

    final List<BudgetLine> lines = [];
    for (final cat in categoryList) {
      final amt = integerAmounts[cat]!.toDouble();
      final pct = (amt / totalUnits) * 100.0;
      lines.add(BudgetLine(
        category: cat,
        amount: amt,
        percentage: double.parse(pct.toStringAsFixed(1)),
        note: _getCategoryNote(cat),
      ));
    }

    return lines;
  }

  String _getCategoryNote(String category) {
    switch (category) {
      case 'Catering & Food':
      case 'Catering & Cake':
      case 'Food & Beverages':
        return 'Includes main meals, appetizers, live stalls, and beverages.';
      case 'Venue & Decor':
      case 'Decor & Theme':
        return 'Mandap, stage setup, floral arrangements, and lighting.';
      case 'Photography & Media':
        return 'Candid photography, videography, and drone coverage.';
      case 'Attire & Makeup':
        return 'Bridal/groom outfits and professional makeup artists.';
      case 'Music & Entertainment':
      case 'Entertainment & Games':
        return 'DJ, live band, sound system, and emcee/host.';
      case 'Stage, Audio & Tent':
        return 'Audio setup, stage fabrication, and weather canopy.';
      case 'Logistics & Permits':
        return 'Local civic permits, sound licenses, and parking setup.';
      case 'Contingency Fund':
        return 'Emergency buffer for unforeseen expenses or price changes.';
      default:
        return 'Allocated budget for event requirements.';
    }
  }

  String _generateAdvice(EventContext context, double costPerGuest, FeasibilityStatus status) {
    final sym = context.currencySymbol;
    final formattedCpg = '$sym${costPerGuest.toStringAsFixed(0)}';

    switch (status) {
      case FeasibilityStatus.comfortable:
        return 'At $formattedCpg per guest in ${context.city}, your budget is healthy and well-balanced! You have comfortable room for premium menu items and custom decor.';
      case FeasibilityStatus.tight:
        return 'At $formattedCpg per guest, your budget is tight. Consider prioritizing high-impact catering per plate and streamlining floral or print decor.';
      case FeasibilityStatus.unrealistic:
        return 'At $formattedCpg per guest in ${context.city}, costs may exceed your limit. We recommend reducing the guest count or opting for a buffet/community venue to avoid budget deficit.';
    }
  }
}
