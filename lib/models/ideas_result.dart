/// Holds structured GenAI recommendations. Immutable.
class IdeasResult {
  final String themeSummary;
  final List<String> decorIdeas;
  final List<String> menuHighlights;
  final List<String> interactiveActivities;
  final List<String> entertainmentOptions;
  final List<String> returnGiftIdeas;
  final List<String> sampleDayOfSchedule;
  final bool isFallback;

  const IdeasResult({
    required this.themeSummary,
    required this.decorIdeas,
    required this.menuHighlights,
    required this.interactiveActivities,
    required this.entertainmentOptions,
    required this.returnGiftIdeas,
    required this.sampleDayOfSchedule,
    this.isFallback = false,
  });

  factory IdeasResult.fromJson(Map<String, dynamic> json, {bool isFallback = false}) {
    return IdeasResult(
      themeSummary: json['themeSummary'] as String? ?? 'Custom Event Theme Concept',
      decorIdeas: _toStringList(json['decorIdeas']),
      menuHighlights: _toStringList(json['menuHighlights']),
      interactiveActivities: _toStringList(json['interactiveActivities']),
      entertainmentOptions: _toStringList(json['entertainmentOptions']),
      returnGiftIdeas: _toStringList(json['returnGiftIdeas']),
      sampleDayOfSchedule: _toStringList(json['sampleDayOfSchedule']),
      isFallback: isFallback,
    );
  }

  static List<String> _toStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return const [];
  }

  Map<String, dynamic> toJson() => {
        'themeSummary': themeSummary,
        'decorIdeas': decorIdeas,
        'menuHighlights': menuHighlights,
        'interactiveActivities': interactiveActivities,
        'entertainmentOptions': entertainmentOptions,
        'returnGiftIdeas': returnGiftIdeas,
        'sampleDayOfSchedule': sampleDayOfSchedule,
        'isFallback': isFallback,
      };
}
