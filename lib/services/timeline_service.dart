import '../models/enums.dart';
import '../models/event_context.dart';
import '../models/milestone.dart';

/// Pure Dart backward-planning timeline generator with injectable clock for deterministic testing.
class TimelineService {
  final DateTime Function() _now;

  TimelineService({DateTime Function()? nowProvider})
      : _now = nowProvider ?? DateTime.now;

  /// Generate backward milestone plan
  List<Milestone> generateTimeline(EventContext context) {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(
      context.eventDate.year,
      context.eventDate.month,
      context.eventDate.day,
    );

    final daysRemaining = eventDay.difference(today).inDays;
    final isRushMode = daysRemaining < 30;

    // Milestone definitions: offset in days before event, title, description
    final rawMilestones = _getRawMilestones(context.eventType, daysRemaining);

    final List<Milestone> milestones = [];

    // Prepend immediate kickoff milestone if window is open
    if (daysRemaining > 3) {
      final kickoffOffset = daysRemaining < 30 ? 1 : 2;
      final kickoffDate = today.add(Duration(days: kickoffOffset));
      String kickoffTitle = 'Immediate Kickoff & Budget Lock';
      String kickoffDesc = 'Lock total budget and core guest estimates.';
      if (daysRemaining < 30) {
        kickoffTitle = 'Fast-Track Immediate Action (48 Hours)';
        kickoffDesc = 'Urgent compressed timeline: Lock venue contracts, catering deposits, and invitations immediately.';
      } else if (daysRemaining < 90) {
        kickoffTitle = 'Fast-Track Setup & Essential Bookings';
        kickoffDesc = 'Since event is within 3 months, expedite venue reservation and send invites without delay.';
      }

      milestones.add(Milestone(
        id: 'm_${context.eventType.name}_kickoff',
        title: kickoffTitle,
        description: kickoffDesc,
        dueDate: kickoffDate,
        timeFrameLabel: daysRemaining < 30 ? 'Immediate (48h)' : 'Kickoff',
        status: MilestoneStatus.dueSoon,
      ));
    }

    for (int i = 0; i < rawMilestones.length; i++) {
      final raw = rawMilestones[i];
      final targetOffsetDays = raw['offsetDays'] as int;

      // Mathematical Filtering:
      // 1. Must fit within the days remaining window
      if (targetOffsetDays > 0 && targetOffsetDays > daysRemaining) {
        continue;
      }
      // 2. If the event is less than 3 months away (daysRemaining < 90), do NOT generate 9 months or 6 months out
      if (daysRemaining < 90 && targetOffsetDays >= 90) {
        continue;
      }

      final dueDate = eventDay.subtract(Duration(days: targetOffsetDays));
      final status = _calculateStatus(dueDate, today, eventDay);

      milestones.add(Milestone(
        id: 'm_${context.eventType.name}_$i',
        title: raw['title'] as String,
        description: raw['description'] as String,
        dueDate: dueDate,
        timeFrameLabel: raw['label'] as String,
        status: status,
      ));
    }

    // Sort by due date ascending
    milestones.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return milestones;
  }

  /// Check if event is in Rush Mode (< 30 days)
  bool isRushMode(EventContext context) {
    final now = _now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(
      context.eventDate.year,
      context.eventDate.month,
      context.eventDate.day,
    );
    return eventDay.difference(today).inDays < 30;
  }

  MilestoneStatus _calculateStatus(DateTime dueDate, DateTime today, DateTime eventDay) {
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (dueDay.isBefore(today)) {
      return MilestoneStatus.overdue;
    }
    final daysToDue = dueDay.difference(today).inDays;
    if (daysToDue <= 7) {
      return MilestoneStatus.dueSoon;
    }
    return MilestoneStatus.upcoming;
  }

  List<Map<String, dynamic>> _getRawMilestones(EventType eventType, int daysRemaining) {
    switch (eventType) {
      case EventType.wedding:
        return [
          {
            'offsetDays': 360,
            'label': '12 Months Before',
            'title': 'Set Budget & Guest List',
            'description': 'Lock down total budget, estimated guest count, and draft key family priorities.',
          },
          {
            'offsetDays': 270,
            'label': '9 Months Before',
            'title': 'Book Venue & Caterer',
            'description': 'Reserve ceremony mandap/hall and finalize tasting session with caterers.',
          },
          {
            'offsetDays': 180,
            'label': '6 Months Before',
            'title': 'Hire Photographer & Decorator',
            'description': 'Book media team, decide on theme/colors, and order invitation cards.',
          },
          {
            'offsetDays': 90,
            'label': '3 Months Before',
            'title': 'Outfits & Send Invitations',
            'description': 'Finalize wedding attire fittings, dispatch physical/e-invites with RSVP link.',
          },
          {
            'offsetDays': 60,
            'label': '2 Months Before',
            'title': 'Book DJ, Makeup & Sound',
            'description': 'Confirm hair/makeup artist, DJ playlist, and sound/light setup.',
          },
          {
            'offsetDays': 30,
            'label': '1 Month Before',
            'title': 'Final RSVP & Vendor Walkthrough',
            'description': 'Lock headcounts with caterer and conduct venue walkthrough.',
          },
          {
            'offsetDays': 14,
            'label': '2 Weeks Before',
            'title': 'Seating & Return Gifts',
            'description': 'Finalize seating chart, pack return gift hampers, and assign family duties.',
          },
          {
            'offsetDays': 7,
            'label': '1 Week Before',
            'title': 'Pack Rehearsal Kits & Payments',
            'description': 'Prepare cash envelopes for vendor final payments and pack emergency kits.',
          },
          {
            'offsetDays': 0,
            'label': 'Event Day',
            'title': 'Execution & Celebration',
            'description': 'Coordinate morning arrivals, run timeline smoothly, and enjoy!',
          },
        ];

      case EventType.birthday:
        return [
          {
            'offsetDays': 90,
            'label': '3 Months Before',
            'title': 'Pick Theme & Venue',
            'description': 'Choose birthday theme, target budget, and reserve venue/hall.',
          },
          {
            'offsetDays': 60,
            'label': '2 Months Before',
            'title': 'Book Entertainer & Baker',
            'description': 'Reserve magician/emcee/game host and customize birthday cake order.',
          },
          {
            'offsetDays': 30,
            'label': '1 Month Before',
            'title': 'Send Invites & Order Decor',
            'description': 'Send digital invitations and order balloon arches and customized props.',
          },
          {
            'offsetDays': 14,
            'label': '2 Weeks Before',
            'title': 'Confirm RSVPs & Goodie Bags',
            'description': 'Assemble return gift bags according to confirmed guest count.',
          },
          {
            'offsetDays': 7,
            'label': '1 Week Before',
            'title': 'Playlist & Game Schedule',
            'description': 'Prepare party games, playlist, and re-confirm cake delivery time.',
          },
          {
            'offsetDays': 0,
            'label': 'Event Day',
            'title': 'Party Time',
            'description': 'Welcome guests, enjoy games, cake cutting, and gift distribution.',
          },
        ];

      case EventType.community:
        return [
          {
            'offsetDays': 120,
            'label': '4 Months Before',
            'title': 'Form Committee & Permits',
            'description': 'Establish volunteer leads, draft budget, and file municipal permits.',
          },
          {
            'offsetDays': 90,
            'label': '3 Months Before',
            'title': 'Book Venue & Audio Stage',
            'description': 'Reserve community hall/grounds and contract stage & sound vendor.',
          },
          {
            'offsetDays': 60,
            'label': '2 Months Before',
            'title': 'Sponsorship & Marketing',
            'description': 'Distribute flyers, reach local sponsors, and launch registration.',
          },
          {
            'offsetDays': 30,
            'label': '1 Month Before',
            'title': 'Volunteer Briefing & Catering',
            'description': 'Assign volunteer duties (security, registration, food distribution).',
          },
          {
            'offsetDays': 14,
            'label': '2 Weeks Before',
            'title': 'Signage & Equipment Check',
            'description': 'Print direction banners, check mic/speaker equipment and first aid kits.',
          },
          {
            'offsetDays': 0,
            'label': 'Event Day',
            'title': 'Community Gathering',
            'description': 'Stage setup at 6 AM, run event schedule, and manage cleanup committee.',
          },
        ];
    }
  }
}
