import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/enums.dart';

import '../../state/checklist_controller.dart';

class VendorTab extends StatelessWidget {
  const VendorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChecklistController>(
      builder: (ctx, controller, _) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = controller.items;
        if (items.isEmpty) {
          return const Center(
            child: Text('No vendor items found for this event type.'),
          );
        }

        return Column(
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.indigo.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vendor Progress: ${controller.completedCount} of ${controller.totalCount} completed',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(controller.progressFraction * 100).round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: controller.progressFraction,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),

            // Vendor Checklist List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (ctx, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExpansionTile(
                      leading: Checkbox(
                        value: item.isCompleted,
                        onChanged: (_) => controller.toggleItem(item.id),
                        activeColor: Colors.indigo,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: item.isCompleted
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(top: 4, right: 6),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(item.priority)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.priority.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getPriorityColor(item.priority),
                              ),
                            ),
                          ),
                          Text(
                            item.leadTime,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      children: [
                        if (item.questionsToAsk.isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Questions to ask this vendor:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                          ),
                          ...item.questionsToAsk.map((q) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(
                                        q,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 8),
                        ]
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getPriorityColor(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.mustBook:
        return Colors.red.shade700;
      case PriorityLevel.recommended:
        return Colors.orange.shade800;
      case PriorityLevel.optional:
        return Colors.blue.shade700;
    }
  }
}
