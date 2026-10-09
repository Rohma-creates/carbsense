import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/food_item.dart';

class FoodDataService {
  // Singleton pattern — only one instance ever exists
  static final FoodDataService instance = FoodDataService._();
  FoodDataService._();

  List<FoodItem> _items = [];

  Future<void> load() async {
    // Read the file from assets as a plain string
    final raw = (await rootBundle.loadString(
      'assets/data/carbsense_foods.csv',
    )).replaceFirst('\uFEFF', ''); // strip BOM if the file has one

    // The csv package splits it into rows and columns
    final rows = const CsvToListConverter(eol: '\n').convert(raw);

    // First row is the header: ['Category', 'FoodItem', ...]
    final headers = rows.first.map((e) => e.toString().trim()).toList();

    // Every row after that is actual data
    _items =
        rows
            .skip(1)
            .where((r) => r.any((c) => c.toString().trim().isNotEmpty))
            .map((row) {
              final map = <String, dynamic>{};
              for (var i = 0; i < headers.length; i++) {
                map[headers[i]] = i < row.length ? row[i] : '';
              }
              return FoodItem.fromCsv(map);
            })
            .toList();
  }

  // All unique category names: ['Cereals', 'Fruits', ...]
  List<String> get categories =>
      _items.map((f) => f.category).toSet().toList()..sort();

  // Count how many items are in a category
  int countByCategory(String category) =>
      _items.where((f) => f.category == category).length;

  // All items in one category
  List<FoodItem> byCategory(String category) =>
      _items.where((f) => f.category == category).toList();

  // Search — checks foodItem name AND foodDetail text
  List<FoodItem> search(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();
    return _items
        .where(
          (f) =>
              f.foodItem.toLowerCase().contains(q) ||
              f.foodDetail.toLowerCase().contains(q),
        )
        .toList();
  }
}
