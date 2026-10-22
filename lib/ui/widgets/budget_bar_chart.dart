import 'package:flutter/material.dart';
import '../../core/formatters.dart';
import '../../models/budget_plan.dart';

/// Lightweight accessible custom budget bar chart.
class BudgetBarChart extends StatelessWidget {
  final List<BudgetLine> lines;
  final String currencySymbol;

  const BudgetBarChart({
    super.key,
    required this.lines,
    required this.currencySymbol,
  });

  static const List<Color> _barColors = [
    Color(0xFF3F51B5), // Indigo
    Color(0xFF009688), // Teal
    Color(0xFFFF9800), // Orange
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF607D8B), // Blue Grey
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visual Share Allocation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 24,
            child: Row(
              children: List.generate(lines.length, (index) {
                final line = lines[index];
                final color = _barColors[index % _barColors.length];
                final formattedAmt = AppFormatters.formatCurrency(
                  line.amount,
                  symbol: currencySymbol,
                );

                return Expanded(
                  flex: (line.percentage * 10).round().clamp(1, 1000),
                  child: Semantics(
                    label:
                        '${line.category}, ${line.percentage.toStringAsFixed(1)} percent, $formattedAmt',
                    child: Container(
                      color: color,
                      margin: const EdgeInsets.only(right: 1),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: List.generate(lines.length, (index) {
            final line = lines[index];
            final color = _barColors[index % _barColors.length];

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(
                  '${line.category} (${line.percentage}%)',
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
