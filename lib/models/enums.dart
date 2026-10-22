/// Core domain enums used across EventCraft AI.

enum EventType {
  wedding,
  birthday,
  community;

  String get displayName {
    switch (this) {
      case EventType.wedding:
        return 'Wedding / Reception';
      case EventType.birthday:
        return 'Birthday Party';
      case EventType.community:
        return 'Community / NGO Event';
    }
  }
}

enum PriorityLevel {
  mustBook,
  recommended,
  optional;

  String get displayName {
    switch (this) {
      case PriorityLevel.mustBook:
        return 'Must Book Early';
      case PriorityLevel.recommended:
        return 'Recommended';
      case PriorityLevel.optional:
        return 'Optional / Add-on';
    }
  }
}

enum FeasibilityStatus {
  comfortable,
  tight,
  unrealistic;

  String get displayName {
    switch (this) {
      case FeasibilityStatus.comfortable:
        return 'Comfortable Budget';
      case FeasibilityStatus.tight:
        return 'Tight / Selective Budget';
      case FeasibilityStatus.unrealistic:
        return 'Unrealistic Budget';
    }
  }
}

enum MilestoneStatus {
  upcoming,
  dueSoon,
  overdue,
  completed;

  String get displayName {
    switch (this) {
      case MilestoneStatus.upcoming:
        return 'Upcoming';
      case MilestoneStatus.dueSoon:
        return 'Due Soon';
      case MilestoneStatus.overdue:
        return 'Overdue!';
      case MilestoneStatus.completed:
        return 'Completed';
    }
  }
}
