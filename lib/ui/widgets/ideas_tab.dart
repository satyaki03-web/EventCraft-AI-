import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ideas_result.dart';
import '../../state/plan_controller.dart';

class IdeasTab extends StatelessWidget {
  const IdeasTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlanController>(
      builder: (ctx, controller, _) {
        final ideas = controller.ideas;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: controller.isLoadingIdeas
                    ? null
                    : () => controller.fetchIdeas(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: controller.isLoadingIdeas
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  controller.isLoadingIdeas
                      ? 'Generating Gemini Recommendations...'
                      : (ideas == null
                          ? 'Generate Creative Ideas with Gemini AI'
                          : 'Regenerate Ideas'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (ideas != null && ideas.isFallback)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wifi_off, color: Colors.amber.shade900, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Showing curated offline ideas. (To enable live Gemini generation, configure GEMINI_API_KEY).',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (ideas == null && !controller.isLoadingIdeas) ...[
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 48,
                          color: Colors.indigo,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ready to craft unique event ideas?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button above to receive customized themes, decor concepts, menu highlights, and day-of schedules tailored to your event in ${controller.context?.city}.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (ideas != null) ...[
                _buildIdeaSection('🎨 Theme Concept', ideas.themeSummary, isHeader: true),
                _buildIdeaList('🌺 Decor & Lighting Highlights', ideas.decorIdeas),
                _buildIdeaList('🍲 Menu & Food Highlights', ideas.menuHighlights),
                _buildIdeaList('🎯 Interactive Guest Activities', ideas.interactiveActivities),
                _buildIdeaList('🎶 Music & Entertainment', ideas.entertainmentOptions),
                _buildIdeaList('🎁 Return Gifts & Favors', ideas.returnGiftIdeas),
                _buildIdeaList('⏰ Sample Day-of Schedule', ideas.sampleDayOfSchedule),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdeaSection(String title, String content, {bool isHeader = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeaList(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 13, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
