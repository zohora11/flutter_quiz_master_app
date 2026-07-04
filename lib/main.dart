import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/theme_provider.dart';
import 'providers/quiz_provider.dart';
import 'models/quiz_models.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/review_screen.dart';
import 'services/quiz_data_loader.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final questionBank = await QuizDataLoader.load();
  runApp(MyApp(questionBank: questionBank));
}

class MyApp extends StatelessWidget {
  final Map<String, List<Question>> questionBank;

  const MyApp({super.key, required this.questionBank});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(questionBank: questionBank),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Quiz Master',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/quiz/:categoryId',
        name: 'quiz',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          return QuizScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: '/result',
        name: 'result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ResultScreen(resultData: extra);
        },
      ),
      GoRoute(
        path: '/review',
        name: 'review',
        builder: (context, state) {
          final session = state.extra as QuizSession;
          return ReviewScreen(session: session);
        },
      ),
    ],
  );
}
