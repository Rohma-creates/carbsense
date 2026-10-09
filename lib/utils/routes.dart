import 'package:carbsense/Views/diabetic_mode.dart';
import 'package:carbsense/Views/diet_guest_calculations.dart';
import 'package:carbsense/Views/diet_mode.dart';
import 'package:carbsense/Views/diet_post_meal_screen.dart';
import 'package:carbsense/Views/food_categories.dart';
import 'package:carbsense/Views/food_detail_screen.dart';
import 'package:carbsense/Views/food_list_screen.dart';
import 'package:carbsense/Views/guest_info.dart';
import 'package:carbsense/Views/guest_info_diet.dart';
import 'package:carbsense/Views/splash_screen.dart';
import 'package:carbsense/Views/welcome_view.dart';
import 'package:carbsense/core/constants/app_user_mode.dart';
import 'package:carbsense/features/auth/screens/login_screen.dart';
import 'package:carbsense/features/auth/screens/sign_up_screen.dart';
import 'package:carbsense/models/food_item.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:flutter/material.dart';
import 'package:carbsense/Views/diabetic_post_meal_screen.dart';

class Routes {
  static MaterialPageRoute generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splashScreen:
        return MaterialPageRoute(builder: (context) => SplashScreen());
      case RouteNames.welcomeView:
        return MaterialPageRoute(builder: (context) => WelcomeView());
      case RouteNames.diabeticMode:
        return MaterialPageRoute(builder: (context) => DiabeticMode());
      case RouteNames.dietMode:
        return MaterialPageRoute(builder: (context) => DietMode());
      case RouteNames.guestInfo:
        return MaterialPageRoute(builder: (context) => GuestInfoScreen());
      case RouteNames.guestInfoDiet:
        return MaterialPageRoute(builder: (context) => GuestInfoDiet());
      case RouteNames.foodCategory:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (context) => FoodCategoriesScreen(
                activeMode: args['mode'] as AppUserMode,
                icRatio: (args['icRatio'] as num?)?.toDouble() ?? 0.0,
                goalIndex: (args['goalIndex'] as int?),
              ),
        );
      case RouteNames.dietGuestCalculation:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => DietGuestCalculations(
                height: args['height'],
                weight: args['weight'],
                age: args['age'],
                goalIndex: args['goalIndex'],
              ),
        );

      case RouteNames.foodList:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => FoodListScreen(
                activeMode: args['activeMode'] as AppUserMode,
                category: args['categoryName'] as String,
                icRatio: (args['icRatio'] as num?)?.toDouble() ?? 0.0,
                goalIndex: args['goalIndex'] as int?, // diet mode only
              ),
        );

      case RouteNames.foodDetail:
        final item = settings.arguments as FoodItem;
        return MaterialPageRoute(
          builder: (context) => FoodDetailScreen(item: item),
        );
      case RouteNames.diabeticPostMealScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (context) => DiabeticPostMealScreen(
                item: args['item'] as FoodItem,
                icRatio: (args['icRatio'] as num).toDouble(),
              ),
        );

      case RouteNames.dietPostMealScreen:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (context) => DietPostMealScreen(
                item: args['item'] as FoodItem,

                goalIndex: args['goalIndex'] as int?,
              ),
        );

      case RouteNames.signUpScreen:
        final mode = settings.arguments as AppUserMode? ?? AppUserMode.diabetic;
        return MaterialPageRoute(
          builder: (context) => SignUpScreen(mode: mode),
        );

      case RouteNames.loginScreen:
        return MaterialPageRoute(builder: (context) => LoginScreen());

      default:
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
