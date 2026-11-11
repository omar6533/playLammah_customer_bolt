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
  final VoidCallback? onReport;

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
    this.onReport,
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
                if (onReport != null) ...[
                  _ReportButton(onTap: onReport!),
                  const SizedBox(width: 8),
                ],
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

class _ReportButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ReportButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'ملاحظة على السؤال',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCCCCCC)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag_outlined, size: 16, color: Color(0xFF888888)),
              SizedBox(width: 4),
              Text('ملاحظة',
                  style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
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

  bool get _hasMedia => mediaUrl != null && mediaUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.45;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: _kImageBg,
        constraints: BoxConstraints(maxHeight: maxHeight.clamp(200, 420)),
        width: double.infinity,
        child: _hasMedia
            ? Image.network(
                mediaUrl!,
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : const SizedBox(
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryRed),
                        ),
                      ),
                errorBuilder: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
    if (!_hasMedia) return image;

    return GestureDetector(
      onTap: () => showQuestionImageViewer(context, mediaUrl!),
      child: MouseRegion(
        cursor: SystemMouseCursors.zoomIn,
        child: Stack(
          children: [
            image,
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.zoom_in, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
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

/// Full-screen view of a question image with pinch / scroll-wheel zoom.
Future<void> showQuestionImageViewer(BuildContext context, String url) {
  return showDialog(
    context: context,
    barrierColor: Colors.black87,
    builder: (ctx) => Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 6,
                child: Center(
                  child: Image.network(url, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: IconButton.filled(
                onPressed: () => Navigator.pop(ctx),
                style: IconButton.styleFrom(backgroundColor: Colors.white24),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
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
