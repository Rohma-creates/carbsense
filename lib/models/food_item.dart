class FoodItem {
  final String category;
  final String foodItem;
  final String foodDetail;
  final String servingSize;
  final String carbohydrates;
  final String imageUrl;
  //  final String insulin;

  const FoodItem({
    required this.category,
    required this.foodItem,
    required this.foodDetail,
    required this.servingSize,
    required this.carbohydrates,
    required this.imageUrl,
    // required this.insulin,
  });

  /// Carbs per serving as a number: "12.5 gm" -> 12.5, "15gm" -> 15.
  double get carbsPerServing {
    final m = RegExp(r'[0-9]+\.?[0-9]*').stringMatch(carbohydrates);
    return double.tryParse(m ?? '') ?? 0;
  }

  // This factory reads ONE row from the CSV and builds a FoodItem
  factory FoodItem.fromCsv(Map<String, dynamic> row) {
    return FoodItem(
      category: row['Category']?.toString().trim() ?? '',
      foodItem: row['FoodItem']?.toString().trim() ?? '',
      foodDetail: row['Food Detail']?.toString().trim() ?? '',
      servingSize: row['ServingSize']?.toString().trim() ?? '',
      carbohydrates: row['Carbohydrates']?.toString().trim() ?? '',
      imageUrl: row['Image']?.toString().trim() ?? '',
      //    insulin: row['Insulin']?.toString().trim() ?? '',
    );
  }
}
