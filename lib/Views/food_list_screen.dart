import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/utils/carb_level.dart';
import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/food_data_service.dart';
//import 'food_detail_screen.dart';

class FoodListScreen extends StatelessWidget {
  final AppUserMode activeMode;
  final String category;
  final double icRatio;
  final int? goalIndex;

  const FoodListScreen({
    super.key,
    required this.activeMode,
    required this.category,
    required this.icRatio,
    this.goalIndex,
  });

  @override
  Widget build(BuildContext context) {
    final items = FoodDataService.instance.byCategory(category);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${items.length} item${items.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body:
          items.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No items in this category',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _FoodListCard(
                    item: item,
                    showLevel: activeMode == AppUserMode.diet,
                    onTap: () {
                      if (activeMode == AppUserMode.diabetic) {
                        Navigator.pushNamed(
                          context,
                          RouteNames.diabeticPostMealScreen,
                          arguments: {
                            'item': item,
                            'icRatio':
                                icRatio, // Passed from the previous screen
                          },
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          RouteNames.dietPostMealScreen,
                          arguments: {'item': item, 'goalIndex': goalIndex},
                        );
                      }
                      //    Navigator.pushNamed(context, RouteNames.foodDetail, arguments: food);
                    },
                    //////////////////subject to change//////////////
                    /*  onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FoodDetailScreen(item: item),
                          ),
                        ),*/
                    /////////////////////////////////////////////
                  );
                },
              ),
    );
  }
}

// ─── Food Card ────────────────────────────────────────────────────────────────

class _FoodListCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;
  final bool showLevel;

  const _FoodListCard({
    required this.item,
    required this.onTap,
    this.showLevel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Food image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _FoodImage(imageUrl: item.imageUrl, size: 60),
              ),
              const SizedBox(width: 14),

              // Name + detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.foodItem,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    if (item.servingSize.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.servingSize,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                    if (showLevel) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item.carbsPerServing.toStringAsFixed(item.carbsPerServing == item.carbsPerServing.truncateToDouble() ? 0 : 1)} g',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF062A1F),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CarbLevelPill(gramsPerServing: item.carbsPerServing),
                        ],
                      ),
                    ] else if (item.carbohydrates.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF6C63FF,
                          ).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${item.carbohydrates} carbs',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Food Image Widget ────────────────────────────────────────────────────────

class _FoodImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _FoodImage({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl.trim().isNotEmpty;

    if (!hasUrl) {
      return Container(
        width: size,
        height: size,
        color: const Color(0xFFF0F1F5),
        child: Icon(
          Icons.restaurant,
          color: Colors.grey.shade400,
          size: size * 0.45,
        ),
      );
    }

    return Image.network(
      imageUrl,
      cacheWidth: 200,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => Container(
            width: size,
            height: size,
            color: const Color(0xFFF0F1F5),
            child: Icon(
              Icons.restaurant,
              color: Colors.grey.shade400,
              size: size * 0.45,
            ),
          ),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(
          width: size,
          height: size,
          color: const Color(0xFFF0F1F5),
          child: Center(
            child: SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade300,
              ),
            ),
          ),
        );
      },
    );
  }
}
