import 'enums.dart';

/// Single budget line item. Immutable.
class BudgetLine {
  final String category;
  final double amount;
  final double percentage; // e.g. 35.0 for 35%
  final String note;

  const BudgetLine({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.note,
  });
}

/// Complete budget plan computed deterministically.
class BudgetPlan {
  final double totalBudget;
  final String currencySymbol;
  final double costPerGuest;
  final FeasibilityStatus feasibilityStatus;
  final String advice;
  final List<BudgetLine> lines;

  const BudgetPlan({
    required this.totalBudget,
    required this.currencySymbol,
    required this.costPerGuest,
    required this.feasibilityStatus,
    required this.advice,
    required this.lines,
  });
}
