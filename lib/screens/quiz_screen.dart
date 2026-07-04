import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_models.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;

  const QuizScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.categoryGradient(widget.categoryId).first;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => _showExitConfirmation(context),
          ),
          title: const Text('Quiz'),
        ),
        body: Consumer<QuizProvider>(
          builder: (context, quizProvider, _) {
            final session = quizProvider.currentSession;
            if (session == null) {
              return const Center(child: Text('No quiz session found'));
            }

            final currentQuestion = session.questions[session.currentQuestionIndex];
            final progress = (session.currentQuestionIndex + 1) / session.questions.length;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProgressSection(
                      session.currentQuestionIndex + 1,
                      session.questions.length,
                      progress,
                      accent,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          transitionBuilder: (child, animation) {
                            final offsetAnim = Tween<Offset>(
                              begin: const Offset(0.06, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(position: offsetAnim, child: child),
                            );
                          },
                          child: Column(
                            key: ValueKey(session.currentQuestionIndex),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildQuestionCard(context, currentQuestion, accent),
                              const SizedBox(height: 20),
                              _buildOptionsSection(context, currentQuestion, quizProvider, accent),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNavigationButtons(context, session, quizProvider, accent),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressSection(int current, int total, double progress, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'Question $current of $total',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: accent,
                ),
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Theme.of(context).dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, Question question, Color accent) {
    final brightness = Theme.of(context).brightness;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft(brightness),
        border: Border.all(color: accent.withOpacity(0.15), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.quiz_rounded, color: accent, size: 22),
          const SizedBox(height: 10),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection(
    BuildContext context,
    Question question,
    QuizProvider quizProvider,
    Color accent,
  ) {
    final session = quizProvider.currentSession!;
    final currentIndex = session.currentQuestionIndex;
    final selectedAnswer = session.userAnswers[currentIndex];
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        question.options.length,
        (optionIndex) {
          final isSelected = selectedAnswer == optionIndex;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: GestureDetector(
              onTap: () => quizProvider.selectAnswer(optionIndex),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? accent : Theme.of(context).dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? accent.withOpacity(0.08) : Colors.transparent,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? accent : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? accent : Theme.of(context).dividerColor,
                          width: 1.6,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isSelected
                          ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                          : Text(
                              letters[optionIndex],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[optionIndex],
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    QuizSession session,
    QuizProvider quizProvider,
    Color accent,
  ) {
    return Row(
      children: [
        if (session.currentQuestionIndex > 0)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => quizProvider.previousQuestion(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Previous'),
            ),
          ),
        if (session.currentQuestionIndex > 0) const SizedBox(width: 12),
        Expanded(
          flex: session.currentQuestionIndex > 0 ? 1 : 2,
          child: session.isLastQuestion
              ? FilledButton.icon(
                  onPressed: session.isAnswered && !_submitting
                      ? () => _handleSubmit(context, quizProvider)
                      : null,
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.flag_rounded, size: 18),
                  label: Text(_submitting ? 'Submitting…' : 'Submit'),
                )
              : FilledButton.icon(
                  onPressed: session.isAnswered ? () => quizProvider.nextQuestion() : null,
                  style: FilledButton.styleFrom(backgroundColor: accent),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Next'),
                ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context, QuizProvider quizProvider) async {
    final session = quizProvider.currentSession!;
    setState(() => _submitting = true);
    final result = await quizProvider.submitQuiz();
    if (!mounted) return;
    context.pushReplacement(
      '/result',
      extra: {
        'result': result,
        'session': session,
      },
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<QuizProvider>().resetQuiz();
              context.go('/');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
