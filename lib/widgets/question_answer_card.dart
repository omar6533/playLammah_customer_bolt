import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const _kTimerGreen = Color(0xFF4B5E3C);
const _kCardBorder = Color(0xFFF0E0E6);
const _kCardRadius = 20.0;
const _kImageBg = Color(0xFFFFF0F5);

/// White question card shown during gameplay.
/// Displays timer, points badge, question text, illustration/answer, and action button.
class QuestionAnswerCard extends StatelessWidget {
  final String timerDisplay;
  final bool timerRunning;
  final int points;
  final String questionTextAr;
  final String? mediaUrl;
  final bool showAnswer;
  final String answerAr;
  final bool isSubmitting;
  final VoidCallback onToggleTimer;
  final VoidCallback onResetTimer;
  final VoidCallback onShowAnswer;
  final VoidCallback onSelectTeam;

  const QuestionAnswerCard({
    super.key,
    required this.timerDisplay,
    required this.timerRunning,
    required this.points,
    required this.questionTextAr,
    this.mediaUrl,
    required this.showAnswer,
    required this.answerAr,
    required this.isSubmitting,
    required this.onToggleTimer,
    required this.onResetTimer,
    required this.onShowAnswer,
    required this.onSelectTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: _kCardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: timer | points badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _TimerChip(
                  display: timerDisplay,
                  running: timerRunning,
                  onToggle: onToggleTimer,
                  onReset: onResetTimer,
                ),
                const Spacer(),
                _PointsBadge(points: points),
              ],
            ),
          ),
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                children: [
                  Text(
                    questionTextAr,
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.w800,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (!showAnswer)
                    _Illustration(mediaUrl: mediaUrl)
                  else
                    _AnswerReveal(answerAr: answerAr),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // Bottom action button (left-aligned to match Figma)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: showAnswer
                  ? _ActionButton(
                      label: 'أي فريق جاوب صح؟',
                      onTap: isSubmitting ? null : onSelectTeam,
                    )
                  : _ActionButton(
                      label: 'الإجابة',
                      onTap: isSubmitting ? null : onShowAnswer,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _TimerChip extends StatelessWidget {
  final String display;
  final bool running;
  final VoidCallback onToggle;
  final VoidCallback onReset;

  const _TimerChip({
    required this.display,
    required this.running,
    required this.onToggle,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _kTimerGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              running ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            display,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onReset,
            child: const Icon(Icons.refresh, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  final int points;
  const _PointsBadge({required this.points});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: Text(
        '$points',
        style: const TextStyle(
          color: AppColors.primaryRed,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final String? mediaUrl;
  const _Illustration({this.mediaUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: _kImageBg,
        constraints: const BoxConstraints(maxHeight: 260),
        width: double.infinity,
        child: (mediaUrl != null && mediaUrl!.isNotEmpty)
            ? Image.network(
                mediaUrl!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Image.asset(
      'assets/images/category_placeholder.png',
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Padding(
        padding: EdgeInsets.all(32),
        child: Text('🎯', style: TextStyle(fontSize: 64)),
      ),
    );
  }
}

class _AnswerReveal extends StatelessWidget {
  final String answerAr;
  const _AnswerReveal({required this.answerAr});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: AppColors.primaryRed.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          const Text(
            'الإجابة',
            style: TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            answerAr,
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
