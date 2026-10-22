import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/plan_exporter.dart';
import '../../state/checklist_controller.dart';
import '../../state/plan_controller.dart';
import '../widgets/budget_tab.dart';
import '../widgets/chat_tab.dart';
import '../widgets/ideas_tab.dart';
import '../widgets/timeline_tab.dart';
import '../widgets/vendor_tab.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _exportCopy(BuildContext context, PlanController controller, ChecklistController checklist) {
    if (controller.context == null || controller.budgetPlan == null) return;

    final markdown = PlanExporter.buildMarkdownPlan(
      context: controller.context!,
      budgetPlan: controller.budgetPlan!,
      milestones: controller.milestones,
      vendors: checklist.items,
      ideas: controller.ideas,
    );

    PlanExporter.copyToClipboard(markdown);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Full plan copied to clipboard in Markdown format!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportShare(BuildContext context, PlanController controller, ChecklistController checklist) {
    if (controller.context == null || controller.budgetPlan == null) return;

    final markdown = PlanExporter.buildMarkdownPlan(
      context: controller.context!,
      budgetPlan: controller.budgetPlan!,
      milestones: controller.milestones,
      vendors: checklist.items,
      ideas: controller.ideas,
    );

    PlanExporter.sharePlan(markdown);
  }

  @override
  Widget build(BuildContext context) {
    final planCtrl = Provider.of<PlanController>(context);
    final checklistCtrl = Provider.of<ChecklistController>(context);

    final eventContext = planCtrl.context;
    final budgetPlan = planCtrl.budgetPlan;

    if (eventContext == null || budgetPlan == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No plan generated yet.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/input'),
                child: const Text('Go to Planner Input'),
              )
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            eventContext.title,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Event Details',
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy Plan as Markdown',
              onPressed: () => _exportCopy(context, planCtrl, checklistCtrl),
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Share Plan',
              onPressed: () => _exportShare(context, planCtrl, checklistCtrl),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.account_balance_wallet), text: 'Budget'),
              Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
              Tab(icon: Icon(Icons.checklist), text: 'Vendors'),
              Tab(icon: Icon(Icons.lightbulb_outline), text: 'Ideas'),
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Ask Planner'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: TabBarView(
              children: [
                BudgetTab(context: eventContext, plan: budgetPlan),
                TimelineTab(
                  milestones: planCtrl.milestones,
                  isRushMode: planCtrl.isRushMode,
                ),
                const VendorTab(),
                const IdeasTab(),
                const ChatTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
