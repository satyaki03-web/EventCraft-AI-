import 'enums.dart';

/// Single milestone on event timeline. Immutable.
class Milestone {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String timeFrameLabel; // e.g., "12 Months Before", "2 Weeks Before"
  final MilestoneStatus status;

  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.timeFrameLabel,
    required this.status,
  });

  Milestone copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? timeFrameLabel,
    MilestoneStatus? status,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      timeFrameLabel: timeFrameLabel ?? this.timeFrameLabel,
      status: status ?? this.status,
    );
  }
}
