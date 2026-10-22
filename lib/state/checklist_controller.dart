import 'package:flutter/foundation.dart';
import '../models/event_context.dart';
import '../models/vendor_item.dart';
import '../services/storage_service.dart';
import '../services/vendor_service.dart';

/// State controller managing interactive vendor checklist and persistence.
class ChecklistController extends ChangeNotifier {
  final VendorService _vendorService;
  final StorageService _storageService;

  List<VendorItem> _items = [];
  bool _isLoading = false;

  ChecklistController({
    VendorService? vendorService,
    StorageService? storageService,
  })  : _vendorService = vendorService ?? VendorService(),
        _storageService = storageService ?? StorageService();

  List<VendorItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  int get completedCount => _items.where((i) => i.isCompleted).length;
  int get totalCount => _items.length;
  double get progressFraction =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  /// Generate or update items based on event context and apply saved progress
  Future<void> updateForContext(EventContext context) async {
    _isLoading = true;
    notifyListeners();

    final rawItems = _vendorService.generateVendorChecklist(context);
    final savedProgress = await _storageService.loadChecklistProgress();

    _items = rawItems.map((item) {
      final isDone = savedProgress[item.id] ?? false;
      return item.copyWith(isCompleted: isDone);
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  /// Toggle item completion and save to local storage
  Future<void> toggleItem(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    final current = _items[index];
    _items[index] = current.copyWith(isCompleted: !current.isCompleted);
    notifyListeners();

    final progressMap = {for (final item in _items) item.id: item.isCompleted};
    await _storageService.saveChecklistProgress(progressMap);
  }
}
