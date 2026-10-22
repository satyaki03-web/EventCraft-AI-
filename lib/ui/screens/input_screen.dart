import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/enums.dart';
import '../../models/event_context.dart';
import '../../state/checklist_controller.dart';
import '../../state/plan_controller.dart';
import '../../validation/input_validator.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _formKey = GlobalKey<FormState>();

  EventType _selectedEventType = EventType.wedding;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _guestController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _themeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 90));
  String _selectedCurrencyCode = 'INR';
  String _selectedCurrencySymbol = '₹';
  bool _isOutdoor = false;
  final List<String> _selectedDietary = [];

  final List<String> _dietaryOptions = [
    'Pure Vegetarian',
    'Jain Options',
    'Halal Options',
    'Vegan',
    'Gluten-Free',
    'Nut Allergies',
  ];

  @override
  void initState() {
    super.initState();
    final planCtrl = Provider.of<PlanController>(context, listen: false);
    final ctx = planCtrl.context;
    if (ctx != null) {
      _selectedEventType = ctx.eventType;
      _titleController.text = ctx.title;
      _selectedDate = ctx.eventDate;
      _guestController.text = ctx.guestCount.toString();
      _budgetController.text = ctx.totalBudget.toStringAsFixed(0);
      _selectedCurrencyCode = ctx.currencyCode;
      _selectedCurrencySymbol = ctx.currencySymbol;
      _cityController.text = ctx.city;
      _isOutdoor = ctx.isOutdoor;
      _selectedDietary.addAll(ctx.dietaryRequirements);
      _themeController.text = ctx.themePreference;
      _notesController.text = ctx.additionalNotes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _guestController.dispose();
    _budgetController.dispose();
    _cityController.dispose();
    _themeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1095)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final title = InputValidator.sanitizeText(_titleController.text);
    final city = InputValidator.sanitizeText(_cityController.text);
    final theme = InputValidator.sanitizeText(_themeController.text);
    final notes = InputValidator.sanitizeText(_notesController.text);

    final guestCount = int.parse(_guestController.text.trim());
    final totalBudget = double.parse(
        _budgetController.text.replaceAll(RegExp(r'[,₹\$€£]'), '').trim());

    final newContext = EventContext(
      eventType: _selectedEventType,
      title: title,
      eventDate: _selectedDate,
      guestCount: guestCount,
      totalBudget: totalBudget,
      currencySymbol: _selectedCurrencySymbol,
      currencyCode: _selectedCurrencyCode,
      city: city,
      isOutdoor: _isOutdoor,
      dietaryRequirements: List.from(_selectedDietary),
      themePreference: theme.isNotEmpty ? theme : 'Classic',
      additionalNotes: notes,
    );

    final planCtrl = Provider.of<PlanController>(context, listen: false);
    final checklistCtrl = Provider.of<ChecklistController>(context, listen: false);

    planCtrl.setContext(newContext);
    checklistCtrl.updateForContext(newContext);

    Navigator.pushNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber),
            SizedBox(width: 8),
            Text('EventCraft AI Planner'),
          ],
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Plan Your Next Event Effortlessly',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter your event parameters below to build an automated budget, timeline, and AI vendor checklist.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // Event Type
                  DropdownButtonFormField<EventType>(
                    value: _selectedEventType,
                    decoration: const InputDecoration(
                      labelText: 'Event Vertical / Type',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: EventType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.displayName),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedEventType = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  // Event Name
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Name / Title',
                      hintText: 'e.g. Ananya & Aarav Wedding',
                      prefixIcon: Icon(Icons.event),
                      border: OutlineInputBorder(),
                    ),
                    validator: InputValidator.validateTitle,
                  ),
                  const SizedBox(height: 14),

                  // Date Picker Row
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Event Date',
                        prefixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Guest Count & Currency
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _guestController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Guest Count',
                            prefixIcon: Icon(Icons.people),
                            border: OutlineInputBorder(),
                          ),
                          validator: InputValidator.validateGuestCount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCurrencyCode,
                          decoration: const InputDecoration(
                            labelText: 'Currency',
                            border: OutlineInputBorder(),
                          ),
                          items: AppConstants.currencies
                              .map((c) => DropdownMenuItem(
                                    value: c['code'],
                                    child: Text(c['code']!),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final curr = AppConstants.currencies
                                  .firstWhere((c) => c['code'] == val);
                              setState(() {
                                _selectedCurrencyCode = curr['code']!;
                                _selectedCurrencySymbol = curr['symbol']!;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Total Budget
                  TextFormField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Budget ($_selectedCurrencySymbol)',
                      hintText: 'e.g. 1500000',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: const OutlineInputBorder(),
                    ),
                    validator: InputValidator.validateBudget,
                  ),
                  const SizedBox(height: 14),

                  // City / Location
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City / Region',
                      hintText: 'e.g. Mumbai, Delhi, Bengaluru',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: InputValidator.validateCity,
                  ),
                  const SizedBox(height: 14),

                  // Indoor / Outdoor Switch
                  SwitchListTile(
                    title: const Text('Outdoor Venue Event'),
                    subtitle: const Text(
                        'Automatically includes weather canopy & generator backup'),
                    value: _isOutdoor,
                    activeColor: Colors.indigo,
                    onChanged: (val) => setState(() => _isOutdoor = val),
                  ),
                  const SizedBox(height: 10),

                  // Dietary Requirements
                  const Text(
                    'Dietary & Catering Needs',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _dietaryOptions.map((option) {
                      final isSelected = _selectedDietary.contains(option);
                      return FilterChip(
                        label: Text(option),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDietary.add(option);
                            } else {
                              _selectedDietary.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Theme Preference
                  TextFormField(
                    controller: _themeController,
                    decoration: const InputDecoration(
                      labelText: 'Theme / Color Preference',
                      hintText: 'e.g. Royal Marigold & Gold / Retro 90s',
                      prefixIcon: Icon(Icons.palette),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Generate Event Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
