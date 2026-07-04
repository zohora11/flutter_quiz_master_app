import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_models.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/score_ring.dart';
import '../widgets/fade_slide_in.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const ResultScreen({
    super.key,
    required this.resultData,
  });

  @override
  Widget build(BuildContext context) {
    final result = resultData['result'] as QuizResult;
    final session = resultData['session'] as QuizSession?;
    final percentage = double.tryParse(result.percentage) ?? 0;
    final performanceColor = _getPerformanceColor(percentage);
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quiz Completed'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeSlideIn(
                index: 0,
                child: _buildScoreHeader(context, result, percentage, performanceColor),
              ),
              const SizedBox(height: 24),
              FadeSlideIn(
                index: 1,
                child: _buildPerformanceMetrics(result, context, brightness),
              ),
              const SizedBox(height: 20),
              FadeSlideIn(
                index: 2,
                child: _buildPerformanceGrade(percentage, performanceColor),
              ),
              const SizedBox(height: 28),
              FadeSlideIn(
                index: 3,
                child: _buildActionButtons(context, session),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }

  String _getPerformanceGrade(double percentage) {
    if (percentage >= 90) return 'Excellent! 🎉';
    if (percentage >= 80) return 'Great Job! 👏';
    if (percentage >= 70) return 'Good! 👍';
    if (percentage >= 60) return 'Fair 😊';
    return 'Keep Practicing 💪';
  }

  Widget _buildScoreHeader(
    BuildContext context,
    QuizResult result,
    double percentage,
    Color performanceColor,
  ) {
    return Center(
      child: Column(
        children: [
          ScoreRing(
            percentage: percentage,
            color: performanceColor,
            trackColor: Theme.of(context).dividerColor,
            size: 176,
            strokeWidth: 14,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  result.percentage.contains('.')
                      ? result.percentage.split('.').first
                      : result.percentage,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: performanceColor,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: performanceColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${result.correctAnswers} of ${result.totalQuestions} correct',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(QuizResult result, BuildContext context, Brightness brightness) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: AppShadows.soft(brightness),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3),
          ),
          const SizedBox(height: 12),
          _buildMetricRow(
            label: 'Total Questions',
            value: result.totalQuestions.toString(),
            context: context,
          ),
          _buildMetricRow(
            label: 'Correct Answers',
            value: result.correctAnswers.toString(),
            context: context,
            valueColor: AppColors.success,
          ),
          _buildMetricRow(
            label: 'Wrong Answers',
            value: result.wrongAnswers.toString(),
            context: context,
            valueColor: result.wrongAnswers > 0 ? AppColors.error : null,
          ),
          _buildMetricRow(
            label: 'Final Score',
            value: '${result.score}/${result.totalScore}',
            context: context,
          ),
          _buildMetricRow(
            label: 'Date & Time',
            value: DateFormat('MMM d, yyyy • h:mm a').format(result.timestamp),
            context: context,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required BuildContext context,
    Color? valueColor,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: -0.2,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: valueColor,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrade(double percentage, Color performanceColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: LinearGradient(
          colors: [
            performanceColor.withOpacity(0.16),
            performanceColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: performanceColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        _getPerformanceGrade(percentage),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: performanceColor,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, QuizSession? session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (session != null)
          FilledButton.icon(
            onPressed: () => context.push('/review', extra: session),
            icon: const Icon(Icons.fact_check_rounded, size: 19),
            label: const Text('Review Answers'),
          ),
        if (session != null) const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: session != null
              ? () {
            context.read<QuizProvider>().startQuiz(session.categoryId);
            context.pushReplacement('/quiz/${session.categoryId}');
          }
              : () => context.go('/'),
          icon: const Icon(Icons.replay_rounded, size: 19),
          label: const Text('Play Again'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => context.go('/'),
          child: const Text('Back to Home'),
        ),
      ],
    );
  }
}
