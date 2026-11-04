import 'package:carbsense/core/constants/app_colors.dart';
import 'package:carbsense/core/constants/app_text_styles.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/widgets/carbsense_appbar.dart';
import 'package:carbsense/widgets/carbsense_textbox.dart';
import 'package:carbsense/providers/diet_log_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../services/food_data_service.dart';

// Category asset images — must match CSV category names exactly
const _categoryImages = {
  'Cereals': 'assets/images/cereal.jpg',
  'Vegetables': 'assets/images/veg.jpg',
  'Fruits': 'assets/images/fruits.jpg',
  'Milk': 'assets/images/milk.jpg',
  'Desserts': 'assets/images/desserts.jpg',
  'Snacks': 'assets/images/snack.jpg',
  'Lentils': 'assets/images/lentil.jpg',
  'Fast Food': 'assets/images/fast-food.jpg',
  'Asian Food': 'assets/images/asianFood.jpg',
};
const _fallbackImage = 'assets/images/wheat.png';

class FoodCategoriesScreen extends StatefulWidget {
  final AppUserMode activeMode;
  final double icRatio;

  final int? goalIndex;

  const FoodCategoriesScreen({
    super.key,
    required this.activeMode,
    required this.icRatio,
    this.goalIndex,
  });

  @override
  State<FoodCategoriesScreen> createState() => _FoodCategoriesScreenState();
}

class _FoodCategoriesScreenState extends State<FoodCategoriesScreen> {
  // BUG FIX: only one mechanism for search — plain String, no controller listener
  Color get _borderColor =>
      widget.activeMode == AppUserMode.diabetic
          ? AppColors.diabeticBorder
          : AppColors.dietBorder;

  String _searchQuery = '';
  List<FoodItem> _searchResults = [];

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
      _searchResults =
          _searchQuery.isEmpty ? [] : FoodDataService.instance.search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final icRatio = widget.icRatio;
    /* final Gradient appBarGradient =
        widget.activeMode == AppUserMode.diabetic
            ? AppColors.diabeticGradient
            : AppColors.dietGradient;*/
    /*   widget.activeMode == AppUserMode.diabetic
        ? AppColors.diabeticGradient
        : AppColors.dietGradient;*/
    final svc = FoodDataService.instance;
    final categories = svc.categories;

    final modeName =
        widget.activeMode == AppUserMode.diet ? 'Diet' : 'Diabetic';
    final hasLog = context.watch<DietLogProvider>().todayEntries.isNotEmpty;

    return PopScope(
      canPop: !hasLog,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: Text('Leave $modeName Mode?'),
                content: const Text(
                  'Your food log for this guest session will be cleared.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Stay'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Leave and clear'),
                  ),
                ],
              ),
        );
        if (leave == true && context.mounted) {
          context.read<DietLogProvider>().resetSession();
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            CarbSenseAppBar(
              title: 'Food Categories',
              showBack: true,
              subtitle: 'Choose your Category of food or Search',
              mode: widget.activeMode,
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CarbsenseTextbox(
                label: '',
                hint: 'Search Food...',
                prefixIcon: Icons.search,
                // BUG FIX: only onChanged — no controller, no double-firing
                onChanged: _onSearchChanged,
              ),
            ),

            const SizedBox(height: 10),

            // BUG FIX: Expanded wraps the switching content so it has a bounded
            // height — this is what was missing and causing the layout freeze
            Expanded(
              child:
                  _searchQuery.isNotEmpty
                      ? _buildSearchResults(icRatio)
                      : _buildCategoryGrid(context, categories, svc, icRatio),
            ),
          ],
        ),
      ),
    );
  }

  // ── Category grid ──────────────────────────────────────────────────────────
  // BUG FIX: GridView is now directly inside an Expanded — no SingleChildScrollView
  // wrapper needed, so shrinkWrap is NOT set (it defaults to false which is correct)
  Widget _buildCategoryGrid(
    BuildContext context,
    List<String> categories,
    FoodDataService svc,
    double icRatio,
  ) {
    final scale = MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 1.5);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        //  childAspectRatio: 1.1,
        mainAxisExtent: 165 * scale,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final catName = categories[index];
        final count = svc.countByCategory(catName);
        final image = _categoryImages[catName] ?? _fallbackImage;

        return _buildCategoryCard(
          context,
          catName,
          '$count items',
          image,
          onTap: () {
            Navigator.pushNamed(
              context,
              RouteNames.foodList,
              arguments: {
                'categoryName': catName,
                'icRatio': icRatio,
                'activeMode': widget.activeMode,
                'goalIndex': widget.goalIndex,
              },
            );
          },
        );
      },
    );
  }

  // ── Search results ─────────────────────────────────────────────────────────
  // BUG FIX: ListView is now directly inside an Expanded — it has bounded height
  // so Flutter can lay it out correctly without freezing
  Widget _buildSearchResults(double icRatio) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No results for "$_searchQuery"',
              style: AppTextStyles.cardTitleLarge(context),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different spelling',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            '${_searchResults.length} result${_searchResults.length != 1 ? 's' : ''} for "$_searchQuery"',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            itemCount: _searchResults.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final food = _searchResults[index];
              return _buildSearchResultCard(context, food, icRatio);
            },
          ),
        ),
      ],
    );
  }

  // ── Category card (your original style) ────────────────────────────────────
  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String itemCount,
    String image, {
    VoidCallback? onTap,
  }) {
    final Map<String, Color> categoryColors = {
      'Cereals': Colors.brown.shade100,
      'Fruits': Colors.red.shade100,
      'Vegetables': Colors.green.shade100,
      'Desserts': Colors.blue.shade100,
      'Milk': Colors.purple.shade100,
      'Fast Food': Colors.orange.shade50,
      'Lentils': Colors.yellow.shade200,
      'Snacks': Colors.cyan.shade100,
    };
    final Color bgColor = categoryColors[title] ?? Colors.grey.shade100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage(image),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.cardTitleLarge(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              itemCount,
              style: AppTextStyles.chipFilled(
                context,
              ).copyWith(fontSize: 10, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search result card — uses real network image from CSV ──────────────────
  Widget _buildSearchResultCard(
    BuildContext context,
    FoodItem food,
    double icRatio,
  ) {
    return GestureDetector(
      onTap: () {
        if (widget.activeMode == AppUserMode.diabetic) {
          Navigator.pushNamed(
            context,
            RouteNames.diabeticPostMealScreen,
            arguments: {
              'item': food,
              'icRatio': widget.icRatio, // Passed from the previous screen
            },
          );
        } else {
          Navigator.pushNamed(
            context,
            RouteNames.dietPostMealScreen,
            arguments: {'item': food, 'goalIndex': widget.goalIndex},
          );
        }
        //    Navigator.pushNamed(context, RouteNames.foodDetail, arguments: food);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              widget.activeMode == AppUserMode.diabetic
                  ? AppColors.diabeticSurface
                  : AppColors.dietSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Hero(
              tag: 'food_img_${food.foodItem}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _NetworkFoodImage(imageUrl: food.imageUrl, size: 48),
              ),
            ),

            // Real food image from CSV URL
            /*      ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _NetworkFoodImage(imageUrl: food.imageUrl, size: 48),
            ),*/
            const SizedBox(width: 12),

            // Food name + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.foodItem,
                    style: AppTextStyles.cardTitleLarge(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    food.category,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Carbs badge
            /*    Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                food.carbohydrates,
                style: AppTextStyles.chipFilled(
                  context,
                ).copyWith(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
*/
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Network image with loading + error fallback ────────────────────────────────
class _NetworkFoodImage extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _NetworkFoodImage({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return _placeholder(size);
    }
    return Image.network(
      imageUrl,
      cacheWidth: 200,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(size),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SizedBox(
              width: size * 0.4,
              height: size * 0.4,
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

  Widget _placeholder(double size) {
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
}
