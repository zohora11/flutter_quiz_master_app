import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_models.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';

/// Shows every question from a completed quiz session with the user's
/// answer laid alongside the correct one, so they can see exactly what
/// they got right, what they missed, and why.
class ReviewScreen extends StatelessWidget {
  final QuizSession session;

  const ReviewScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final total = session.questions.length;
    final correctCount = List.generate(total, (i) => i)
        .where((i) => session.userAnswers[i] == session.questions[i].correctAnswerIndex)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Answer Review')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            FadeSlideIn(index: 0, child: _SummaryBar(total: total, correct: correctCount)),
            const SizedBox(height: 18),
            ...List.generate(total, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: FadeSlideIn(
                  index: i + 1,
                  baseDelay: const Duration(milliseconds: 45),
                  child: _QuestionReviewCard(
                    index: i,
                    question: session.questions[i],
                    userAnswerIndex: session.userAnswers[i],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back to Results'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final int total;
  final int correct;
  const _SummaryBar({required this.total, required this.correct});

  @override
  Widget build(BuildContext context) {
    final wrong = total - correct;
    final brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryStat(
              context,
              icon: Icons.check_circle_rounded,
              color: AppColors.success,
              label: 'Correct',
              value: correct,
            ),
          ),
          Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
          Expanded(
            child: _summaryStat(
              context,
              icon: Icons.cancel_rounded,
              color: AppColors.error,
              label: 'Wrong',
              value: wrong,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryStat(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required int value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuestionReviewCard extends StatelessWidget {
  final int index;
  final Question question;
  final int? userAnswerIndex;

  const _QuestionReviewCard({
    required this.index,
    required this.question,
    required this.userAnswerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isAnswered = userAnswerIndex != null;
    final isCorrect = userAnswerIndex == question.correctAnswerIndex;
    final statusColor = !isAnswered
        ? AppColors.warning
        : (isCorrect ? AppColors.success : AppColors.error);
    final statusLabel = !isAnswered ? 'Skipped' : (isCorrect ? 'Correct' : 'Incorrect');
    final statusIcon = !isAnswered
        ? Icons.remove_circle_rounded
        : (isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.soft(brightness),
        border: Border.all(color: statusColor.withOpacity(0.25), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusLabel,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: statusColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(question.options.length, (optionIndex) {
            final isCorrectOption = optionIndex == question.correctAnswerIndex;
            final isUserOption = optionIndex == userAnswerIndex;

            Color? bg;
            Color? border;
            Widget? trailing;
            Color textColor = Theme.of(context).textTheme.bodyLarge?.color ??
                (brightness == Brightness.dark ? Colors.white : Colors.black);
            FontWeight weight = FontWeight.w500;

            if (isCorrectOption) {
              bg = AppColors.success.withOpacity(0.10);
              border = AppColors.success.withOpacity(0.5);
              textColor = AppColors.success;
              weight = FontWeight.w700;
              trailing = const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.success);
            } else if (isUserOption && !isCorrect) {
              bg = AppColors.error.withOpacity(0.10);
              border = AppColors.error.withOpacity(0.5);
              textColor = AppColors.error;
              weight = FontWeight.w700;
              trailing = const Icon(Icons.cancel_rounded, size: 18, color: AppColors.error);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: bg ?? Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: border ?? Theme.of(context).dividerColor,
                    width: border != null ? 1.4 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        question.options[optionIndex],
                        style: TextStyle(fontSize: 13.5, fontWeight: weight, color: textColor),
                      ),
                    ),
                    if (trailing != null) trailing,
                  ],
                ),
              ),
            );
          }),
          if (!isAnswered)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'You did not answer this question.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          if (question.explanation != null && question.explanation!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question.explanation!,
                      style: const TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
