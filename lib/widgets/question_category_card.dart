import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../models/question.dart';
import '../models/sub_category.dart';

const _kCellRed = Color(0xFFBB1F50);
const _kCellPlayed = Color(0xFFE8C0CE);
const _kCardBg = Color(0xFFFFF0F5);
const _kNamePill = Color(0xFFFFD6E8);

class QuestionCategoryCard extends StatelessWidget {
  final String subCategoryId;
  final List<Question> leftQuestions;
  final List<Question> rightQuestions;
  final List<String> playedQuestions;
  final SubCategory? subcategory;
  final String gameId;
  final bool isNavigating;
  final ValueChanged<bool> onNavigatingChanged;

  const QuestionCategoryCard({
    super.key,
    required this.subCategoryId,
    required this.leftQuestions,
    required this.rightQuestions,
    required this.playedQuestions,
    required this.subcategory,
    required this.gameId,
    required this.isNavigating,
    required this.onNavigatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _QuestionColumn(
                  questions: leftQuestions,
                  playedQuestions: playedQuestions,
                  gameId: gameId,
                  isNavigating: isNavigating,
                  onNavigatingChanged: onNavigatingChanged,
                ),
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    'assets/images/category_placeholder.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        subcategory?.icon ?? '🎯',
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ),
                _QuestionColumn(
                  questions: rightQuestions,
                  playedQuestions: playedQuestions,
                  gameId: gameId,
                  isNavigating: isNavigating,
                  onNavigatingChanged: onNavigatingChanged,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: _kNamePill,
            child: Text(
              subcategory?.nameAr ?? '',
              style: const TextStyle(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionColumn extends StatelessWidget {
  final List<Question> questions;
  final List<String> playedQuestions;
  final String gameId;
  final bool isNavigating;
  final ValueChanged<bool> onNavigatingChanged;

  const _QuestionColumn({
    required this.questions,
    required this.playedQuestions,
    required this.gameId,
    required this.isNavigating,
    required this.onNavigatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: Column(
        children: questions
            .map((q) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: _QuestionCell(
                      question: q,
                      isPlayed: playedQuestions.contains(q.id),
                      gameId: gameId,
                      isNavigating: isNavigating,
                      onNavigatingChanged: onNavigatingChanged,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _QuestionCell extends StatelessWidget {
  final Question question;
  final bool isPlayed;
  final String gameId;
  final bool isNavigating;
  final ValueChanged<bool> onNavigatingChanged;

  const _QuestionCell({
    required this.question,
    required this.isPlayed,
    required this.gameId,
    required this.isNavigating,
    required this.onNavigatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isPlayed || isNavigating)
          ? null
          : () async {
              onNavigatingChanged(true);
              await context.router.push(
                QuestionDisplayRoute(
                  gameId: gameId,
                  questionId: question.id,
                ),
              );
              onNavigatingChanged(false);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isPlayed ? _kCellPlayed : _kCellRed,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '${question.points}',
            style: TextStyle(
              color: isPlayed
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
