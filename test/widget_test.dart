// Widget smoke tests for Quiz Master.
//
// These exercise the real widget tree (MyApp) instead of using mocks, since
// the app's local-storage layer (SharedPreferences) can be seeded with
// in-memory mock values for tests via `SharedPreferences.setMockInitialValues`.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_quiz_master_app/main.dart';

void main() {
  setUp(() {
    // Start every test with empty local storage.
    SharedPreferences.setMockInitialValues({});
  });

  group('Quiz Master Widget Tests', () {
    testWidgets('Home screen displays welcome banner and categories',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp(questionBank: {}));
      await tester.pumpAndSettle();

      expect(find.text('Quiz Master'), findsOneWidget);
      expect(find.textContaining('Test your knowledge'), findsOneWidget);
      expect(find.text('Sports'), findsOneWidget);
      expect(find.text('Science'), findsOneWidget);
      expect(find.text('Technology'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('General Knowledge'), findsOneWidget);
    });

    testWidgets('Statistics section displays default values',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp(questionBank: {}));
      await tester.pumpAndSettle();

      expect(find.text('Your Progress'), findsOneWidget);
      expect(find.text('Attempts'), findsOneWidget);
      expect(find.text('Best Score'), findsOneWidget);
      expect(find.text('Last Score'), findsOneWidget);
    });

    testWidgets('Theme toggle switches between light and dark mode icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp(questionBank: {}));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.dark_mode_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.dark_mode_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
    });

    testWidgets('Tapping a category starts a quiz and shows the first question',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp(questionBank: {}));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Science'));
      await tester.pumpAndSettle();

      expect(find.text('Question 1 of 5'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Selecting an answer enables the Next button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp(questionBank: {}));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Science'));
      await tester.pumpAndSettle();

      final nextButtonFinder = find.widgetWithText(FilledButton, 'Next');
      expect(nextButtonFinder, findsOneWidget);
      expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNull);

      // Tap the first answer option for question 1 ("What is the chemical
      // symbol for Gold?").
      await tester.tap(find.text('Go').hitTestable());
      await tester.pumpAndSettle();

      expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNotNull);
    });

    testWidgets('Exiting a quiz shows a confirmation dialog',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp(questionBank: {}));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Science'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Exit Quiz?'), findsOneWidget);
    });
  });
}
