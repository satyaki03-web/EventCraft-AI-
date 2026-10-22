import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_context.dart';

/// Storage service using shared_preferences for non-sensitive local persistence.
class StorageService {
  static const String _keyVendorChecklist = 'eventcraft_vendor_checklist';
  static const String _keyLastContext = 'eventcraft_last_context';

  /// Save vendor item completion statuses (map of itemId -> bool)
  Future<void> saveChecklistProgress(Map<String, bool> progressMap) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(progressMap);
    await prefs.setString(_keyVendorChecklist, jsonStr);
  }

  /// Load vendor item completion statuses
  Future<Map<String, bool>> loadChecklistProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyVendorChecklist);
    if (jsonStr == null || jsonStr.isEmpty) return {};

    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v as bool));
    } catch (_) {
      return {};
    }
  }

  /// Save last form inputs
  Future<void> saveLastEventContext(EventContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(context.toJson());
    await prefs.setString(_keyLastContext, jsonStr);
  }

  /// Load last form inputs
  Future<EventContext?> loadLastEventContext() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyLastContext);
    if (jsonStr == null || jsonStr.isEmpty) return null;

    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      return EventContext.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
