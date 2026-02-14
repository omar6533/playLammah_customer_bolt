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
  bool _isSubmitting = false;

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
          child: !_showAnswer
              ? _buildFullScreenQuestion(context, question)
              : _buildFullScreenAnswer(context, question),
        ),
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          color: AppColors.white,
          child: SafeArea(
            child: _buildActionButtons(context, question),
          ),
        ),
      ],
    );
  }

  Widget _buildFullScreenQuestion(BuildContext context, question) {
    return Container(
      color: AppColors.primaryYellow,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${question.points} نقطة',
                  style: AppTextStyles.extraLargeTvBold.copyWith(
                    color: AppColors.white,
                    fontSize: 32,
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              if (question.mediaUrl != null &&
                  question.mediaUrl!.isNotEmpty) ...[
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      question.mediaUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.white,
                          child: Icon(Icons.broken_image,
                              size: 64, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
              ],
              Text(
                question.questionTextAr,
                style: AppTextStyles.extraLargeTvBold.copyWith(
                  color: AppColors.darkGray,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenAnswer(BuildContext context, question) {
    return Container(
      color: AppColors.primaryRed,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'الإجابة',
                style: AppTextStyles.extraLargeTvBold.copyWith(
                  color: AppColors.white,
                  fontSize: 36,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              if (question.mediaUrl != null &&
                  question.mediaUrl!.isNotEmpty) ...[
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.35,
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      question.mediaUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.white,
                          child: Icon(Icons.broken_image,
                              size: 64, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
              ],
              Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question.answerAr,
                  style: AppTextStyles.extraLargeTvBold.copyWith(
                    color: AppColors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
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
        onPressed: _isSubmitting
            ? null
            : () {
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
      onPressed: _isSubmitting
          ? null
          : () => _showTeamSelectionDialog(context, question.points),
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
                      onPressed: () =>
                          _handleTeamSelection(dialogContext, 'left', points),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: PrimaryButton(
                      text: rightTeamName,
                      onPressed: () =>
                          _handleTeamSelection(dialogContext, 'right', points),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              PrimaryButton(
                text: 'ولا أحد',
                onPressed: () =>
                    _handleTeamSelection(dialogContext, 'none', points),
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

  void _handleTeamSelection(
      BuildContext dialogContext, String winner, int points) {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    Navigator.of(dialogContext).pop();

    _showLoadingAndAwardPoints(winner, points);
  }

  Future<void> _showLoadingAndAwardPoints(String winner, int points) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryRed,
          ),
        ),
      ),
    );

    try {
      await _awardPoints(context, winner, points);

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // If game is over, the Grid listener will handle replace with GameOverRoute
      // We only pop if the state is still GameInProgress
      final gameState = context.read<GameBloc>().state;
      if (gameState is GameInProgress) {
        // context.router.pop();
      }
    } catch (e) {
      debugPrint('❌ Error awarding points: $e');

      if (!mounted) return;

      Navigator.of(context).pop();

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _awardPoints(
      BuildContext context, String winner, int points) async {
    final gameBloc = context.read<GameBloc>();
    final questionBloc = context.read<QuestionBloc>();
    final gameState = gameBloc.state;
    if (gameState is! GameInProgress) return;

    // 1. Dispatch atomic update event
    gameBloc.add(
      AwardPointsEvent(
        gameId: widget.gameId,
        questionId: widget.questionId,
        winner: winner,
        points: points,
      ),
    );

    // 2. Wait for synchronization (max 5s)
    try {
      await gameBloc.stream.firstWhere((state) {
        if (state is GameError) throw Exception(state.message);
        return state is GameInProgress &&
            state.playedQuestions.contains(widget.questionId);
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('⚠️ Sync warning: $e');
    }

    // 3. Check for game completion
    final questionState = questionBloc.state;
    if (questionState is QuestionLoaded) {
      final updatedGameState = gameBloc.state;
      if (updatedGameState is GameInProgress) {
        if (updatedGameState.playedQuestions.length >=
            questionState.questions.length) {
          debugPrint('🏁 Game Complete! Determining winner...');

          String gameWinner;
          final lScore = updatedGameState.leftTeam.score;
          final rScore = updatedGameState.rightTeam.score;

          if (lScore > rScore) {
            gameWinner = updatedGameState.leftTeam.name;
          } else if (rScore > lScore) {
            gameWinner = updatedGameState.rightTeam.name;
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
