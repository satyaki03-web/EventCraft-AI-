import 'package:flutter/material.dart';
import '../../models/enums.dart';

/// Accessible status chip displaying status with icon and text, not color alone.
class StatusChip extends StatelessWidget {
  final FeasibilityStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label = status.displayName;

    switch (status) {
      case FeasibilityStatus.comfortable:
        icon = Icons.check_circle_outline;
        color = Colors.green.shade700;
        break;
      case FeasibilityStatus.tight:
        icon = Icons.info_outline;
        color = Colors.orange.shade800;
        break;
      case FeasibilityStatus.unrealistic:
        icon = Icons.warning_amber_rounded;
        color = Colors.red.shade700;
        break;
    }

    return Semantics(
      label: 'Budget Feasibility Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
