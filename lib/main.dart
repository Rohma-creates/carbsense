import 'package:carbsense/services/food_data_service.dart';
import 'package:carbsense/utils/route_names.dart';
import 'package:carbsense/utils/routes.dart';
//import 'package:carbsense/sample_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:carbsense/providers/diet_log_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // required before async work
  await FoodDataService.instance.load();
  runApp(
    ChangeNotifierProvider(
      create: (_) => DietLogProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      initialRoute: RouteNames.splashScreen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
