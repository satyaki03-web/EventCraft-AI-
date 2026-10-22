import 'package:flutter/foundation.dart';
import '../models/budget_plan.dart';
import '../models/enums.dart';
import '../models/event_context.dart';
import '../models/ideas_result.dart';
import '../models/milestone.dart';
import '../services/ai_service.dart';
import '../services/budget_service.dart';
import '../services/resilient_ai_service.dart';
import '../services/storage_service.dart';
import '../services/timeline_service.dart';

/// Main plan state controller managing budget, timeline, and AI idea generation.
class PlanController extends ChangeNotifier {
  final BudgetService _budgetService;
  final TimelineService _timelineService;
  final AiService _aiService;
  final StorageService _storageService;

  EventContext? _context;
  BudgetPlan? _budgetPlan;
  List<Milestone> _milestones = [];
  IdeasResult? _ideas;

  bool _isLoadingIdeas = false;
  String? _ideasErrorMessage;

  PlanController({
    BudgetService? budgetService,
    TimelineService? timelineService,
    AiService? aiService,
    StorageService? storageService,
  })  : _budgetService = budgetService ?? BudgetService(),
        _timelineService = timelineService ?? TimelineService(),
        _aiService = aiService ?? ResilientAiService(),
        _storageService = storageService ?? StorageService();

  EventContext? get context => _context;
  BudgetPlan? get budgetPlan => _budgetPlan;
  List<Milestone> get milestones => _milestones;
  IdeasResult? get ideas => _ideas;
  bool get isLoadingIdeas => _isLoadingIdeas;
  String? get ideasErrorMessage => _ideasErrorMessage;

  bool get isRushMode =>
      _context != null ? _timelineService.isRushMode(_context!) : false;

  /// Load initial saved plan or initialize defaults
  Future<void> init() async {
    final savedContext = await _storageService.loadLastEventContext();
    if (savedContext != null) {
      setContext(savedContext, save: false);
    } else {
      // Default sample context
      setContext(
        EventContext(
          eventType: EventType.wedding,
          title: 'Aarav & Ananya Wedding',
          eventDate: DateTime.now().add(const Duration(days: 120)),
          guestCount: 250,
          totalBudget: 1500000,
          currencySymbol: '₹',
          currencyCode: 'INR',
          city: 'Mumbai',
          isOutdoor: true,
          dietaryRequirements: const ['Jain Options', 'Pure Vegetarian'],
          themePreference: 'Royal Marigold & Pastel Elegance',
        ),
        save: false,
      );
    }
  }

  /// Update context and recompute budget & timeline deterministically
  void setContext(EventContext newContext, {bool save = true}) {
    _context = newContext;
    _budgetPlan = _budgetService.calculateBudget(newContext);
    _milestones = _timelineService.generateTimeline(newContext);
    _ideas = null; // reset ideas on major input change
    _ideasErrorMessage = null;

    if (save) {
      _storageService.saveLastEventContext(newContext);
    }
    notifyListeners();
  }

  /// Explicit user action to request GenAI ideas
  Future<void> fetchIdeas() async {
    if (_context == null) return;

    _isLoadingIdeas = true;
    _ideasErrorMessage = null;
    notifyListeners();

    try {
      final result = await _aiService.generateIdeas(_context!);
      _ideas = result;
    } catch (e) {
      _ideasErrorMessage = 'Failed to generate ideas. Showing offline fallback.';
    } finally {
      _isLoadingIdeas = false;
      notifyListeners();
    }
  }
}
