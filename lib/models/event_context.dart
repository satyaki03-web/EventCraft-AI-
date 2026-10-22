import 'enums.dart';

/// Represents all user-provided event details and preferences. Immutable.
class EventContext {
  final EventType eventType;
  final String title;
  final DateTime eventDate;
  final int guestCount;
  final double totalBudget;
  final String currencySymbol;
  final String currencyCode;
  final String city;
  final bool isOutdoor;
  final List<String> dietaryRequirements;
  final String themePreference;
  final String additionalNotes;

  const EventContext({
    required this.eventType,
    required this.title,
    required this.eventDate,
    required this.guestCount,
    required this.totalBudget,
    this.currencySymbol = '₹',
    this.currencyCode = 'INR',
    this.city = 'Mumbai',
    this.isOutdoor = false,
    this.dietaryRequirements = const [],
    this.themePreference = 'Classic & Elegant',
    this.additionalNotes = '',
  });

  EventContext copyWith({
    EventType? eventType,
    String? title,
    DateTime? eventDate,
    int? guestCount,
    double? totalBudget,
    String? currencySymbol,
    String? currencyCode,
    String? city,
    bool? isOutdoor,
    List<String>? dietaryRequirements,
    String? themePreference,
    String? additionalNotes,
  }) {
    return EventContext(
      eventType: eventType ?? this.eventType,
      title: title ?? this.title,
      eventDate: eventDate ?? this.eventDate,
      guestCount: guestCount ?? this.guestCount,
      totalBudget: totalBudget ?? this.totalBudget,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
      city: city ?? this.city,
      isOutdoor: isOutdoor ?? this.isOutdoor,
      dietaryRequirements: dietaryRequirements ?? this.dietaryRequirements,
      themePreference: themePreference ?? this.themePreference,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }

  /// Unique hash identifier for caching AI results
  String get cacheKey {
    final dateStr = '${eventDate.year}-${eventDate.month}-${eventDate.day}';
    final diets = dietaryRequirements.join(',');
    return '${eventType.name}|$title|$dateStr|$guestCount|$totalBudget|$currencyCode|$city|$isOutdoor|$diets|$themePreference';
  }

  Map<String, dynamic> toJson() => {
        'eventType': eventType.name,
        'title': title,
        'eventDate': eventDate.toIso8601String(),
        'guestCount': guestCount,
        'totalBudget': totalBudget,
        'currencySymbol': currencySymbol,
        'currencyCode': currencyCode,
        'city': city,
        'isOutdoor': isOutdoor,
        'dietaryRequirements': dietaryRequirements,
        'themePreference': themePreference,
        'additionalNotes': additionalNotes,
      };

  factory EventContext.fromJson(Map<String, dynamic> json) {
    return EventContext(
      eventType: EventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => EventType.wedding,
      ),
      title: json['title'] as String? ?? 'My Event',
      eventDate: DateTime.tryParse(json['eventDate'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 90)),
      guestCount: json['guestCount'] as int? ?? 100,
      totalBudget: (json['totalBudget'] as num? ?? 500000).toDouble(),
      currencySymbol: json['currencySymbol'] as String? ?? '₹',
      currencyCode: json['currencyCode'] as String? ?? 'INR',
      city: json['city'] as String? ?? 'Mumbai',
      isOutdoor: json['isOutdoor'] as bool? ?? false,
      dietaryRequirements:
          List<String>.from(json['dietaryRequirements'] as List? ?? []),
      themePreference: json['themePreference'] as String? ?? 'Classic',
      additionalNotes: json['additionalNotes'] as String? ?? '',
    );
  }
}
