// integration_test/full_qa_test.dart
//
// ─────────────────────────────────────────────────────────────────────────
//  CarbSense QA agent
// ─────────────────────────────────────────────────────────────────────────
//  Drives the real app on your phone/emulator and checks:
//    1. Food data      – every food has carbs, a serving size and an image link
//    2. Diabetic inputs – TDD / weight / height validation and the TDD warning
//    3. Diabetic dose   – every food x many TDD values: no crash, dose is correct
//    4. Diet screen     – every food x every goal: no crash, "add to today" works
//    5. Diabetic journey – taps through EVERY category and EVERY food like a user
//    6. Diet journey     – the same, in Diet mode
//
//  HOW TO RUN (phone connected with USB debugging on):
//      flutter test integration_test/full_qa_test.dart
//
//  READING THE RESULT:
//    • Each check prints a line starting with ▶  (what is being tested now)
//    • Problems print a line starting with ❌
//    • Each part ends with a summary.
//    • If the app itself dies (for example "Lost connection to device"),
//      the LAST ▶ line in the output shows which food caused it.
// ─────────────────────────────────────────────────────────────────────────

import 'package:carbsense/Views/diabetic_post_meal_screen.dart';
import 'package:carbsense/Views/diet_post_meal_screen.dart';
import 'package:carbsense/Views/food_list_screen.dart';
import 'package:carbsense/Views/guest_info_diet.dart' show kGoalProfiles;
import 'package:carbsense/main.dart';
import 'package:carbsense/models/food_item.dart';
import 'package:carbsense/providers/diet_log_provider.dart';
import 'package:carbsense/services/food_data_service.dart';
import 'package:carbsense/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

// TDD values tested for every food. 0 means "TDD left empty".
const List<double> kTddValues = [0, 5, 12.5, 25, 42, 60, 100, 150, 200];

// ── Small helpers ──────────────────────────────────────────────────────────

/// Collects problems so one failure does not stop the whole run.
class QaReport {
  QaReport(this.part);
  final String part;
  final List<String> problems = [];
  String current = '';
  int checks = 0;

  void start(String label) {
    current = label;
    checks++;
    debugPrint('▶ [$part] $label');
  }

  void fail(String message) {
    problems.add('$current → $message');
    debugPrint('   ❌ $message');
  }

  String summary() {
    final b =
        StringBuffer()
          ..writeln('')
          ..writeln('════════ $part ════════')
          ..writeln('Checks run: $checks   Problems: ${problems.length}');
    for (final p in problems) {
      b.writeln('  ❌ $p');
    }
    if (problems.isEmpty) b.writeln('  ✅ All good');
    return b.toString();
  }
}

/// Same number format the app uses: 15 -> "15", 12.5 -> "12.5".
String fmt(double v) => v.toStringAsFixed(v == v.truncateToDouble() ? 0 : 1);

/// Lets the app run in real time for [ms] milliseconds
/// (needed for images, animations and the splash timer).
Future<void> wait(WidgetTester t, [int ms = 300]) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  do {
    await t.pump(const Duration(milliseconds: 50));
    await Future<void>.delayed(const Duration(milliseconds: 20));
  } while (DateTime.now().isBefore(end));
}

/// Scrolls the screen's list/grid until [f] is visible. Returns false if not found.
Future<bool> scrollTo(WidgetTester t, Finder f) async {
  try {
    if (f.evaluate().isEmpty) {
      await t.scrollUntilVisible(
        f.first,
        150,
        scrollable: find.byType(Scrollable).last,
        maxScrolls: 150,
      );
    }
    await t.ensureVisible(f.first);
    await wait(t, 150);
    return true;
  } catch (_) {
    return false;
  }
}

Future<void> tapText(
  WidgetTester t,
  String text, {
  bool contains = false,
}) async {
  final f = contains ? find.textContaining(text) : find.text(text);
  if (!await scrollTo(t, f)) {
    throw StateError('Could not find "$text" on screen');
  }
  await t.tap(f.first, warnIfMissed: false);
  await wait(t, 600);
}

NavigatorState nav(WidgetTester t) =>
    t.state<NavigatorState>(find.byType(Navigator).first);

/// Routes every Flutter error (crashes, overflow, image errors) into [r]
/// instead of stopping the test. Always restore with the returned function.
VoidCallback captureErrors(QaReport r) {
  final original = FlutterError.onError;
  FlutterError.onError = (details) {
    final first = details.exceptionAsString().split('\n').first;
    r.fail('Flutter error: $first');
  };
  return () => FlutterError.onError = original;
}

/// Hosts a single screen, with the same routes and provider as the real app.
Widget host(Widget screen) => ChangeNotifierProvider(
  create: (_) => DietLogProvider(),
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateRoute: Routes.generateRoute,
    home: screen,
  ),
);

/// Starts the full app and waits past the splash screen.
Future<void> startApp(WidgetTester t) async {
  await t.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => DietLogProvider(),
      child: const MyApp(),
    ),
  );
  await wait(t, 4500);
}

Future<void> finish(QaReport r, VoidCallback restore) async {
  restore();
  debugPrint(r.summary());
  expect(r.problems, isEmpty, reason: r.summary());
}

// ── The tests ──────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late List<String> categories;
  late List<FoodItem> allFoods;

  setUpAll(() async {
    await FoodDataService.instance.load();
    final svc = FoodDataService.instance;
    categories = svc.categories;
    allFoods = [for (final c in categories) ...svc.byCategory(c)];
    debugPrint(
      'Loaded ${allFoods.length} foods in ${categories.length} categories',
    );
  });

  // 1 ────────────────────────────────────────────────────────────────────
  testWidgets('1. Food data check', (t) async {
    final r = QaReport('1. Food data');
    final restore = captureErrors(r);
    final seen = <String>{};
    for (final food in allFoods) {
      r.start('${food.category} / ${food.foodItem}');
      if (food.foodItem.isEmpty) r.fail('Food name is empty');
      if (!seen.add(food.foodItem.toLowerCase())) {
        r.fail('Duplicate food name (can break Hero animations)');
      }
      final carbs = food.carbsPerServing;
      if (carbs <= 0) r.fail('Carbs missing or 0 ("${food.carbohydrates}")');
      if (carbs > 150) r.fail('Carbs look too high: $carbs g');
      if (food.servingSize.isEmpty) r.fail('Serving size is empty');
      if (!food.imageUrl.startsWith('https://')) {
        r.fail('Image link missing or not https: "${food.imageUrl}"');
      }
    }
    await finish(r, restore);
  });

  // 2 ────────────────────────────────────────────────────────────────────
  testWidgets(
    '2. Diabetic inputs (validation)',
    (t) async {
      final r = QaReport('2. Diabetic inputs');
      final restore = captureErrors(r);
      try {
        await startApp(t);
        await tapText(t, 'For Diabetics');
        await tapText(t, 'Guest Access');

        // [height, weight, TDD, text that must appear, should open food screen?]
        final cases = <List<Object>>[
          ['170', '70', '42', 'Food Categories', true],
          ['170', '70', '', 'Food Categories', true], // TDD is optional
          ['', '70', '42', 'Food Categories', true], // height is optional
          ['170', '', '42', 'This field cannot be left empty', false],
          ['170', '70', '0', 'TDD must be greater than 0', false],
          ['170', '70', '-5', 'TDD must be greater than 0', false],
          ['170', '70', 'abc', 'Please enter a valid number', false],
          [
            '170',
            '70',
            '420',
            'TDD is usually 5–200 units. Please check it.',
            false,
          ],
          [
            '170',
            '70',
            '0.5',
            'TDD is usually 5–200 units. Please check it.',
            false,
          ],
          ['170', '70', '42.5', 'Food Categories', true], // decimals allowed
          [
            '170',
            '50',
            '150',
            'Please check your TDD',
            false,
          ], // unusual per kg
          ['170', 'abc', '42', 'Please enter a valid numeric value', false],
        ];

        for (final c in cases) {
          r.start('height="${c[0]}" weight="${c[1]}" TDD="${c[2]}"');
          final fields = find.byType(TextFormField);
          await t.enterText(fields.at(0), c[0] as String);
          await t.enterText(fields.at(1), c[1] as String);
          await t.enterText(fields.at(2), c[2] as String);
          await wait(t, 200);
          await tapText(t, 'Find my Food', contains: true);
          await wait(t, 800);

          if (find.text(c[3] as String).evaluate().isEmpty) {
            r.fail('Expected to see "${c[3]}" but did not');
          }
          // Close the "check your TDD" pop-up if it is open.
          if (find.text('Check again').evaluate().isNotEmpty) {
            await t.tap(find.text('Check again'));
            await wait(t, 500);
          }
          // If the food screen opened, go back to the form.
          if (find.text('Food Categories').evaluate().isNotEmpty) {
            if (c[4] != true) r.fail('Food screen opened but should not have');
            nav(t).pop();
            await wait(t, 700);
          } else if (c[4] == true) {
            r.fail('Food screen did not open but should have');
          }
        }
      } catch (e) {
        r.fail('Test stopped early: $e');
      }
      await finish(r, restore);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );

  // 3 ────────────────────────────────────────────────────────────────────
  testWidgets(
    '3. Diabetic dose screen: every food x every TDD',
    (t) async {
      final r = QaReport('3. Diabetic dose');
      final restore = captureErrors(r);

      for (final food in allFoods) {
        for (final tdd in kTddValues) {
          r.start(
            '${food.category} / ${food.foodItem} / TDD ${tdd == 0 ? "empty" : fmt(tdd)}',
          );
          try {
            final ic = tdd == 0 ? 0.0 : 500 / tdd;
            await t.pumpWidget(
              host(
                DiabeticPostMealScreen(
                  key: UniqueKey(),
                  item: food,
                  icRatio: ic,
                ),
              ),
            );
            await wait(
              t,
              tdd == kTddValues.first ? 1200 : 200,
            ); // 1st time: let image load

            // Check the dose shown is what the formula gives.
            final carbs = food.carbsPerServing;
            final raw = ic <= 0 ? 0.0 : carbs / ic;
            final String expected =
                ic <= 0
                    ? 'no estimate'
                    : (raw < 1 ? '< 1' : raw.toStringAsFixed(1));
            if (find.text(expected).evaluate().isEmpty) {
              r.fail('Expected dose "$expected" not shown');
            }
            if (find.text('${fmt(carbs)}g').evaluate().isEmpty) {
              r.fail('Total carbs "${fmt(carbs)}g" not shown for 1 serving');
            }

            // Servings stepper (only once per food, at TDD 42).
            if (tdd == 42) {
              for (var i = 0; i < 12; i++) {
                await t.tap(find.text('+').first, warnIfMissed: false);
                await t.pump();
              }
              await wait(t, 150);
              final total10 = '${fmt(carbs * 10)}g';
              if (find.text(total10).evaluate().isEmpty) {
                r.fail(
                  'After pressing + many times, expected max 10 servings = $total10',
                );
              }
              for (var i = 0; i < 12; i++) {
                await t.tap(find.text('-').first, warnIfMissed: false);
                await t.pump();
              }
              await wait(t, 150);
              if (find.text('${fmt(carbs)}g').evaluate().isEmpty) {
                r.fail(
                  'After pressing - many times, expected minimum 1 serving',
                );
              }
            }
          } catch (e) {
            r.fail('Exception: $e');
          }
        }
      }
      await finish(r, restore);
    },
    timeout: const Timeout(Duration(minutes: 30)),
  );

  // 4 ────────────────────────────────────────────────────────────────────
  testWidgets(
    '4. Diet screen: every food x every goal',
    (t) async {
      final r = QaReport('4. Diet screen');
      final restore = captureErrors(r);

      for (final food in allFoods) {
        for (var g = 0; g < kGoalProfiles.length; g++) {
          r.start(
            '${food.category} / ${food.foodItem} / goal "${kGoalProfiles[g].label}"',
          );
          try {
            await t.pumpWidget(
              host(
                DietPostMealScreen(key: UniqueKey(), item: food, goalIndex: g),
              ),
            );
            await wait(t, g == 0 ? 1200 : 200);

            if (find.text('Meal Summary').evaluate().isEmpty) {
              r.fail('Screen did not show "Meal Summary"');
            }
            // Add 3 servings to today's log once per food.
            if (g == 0) {
              await t.tap(find.text('+').first, warnIfMissed: false);
              await t.pump();
              await t.tap(find.text('+').first, warnIfMissed: false);
              await wait(t, 150);
              await tapText(t, "Add to today's total");
              if (find.textContaining('Added 3 servings').evaluate().isEmpty) {
                r.fail('"Add to today\'s total" did not confirm 3 servings');
              }
            }
          } catch (e) {
            r.fail('Exception: $e');
          }
        }
      }
      await finish(r, restore);
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );

  // 5 & 6: full user journeys ────────────────────────────────────────────
  Future<void> journey(
    WidgetTester t,
    QaReport r, {
    required bool diabetic,
  }) async {
    await startApp(t);
    if (diabetic) {
      await tapText(t, 'For Diabetics');
      await tapText(t, 'Guest Access');
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), '170');
      await t.enterText(fields.at(1), '70');
      await t.enterText(fields.at(2), '42');
      await tapText(t, 'Find my Food', contains: true);
    } else {
      await tapText(t, 'For Diet & Nutrition');
      await tapText(t, 'Guest Access');
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), '165');
      await t.enterText(fields.at(1), '60');
      await t.enterText(fields.at(2), '30');
      await tapText(t, 'Continue', contains: true);
      await tapText(t, 'Find My Food', contains: true);
    }
    await wait(t, 800);
    if (find.text('Food Categories').evaluate().isEmpty) {
      throw StateError('Could not reach the Food Categories screen');
    }

    final svc = FoodDataService.instance;
    for (final cat in categories) {
      r.start('Open category "$cat"');
      try {
        await tapText(t, cat);
        await wait(t, 800);
        if (find.byType(FoodListScreen).evaluate().isEmpty) {
          r.fail('Category list did not open');
          continue;
        }
      } catch (e) {
        r.fail('Exception: $e');
        continue;
      }

      for (final food in svc.byCategory(cat)) {
        r.start('$cat / ${food.foodItem}');
        try {
          final f = find.text(food.foodItem);
          if (!await scrollTo(t, f)) {
            r.fail('Food not found in the list');
            continue;
          }
          await t.tap(f.first, warnIfMissed: false);
          await wait(t, 1500);

          final screen =
              diabetic
                  ? find.byType(DiabeticPostMealScreen)
                  : find.byType(DietPostMealScreen);
          final title = diabetic ? 'Dose Estimate' : 'Meal Summary';
          if (screen.evaluate().isEmpty) {
            r.fail('Tapping the food did not open the $title screen');
          } else {
            if (find.text(title).evaluate().isEmpty) {
              r.fail('$title screen opened but did not draw correctly');
            }
            nav(t).pop();
            await wait(t, 600);
          }
        } catch (e) {
          r.fail('Exception: $e');
        }
      }

      if (find.byType(FoodListScreen).evaluate().isNotEmpty) {
        nav(t).pop();
        await wait(t, 600);
      }
    }
  }

  testWidgets(
    '5. Diabetic journey: every category, every food',
    (t) async {
      final r = QaReport('5. Diabetic journey');
      final restore = captureErrors(r);
      try {
        await journey(t, r, diabetic: true);
      } catch (e) {
        r.fail('Journey stopped early: $e');
      }
      await finish(r, restore);
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );

  testWidgets(
    '6. Diet journey: every category, every food',
    (t) async {
      final r = QaReport('6. Diet journey');
      final restore = captureErrors(r);
      try {
        await journey(t, r, diabetic: false);
      } catch (e) {
        r.fail('Journey stopped early: $e');
      }
      await finish(r, restore);
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}
