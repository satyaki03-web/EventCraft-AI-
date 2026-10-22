import 'package:flutter/material.dart';
import '../../core/formatters.dart';
import '../../models/budget_plan.dart';
import '../../models/event_context.dart';
import 'budget_bar_chart.dart';
import 'status_chip.dart';

class BudgetTab extends StatelessWidget {
  final EventContext context;
  final BudgetPlan plan;

  const BudgetTab({
    super.key,
    required this.context,
    required this.plan,
  });

  @override
  Widget build(BuildContext context) {
    final sym = plan.currencySymbol;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Feasibility Summary Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Budget: ${AppFormatters.formatCurrency(plan.totalBudget, symbol: sym)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      StatusChip(status: plan.feasibilityStatus),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cost per Guest: ${AppFormatters.formatCurrency(plan.costPerGuest, symbol: sym)} (${this.context.guestCount} guests)',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                  const Divider(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.tips_and_updates, color: Colors.indigo, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan.advice,
                          style: const TextStyle(fontSize: 13, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Accessible Bar Visualization
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BudgetBarChart(
                lines: plan.lines,
                currencySymbol: sym,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Budget Table
          const Text(
            'Detailed Category Allocation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: plan.lines.length,
            itemBuilder: (ctx, index) {
              final line = plan.lines[index];
              final amtFormatted = AppFormatters.formatCurrency(
                line.amount,
                symbol: sym,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        line.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        amtFormatted,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            line.note,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${line.percentage}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
