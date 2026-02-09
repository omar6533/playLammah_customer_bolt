import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../bloc/question/question_bloc.dart';
import '../bloc/question/question_state.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_event.dart';
import '../bloc/game/game_state.dart';
import '../utils/responsive_helper.dart';
import '../utils/orientation_manager.dart';
import '../widgets/primary_button.dart';

@RoutePage()
class QuestionDisplayScreen extends StatefulWidget {
  final String gameId;
  final String questionId;

  const QuestionDisplayScreen({
    Key? key,
    required this.gameId,
    required this.questionId,
  }) : super(key: key);

  @override
  State<QuestionDisplayScreen> createState() => _QuestionDisplayScreenState();
}

class _QuestionDisplayScreenState extends State<QuestionDisplayScreen> {
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    return GameScreenWrapper(
      child: Scaffold(
        backgroundColor: AppColors.primaryYellow,
        appBar: AppBar(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: AppColors.white,
          title: Text('السؤال', style: AppTextStyles.largeTvBold),
        ),
        body: BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is! QuestionLoaded) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              );
            }

            final question = state.questions.firstWhere(
              (q) => q.id == widget.questionId,
              orElse: () => state.questions.first,
            );

            return ResponsiveHelper.isLandscape(context)
                ? _buildLandscapeLayout(context, question)
                : _buildPortraitLayout(context, question);
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BuildContext context, question) {
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    return SingleChildScrollView(
      padding: screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: AppSpacing.xl),
          _buildPointsBadge(context, question.points),
          SizedBox(height: AppSpacing.xxl),
          _buildQuestionCard(context, question),
          SizedBox(height: AppSpacing.xxl),
          _buildAnswerSection(context, question),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, question) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: _buildQuestionCard(context, question),
                ),
              ),
              Expanded(
                child: Center(
                  child: _buildAnswerSection(context, question),
                ),
              ),
            ],
          ),
        ),
        BlocBuilder<QuestionBloc, QuestionState>(
          builder: (context, state) {
            if (state is! QuestionLoaded) return const SizedBox();
            final question = state.questions.firstWhere(
              (q) => q.id == widget.questionId,
              orElse: () => state.questions.first,
            );
            return Container(
              padding: EdgeInsets.all(AppSpacing.md),
              color: AppColors.white,
              child: SafeArea(
                child: _buildActionButtons(context, question),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPointsBadge(BuildContext context, int points) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: AppColors.white, size: 32),
            SizedBox(width: AppSpacing.sm),
            Text(
              '$points نقطة',
              style: AppTextStyles.extraLargeTvBold.copyWith(
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, question) {
    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'السؤال',
            style: AppTextStyles.largeTvBold.copyWith(
              color: AppColors.primaryRed,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            question.questionTextAr,
            style: AppTextStyles.extraLargeTvBold.copyWith(
              color: AppColors.darkGray,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 24,
                tablet: 32,
                desktop: 40,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(BuildContext context, question) {
    if (!_showAnswer) {
      return Container(
        margin: EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryRed.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock,
              color: AppColors.white,
              size: 64,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'اضغط لإظهار الإجابة',
              style: AppTextStyles.largeTvBold.copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            if (!ResponsiveHelper.isLandscape(context)) ...[
              SizedBox(height: AppSpacing.xxl),
              _buildActionButtons(context, question),
            ],
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الإجابة',
            style: AppTextStyles.largeTvBold.copyWith(
              color: AppColors.white,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              question.answerAr,
              style: AppTextStyles.extraLargeTvBold.copyWith(
                color: AppColors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 22,
                  tablet: 28,
                  desktop: 36,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (!ResponsiveHelper.isLandscape(context)) ...[
            SizedBox(height: AppSpacing.xxl),
            _buildActionButtons(context, question),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, question) {
    if (!_showAnswer) {
      return PrimaryButton(
        text: 'إظهار الإجابة',
        onPressed: () {
          setState(() {
            _showAnswer = true;
          });
        },
        icon: Icons.visibility,
        backgroundColor: AppColors.primaryYellow,
      );
    }

    return PrimaryButton(
      text: 'أي فريق ؟',
      onPressed: () => _showTeamSelectionDialog(context, question.points),
      icon: Icons.emoji_events,
      backgroundColor: AppColors.darkGray,
    );
  }

  void _showTeamSelectionDialog(BuildContext context, int points) {
    final gameState = context.read<GameBloc>().state;
    if (gameState is! GameInProgress) return;

    final gameRecord = gameState.gameRecord;
    final leftTeamName = gameRecord.leftTeamName;
    final rightTeamName = gameRecord.rightTeamName;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primaryRed, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أي فريق جاوب صح ؟',
                style: AppTextStyles.extraLargeTvBold.copyWith(
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: leftTeamName,
                      onPressed: () async {
                        final router = context.router;
                        final navigator = Navigator.of(dialogContext);
                        await _awardPoints(context, 'left', points);
                        navigator.pop();
                        if (context.mounted) {
                          router.pop();
                        }
                      },
                      backgroundColor: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PrimaryButton(
                      text: rightTeamName,
                      onPressed: () async {
                        final router = context.router;
                        final navigator = Navigator.of(dialogContext);
                        await _awardPoints(context, 'right', points);
                        navigator.pop();
                        if (context.mounted) {
                          router.pop();
                        }
                      },
                      backgroundColor: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              PrimaryButton(
                text: 'ولا أحد',
                onPressed: () async {
                  final router = context.router;
                  final navigator = Navigator.of(dialogContext);
                  await _awardPoints(context, 'none', points);
                  navigator.pop();
                  if (context.mounted) {
                    router.pop();
                  }
                },
                backgroundColor: Colors.grey,
              ),
              SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Text(
                  'العودة للإجابة',
                  style: AppTextStyles.largeTv.copyWith(
                    color: AppColors.primaryRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _awardPoints(
      BuildContext context, String winner, int points) async {
    final gameBloc = context.read<GameBloc>();
    final questionBloc = context.read<QuestionBloc>();
    final gameState = gameBloc.state;
    if (gameState is! GameInProgress) return;

    final gameRecord = gameState.gameRecord;
    int newLeftScore = gameRecord.leftTeamScore;
    int newRightScore = gameRecord.rightTeamScore;
    String newTurn = gameRecord.currentTurn;

    debugPrint(
        '🎮 Before Award - Left: ${gameRecord.leftTeamName} ($newLeftScore), Right: ${gameRecord.rightTeamName} ($newRightScore), Turn: $newTurn');
    debugPrint('🏆 Winner: $winner, Points: $points');

    if (winner == 'left') {
      newLeftScore += points;
      newTurn = 'right';
    } else if (winner == 'right') {
      newRightScore += points;
      newTurn = 'left';
    } else {
      newTurn = gameRecord.currentTurn == 'left' ? 'right' : 'left';
    }

    debugPrint(
        '🎮 After Award - Left: ${gameRecord.leftTeamName} ($newLeftScore), Right: ${gameRecord.rightTeamName} ($newRightScore), Turn: $newTurn');

    gameBloc.add(
      UpdateScoreEvent(
        gameId: widget.gameId,
        leftTeamScore: newLeftScore,
        rightTeamScore: newRightScore,
        currentTurn: newTurn,
      ),
    );

    await gameBloc.stream.firstWhere((state) =>
        state is GameInProgress &&
        state.gameRecord.leftTeamScore == newLeftScore &&
        state.gameRecord.rightTeamScore == newRightScore &&
        state.gameRecord.currentTurn == newTurn);

    debugPrint('✅ State updated, now marking question as played');

    gameBloc.add(
      AnswerQuestionEvent(
        gameId: widget.gameId,
        questionId: widget.questionId,
      ),
    );

    // Wait for the question to be marked as played
    await gameBloc.stream.firstWhere((state) =>
        state is GameInProgress &&
        state.playedQuestions.contains(widget.questionId));

    // Check if all questions have been answered
    final questionState = questionBloc.state;
    if (questionState is QuestionLoaded) {
      final updatedGameState = gameBloc.state;
      if (updatedGameState is GameInProgress) {
        final totalQuestions = questionState.questions.length;
        final playedQuestions = updatedGameState.playedQuestions.length;

        debugPrint(
            '🎯 Game Progress: $playedQuestions / $totalQuestions questions played');

        if (playedQuestions >= totalQuestions) {
          debugPrint('🏁 All questions answered! Completing game...');

          // Determine winner
          String gameWinner;
          if (newLeftScore > newRightScore) {
            gameWinner = gameRecord.leftTeamName;
          } else if (newRightScore > newLeftScore) {
            gameWinner = gameRecord.rightTeamName;
          } else {
            gameWinner = 'tie';
          }

          gameBloc.add(
            CompleteGameEvent(
              gameId: widget.gameId,
              winner: gameWinner,
            ),
          );
        }
      }
    }
  }
}
