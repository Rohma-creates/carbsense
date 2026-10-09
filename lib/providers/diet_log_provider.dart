// lib/providers/diet_log_provider.dart
import 'package:flutter/foundation.dart';

class FoodLogEntry {
  final String name;
  final double
  carbs; // total carbs for this entry (carbs per serving x servings)
  final int servings;
  final DateTime time;
  final double insulinUnits; // diabetic mode only (0 in diet mode)

  FoodLogEntry({
    required this.name,
    required this.carbs,
    required this.servings,
    this.insulinUnits = 0,
    DateTime? time,
  }) : time = time ?? DateTime.now();
}

class DietLogProvider extends ChangeNotifier {
  final List<FoodLogEntry> _entries = [];
  double? _dailyCarbTarget; // null = user has not set a target

  List<FoodLogEntry> get entries => List.unmodifiable(_entries);
  double? get dailyCarbTarget => _dailyCarbTarget;
  bool get hasTarget => _dailyCarbTarget != null;

  bool _isToday(DateTime t) {
    final n = DateTime.now();
    return t.year == n.year && t.month == n.month && t.day == n.day;
  }

  /// Only entries from today, newest first.
  List<FoodLogEntry> get todayEntries =>
      _entries.where((e) => _isToday(e.time)).toList().reversed.toList();

  double get totalCarbsToday =>
      _entries.where((e) => _isToday(e.time)).fold(0.0, (s, e) => s + e.carbs);

  double get totalInsulinToday => _entries
      .where((e) => _isToday(e.time))
      .fold(0.0, (sum, e) => sum + e.insulinUnits);

  /// Ends a guest session: clears the food log AND the optional carb target.
  void resetSession() {
    _entries.clear();
    _dailyCarbTarget = null;
    notifyListeners();
  }

  void addEntry(FoodLogEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void removeEntry(FoodLogEntry entry) {
    _entries.remove(entry);
    notifyListeners();
  }

  void clearLog() {
    _entries.clear();
    notifyListeners();
  }

  void setTarget(double grams) {
    _dailyCarbTarget = grams;
    notifyListeners();
  }

  void clearTarget() {
    _dailyCarbTarget = null;
    notifyListeners();
  }
}
