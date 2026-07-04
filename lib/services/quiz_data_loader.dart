import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/quiz_models.dart';

/// Loads the question bank bundled at `assets/quiz_data.json`.
///
/// Everything is read once, locally, from disk — no network calls, per the
/// assignment's "handle it locally" requirement.
class QuizDataLoader {
  static const String _assetPath = 'assets/quiz_data.json';

  /// Maps the human-readable category names used in the JSON asset to the
  /// category ids used throughout the app's routing/state.
  static const Map<String, String> _categoryNameToId = {
    'Sports': 'sports',
    'Science': 'science',
    'Technology': 'technology',
    'History': 'history',
    'General Knowledge': 'general',
  };

  static Future<Map<String, List<Question>>> load() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final quizzes = decoded['quizzes'] as List<dynamic>? ?? [];

      final Map<String, List<Question>> bank = {};
      for (final quiz in quizzes) {
        final categoryName = quiz['category'] as String;
        final categoryId = _categoryNameToId[categoryName];
        if (categoryId == null) continue;

        final questions = (quiz['questions'] as List<dynamic>)
            .map((q) => Question.fromJson(q as Map<String, dynamic>))
            .toList();
        bank[categoryId] = questions;
      }
      return bank;
    } catch (_) {
      // If the asset is ever missing or malformed, the app still boots —
      // QuizProvider falls back to its built-in question set.
      return {};
    }
  }
}
