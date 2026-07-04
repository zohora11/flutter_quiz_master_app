import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/quiz_models.dart';

class LocalStorageService {
  static const String _themeModeKey = 'theme_mode';
  static const String _quizResultsKey = 'quiz_results';
  static const String _statisticsKey = 'quiz_statistics';

  static Future<void> setThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeModeKey, isDarkMode);
  }

  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeModeKey) ?? false;
  }

  static Future<void> saveQuizResult(QuizResult result) async {
    final prefs = await SharedPreferences.getInstance();

    final existingResults = await getQuizResults();
    existingResults.add(result);

    final jsonList = existingResults.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_quizResultsKey, jsonList);

    await _updateStatistics(existingResults);
  }

  static Future<List<QuizResult>> getQuizResults() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_quizResultsKey) ?? [];
    return jsonList
        .map((jsonString) => QuizResult.fromJson(jsonDecode(jsonString)))
        .toList();
  }

  static Future<QuizStatistics> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_statisticsKey);

    if (jsonString == null) {
      return QuizStatistics.empty();
    }

    final json = jsonDecode(jsonString);
    return QuizStatistics(
      totalAttempts: json['totalAttempts'],
      highestScore: json['highestScore'],
      lastScore: json['lastScore'],
    );
  }

  static Future<void> _updateStatistics(List<QuizResult> results) async {
    if (results.isEmpty) return;

    int highestScore = 0;
    int lastScore = 0;

    for (var result in results) {
      if (result.score > highestScore) {
        highestScore = result.score;
      }
    }

    lastScore = results.last.score;

    final statistics = QuizStatistics(
      totalAttempts: results.length,
      highestScore: highestScore,
      lastScore: lastScore,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _statisticsKey,
      jsonEncode({
        'totalAttempts': statistics.totalAttempts,
        'highestScore': statistics.highestScore,
        'lastScore': statistics.lastScore,
      }),
    );
  }

  static Future<List<QuizResult>> getResultsByCategory(String categoryId) async {
    final allResults = await getQuizResults();
    return allResults.where((result) => result.categoryId == categoryId).toList();
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_quizResultsKey);
    await prefs.remove(_statisticsKey);
  }
}