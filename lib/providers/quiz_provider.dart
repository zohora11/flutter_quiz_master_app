import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/quiz_models.dart';
import '../services/local_storage_service.dart';

class QuizProvider extends ChangeNotifier {
  QuizSession? _currentSession;
  QuizSession? _lastCompletedSession;
  List<QuizResult> _quizHistory = [];
  QuizStatistics _statistics = QuizStatistics.empty();
  final Map<String, List<Question>> _questionBank;
  final List<Category> _categories = [
    Category(id: 'sports', name: 'Sports', emoji: '⚽', questionCount: 10),
    Category(id: 'science', name: 'Science', emoji: '🔬', questionCount: 10),
    Category(id: 'technology', name: 'Technology', emoji: '💻', questionCount: 10),
    Category(id: 'history', name: 'History', emoji: '📚', questionCount: 10),
    Category(id: 'general', name: 'General Knowledge', emoji: '🧠', questionCount: 10),
  ];

  QuizSession? get currentSession => _currentSession;
  QuizSession? get lastCompletedSession => _lastCompletedSession;
  List<QuizResult> get quizHistory => _quizHistory;
  QuizStatistics get statistics => _statistics;
  List<Category> get categories => _categories;

  QuizProvider({Map<String, List<Question>>? questionBank})
      : _questionBank = questionBank ?? const {} {
    _initializeData();
  }

  Future<void> _initializeData() async {
    _quizHistory = await LocalStorageService.getQuizResults();
    _statistics = await LocalStorageService.getStatistics();
    notifyListeners();
  }

  void startQuiz(String categoryId) {
    final category = _categories.firstWhere((c) => c.id == categoryId);
    final questions = _generateQuestions(categoryId, category.questionCount);

    _currentSession = QuizSession(
      id: const Uuid().v4(),
      categoryId: categoryId,
      questions: questions,
    );
    notifyListeners();
  }

  void selectAnswer(int optionIndex) {
    if (_currentSession != null) {
      _currentSession!.selectAnswer(optionIndex);
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (_currentSession != null && !_currentSession!.isLastQuestion) {
      _currentSession!.nextQuestion();
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentSession != null && _currentSession!.currentQuestionIndex > 0) {
      _currentSession!.previousQuestion();
      notifyListeners();
    }
  }

  Future<QuizResult> submitQuiz() async {
    if (_currentSession == null) throw Exception('No active quiz session');

    final result = _currentSession!.generateResult();
    await LocalStorageService.saveQuizResult(result);

    _quizHistory = await LocalStorageService.getQuizResults();
    _statistics = await LocalStorageService.getStatistics();

    _lastCompletedSession = _currentSession;
    _currentSession = null;
    notifyListeners();

    return result;
  }

  void resetQuiz() {
    _currentSession = null;
    notifyListeners();
  }

  List<Question> _generateQuestions(String categoryId, int count) {
    final bankQuestions = _questionBank[categoryId];
    if (bankQuestions != null && bankQuestions.isNotEmpty) {
      final shuffled = List<Question>.from(bankQuestions)..shuffle();
      return shuffled.take(count).toList();
    }
    return _fallbackQuestionBanks(categoryId, count);
  }

  /// Small built-in question set used only if the bundled JSON asset
  /// couldn't be loaded for some reason.
  List<Question> _fallbackQuestionBanks(String categoryId, int count) {
    final questionBanks = {
      'sports': [
        Question(
          id: '1',
          text: 'Which country won the 2022 FIFA World Cup?',
          options: ['Brazil', 'Argentina', 'France', 'Germany'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: '2',
          text: 'In which sport is Serena Williams famous?',
          options: ['Football', 'Tennis', 'Basketball', 'Badminton'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: '3',
          text: 'How many players are on a basketball court per team?',
          options: ['4', '5', '6', '7'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: '4',
          text: 'Which team won the 2023 IPL cricket tournament?',
          options: ['Mumbai Indians', 'Chennai Super Kings', 'Kolkata Knight Riders', 'Delhi Capitals'],
          correctAnswerIndex: 2,
        ),
        Question(
          id: '5',
          text: 'What is the height of a basketball hoop?',
          options: ['8 feet', '10 feet', '12 feet', '9 feet'],
          correctAnswerIndex: 1,
        ),
      ],
      'science': [
        Question(
          id: '1',
          text: 'What is the chemical symbol for Gold?',
          options: ['Go', 'Gd', 'Au', 'Ag'],
          correctAnswerIndex: 2,
        ),
        Question(
          id: '2',
          text: 'How many bones are in the human body?',
          options: ['186', '206', '226', '246'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: '3',
          text: 'What is the speed of light?',
          options: ['300,000 km/s', '150,000 km/s', '450,000 km/s', '200,000 km/s'],
          correctAnswerIndex: 0,
        ),
        Question(
          id: '4',
          text: 'Which gas do plants absorb from the atmosphere?',
          options: ['Oxygen', 'Nitrogen', 'Carbon Dioxide', 'Argon'],
          correctAnswerIndex: 2,
        ),
        Question(
          id: '5',
          text: 'What is the hardest natural substance?',
          options: ['Gold', 'Iron', 'Diamond', 'Platinum'],
          correctAnswerIndex: 2,
        ),
      ],
      'technology': [
        Question(
          id: '1',
          text: 'Who is considered the founder of the World Wide Web?',
          options: ['Bill Gates', 'Tim Berners-Lee', 'Steve Jobs', 'Linus Torvalds'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: '2',
          text: 'What does HTTP stand for?',
          options: ['Hypertext Transfer Protocol', 'High Transfer Text Protocol', 'Hyperlink and Transfer Protocol', 'Home Tool Transfer Protocol'],
          correctAnswerIndex: 0,
        ),
        Question(
          id: '3',
          text: 'Which programming language is known as the "language of the web"?',
          options: ['Python', 'Java', 'JavaScript', 'C++'],
          correctAnswerIndex: 2,
        ),
        Question(
          id: '4',
          text: 'What does AI stand for?',
          options: ['Advanced Internet', 'Artificial Intelligence', 'Application Integration', 'Automated Intelligence'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: '5',
          text: 'Which company developed the Android operating system?',
          options: ['Apple', 'Microsoft', 'Google', 'Samsung'],
          correctAnswerIndex: 2,
        ),
      ],
      'history': [
        Question(
          id: '1',
          text: 'In which year did World War II end?',
          options: ['1943', '1944', '1945', '1946'],
          correctAnswerIndex: 2,
        ),
        Question(
          id: '2',
          text: 'Who was the first President of the United States?',
          options: ['Thomas Jefferson', 'George Washington', 'John Adams', 'James Madison'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: '3',
          text: 'In which year did the Titanic sink?',
          options: ['1910', '1911', '1912', '1913'],
          correctAnswerIndex: 2,
        ),
        Question(
          id: '4',
          text: 'Who invented the telephone?',
          options: ['Thomas Edison', 'Alexander Graham Bell', 'Nikola Tesla', 'Benjamin Franklin'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: '5',
          text: 'Which civilization built the pyramids of Giza?',
          options: ['Greek', 'Roman', 'Egyptian', 'Mesopotamian'],
          correctAnswerIndex: 2,
        ),
      ],
      'general': [
        Question(
          id: '1',
          text: 'What is the capital of France?',
          options: ['Lyon', 'Paris', 'Marseille', 'Nice'],
          correctAnswerIndex: 1,
        ),
        Question(
          id: '2',
          text: 'How many continents are there?',
          options: ['5', '6', '7', '8'],
          correctAnswerIndex: 2,
        ),
        Question(
          id: '3',
          text: 'What is the largest planet in our solar system?',
          options: ['Saturn', 'Neptune', 'Jupiter', 'Uranus'],
          correctAnswerIndex: 2,
        ),
        Question(
          id: '4',
          text: 'Which country has the largest population?',
          options: ['India', 'Indonesia', 'China', 'United States'],
          correctAnswerIndex: 0,
        ),
        Question(
          id: '5',
          text: 'What is the smallest country in the world?',
          options: ['Monaco', 'San Marino', 'Vatican City', 'Liechtenstein'],
          correctAnswerIndex: 2,
        ),
      ],
    };

    return questionBanks[categoryId] ?? [];
  }
}