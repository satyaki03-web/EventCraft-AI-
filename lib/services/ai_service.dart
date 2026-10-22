import '../models/event_context.dart';
import '../models/ideas_result.dart';

/// Abstract AI Service interface for GenAI features.
abstract class AiService {
  /// Generate structured personalized ideas for an event.
  Future<IdeasResult> generateIdeas(EventContext context);

  /// Ask the AI planner a question with event context injected.
  Future<String> askPlanner(EventContext context, String question);
}
