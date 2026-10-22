import 'enums.dart';

/// Single vendor checklist task. Immutable.
class VendorItem {
  final String id;
  final String category;
  final String name;
  final PriorityLevel priority;
  final String leadTime;
  final List<String> questionsToAsk;
  final bool isCompleted;

  const VendorItem({
    required this.id,
    required this.category,
    required this.name,
    required this.priority,
    required this.leadTime,
    required this.questionsToAsk,
    this.isCompleted = false,
  });

  VendorItem copyWith({
    String? id,
    String? category,
    String? name,
    PriorityLevel? priority,
    String? leadTime,
    List<String>? questionsToAsk,
    bool? isCompleted,
  }) {
    return VendorItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      priority: priority ?? this.priority,
      leadTime: leadTime ?? this.leadTime,
      questionsToAsk: questionsToAsk ?? this.questionsToAsk,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
