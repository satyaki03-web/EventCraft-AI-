/// Core application constants, defaults, and thresholds.
/// Contains no magic numbers.
class AppConstants {
  // Budget Feasibility Thresholds (Cost per guest in INR default)
  static const double weddingComfortableMin = 1500.0;
  static const double weddingTightMin = 800.0;

  static const double birthdayComfortableMin = 800.0;
  static const double birthdayTightMin = 400.0;

  static const double communityComfortableMin = 400.0;
  static const double communityTightMin = 150.0;

  // Rate Limiting & Cooldown
  static const int aiCooldownSeconds = 10;
  static const int aiMaxCallsPerMinute = 5;
  static const int aiTimeoutSeconds = 20;

  // Cache
  static const int lruCacheCapacity = 20;

  // Input Sanitization Limits
  static const int maxEventNameLength = 80;
  static const int maxCityLength = 60;
  static const int maxPreferencesLength = 300;
  static const int maxChatQuestionLength = 250;
  static const int maxGuestCount = 50000;
  static const double maxBudgetAmount = 100000000.0; // 10 Cr

  // Default Budget Category Splits (Percentages as integers summing to 100)
  static const Map<String, int> weddingBaseSplits = {
    'Catering & Food': 35,
    'Venue & Decor': 25,
    'Photography & Media': 15,
    'Attire & Makeup': 10,
    'Music & Entertainment': 7,
    'Contingency Fund': 8,
  };

  static const Map<String, int> birthdayBaseSplits = {
    'Catering & Cake': 40,
    'Decor & Theme': 20,
    'Entertainment & Games': 15,
    'Venue Rental': 10,
    'Return Gifts / Favors': 8,
    'Contingency Fund': 7,
  };

  static const Map<String, int> communityBaseSplits = {
    'Food & Beverages': 35,
    'Stage, Audio & Tent': 25,
    'Logistics & Permits': 15,
    'Marketing & Printing': 10,
    'Volunteer Hospitality': 7,
    'Contingency Fund': 8,
  };

  // Supported Currencies
  static const List<Map<String, String>> currencies = [
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee (INR)'},
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar (USD)'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro (EUR)'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound (GBP)'},
    {'code': 'AED', 'symbol': 'AED', 'name': 'UAE Dirham (AED)'},
  ];
}
