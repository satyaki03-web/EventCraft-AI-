import 'package:flutter/material.dart';
import '../../core/formatters.dart';
import '../../models/enums.dart';
import '../../models/milestone.dart';
import 'rush_mode_banner.dart';

class TimelineTab extends StatelessWidget {
  final List<Milestone> milestones;
  final bool isRushMode;

  const TimelineTab({
    super.key,
    required this.milestones,
    required this.isRushMode,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRushMode) const RushModeBanner(),
          const Text(
            'Backward Planning Schedule',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          const Text(
            'Milestones are calculated dynamically backwards from your event date.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: milestones.length,
            itemBuilder: (ctx, index) {
              final m = milestones[index];
              return _MilestoneCard(milestone: m);
            },
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final Milestone milestone;

  const _MilestoneCard({required this.milestone});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color statusColor;

    switch (milestone.status) {
      case MilestoneStatus.upcoming:
        icon = Icons.event;
        statusColor = Colors.blue.shade700;
        break;
      case MilestoneStatus.dueSoon:
        icon = Icons.alarm;
        statusColor = Colors.orange.shade800;
        break;
      case MilestoneStatus.overdue:
        icon = Icons.error_outline;
        statusColor = Colors.red.shade700;
        break;
      case MilestoneStatus.completed:
        icon = Icons.check_circle;
        statusColor = Colors.green.shade700;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          milestone.timeFrameLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Target: ${AppFormatters.formatShortDate(milestone.dueDate)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    milestone.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    milestone.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(icon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        milestone.status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
