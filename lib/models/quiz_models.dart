class Category {
  final String id;
  final String name;
  final String emoji;
  final int questionCount;

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.questionCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      questionCount: json['questionCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'questionCount': questionCount,
    };
  }
}

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'].toString(),
      text: (json['text'] ?? json['question']) as String,
      options: List<String>.from(json['options']),
      correctAnswerIndex:
          (json['correctAnswerIndex'] ?? json['correctAnswer']) as int,
      explanation: json['explanation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
    };
  }
}

class QuizSession {
  final String id;
  final String categoryId;
  final List<Question> questions;
  late final List<int?> userAnswers;
  int currentQuestionIndex;

  QuizSession({
    required this.id,
    required this.categoryId,
    required this.questions,
    List<int?>? userAnswers,
    this.currentQuestionIndex = 0,
  }) {
    this.userAnswers = userAnswers ?? List<int?>.filled(questions.length, null);
  }

  void selectAnswer(int optionIndex) {
    userAnswers[currentQuestionIndex] = optionIndex;
  }

  bool get isAnswered => userAnswers[currentQuestionIndex] != null;

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  void nextQuestion() {
    if (!isLastQuestion) currentQuestionIndex++;
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) currentQuestionIndex--;
  }

  QuizResult generateResult() {
    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctAnswerIndex) {
        correctCount++;
      }
    }
    return QuizResult(
      id: id,
      categoryId: categoryId,
      totalQuestions: questions.length,
      correctAnswers: correctCount,
      wrongAnswers: questions.length - correctCount,
      score: correctCount,
      totalScore: questions.length,
      percentage: ((correctCount / questions.length) * 100).toStringAsFixed(2),
      timestamp: DateTime.now(),
    );
  }
}

class QuizResult {
  final String id;
  final String categoryId;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int score;
  final int totalScore;
  final String percentage;
  final DateTime timestamp;

  QuizResult({
    required this.id,
    required this.categoryId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.score,
    required this.totalScore,
    required this.percentage,
    required this.timestamp,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'],
      categoryId: json['categoryId'],
      totalQuestions: json['totalQuestions'],
      correctAnswers: json['correctAnswers'],
      wrongAnswers: json['wrongAnswers'],
      score: json['score'],
      totalScore: json['totalScore'],
      percentage: json['percentage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'score': score,
      'totalScore': totalScore,
      'percentage': percentage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class QuizStatistics {
  final int totalAttempts;
  final int highestScore;
  final int lastScore;

  QuizStatistics({
    required this.totalAttempts,
    required this.highestScore,
    required this.lastScore,
  });

  factory QuizStatistics.empty() {
    return QuizStatistics(
      totalAttempts: 0,
      highestScore: 0,
      lastScore: 0,
    );
  }
}