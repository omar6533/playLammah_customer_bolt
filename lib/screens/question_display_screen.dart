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
import '../utils/responsive_helper.dart';
import '../utils/orientation_manager.dart';
import '../widgets/primary_button.dart';

@RoutePage()
class QuestionDisplayScreen extends StatelessWidget {
  final String gameId;
  final String questionId;

  const QuestionDisplayScreen({
    Key? key,
    required this.gameId,
    required this.questionId,
  }) : super(key: key);

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
              (q) => q.id == questionId,
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
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          color: AppColors.white,
          child: SafeArea(
            child: _buildActionButtons(context),
          ),
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
            _buildActionButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return PrimaryButton(
      text: 'العودة إلى اللوحة',
      onPressed: () {
        context.read<GameBloc>().add(
              AnswerQuestionEvent(
                gameId: gameId,
                questionId: questionId,
              ),
            );
        context.router.pop();
      },
      icon: Icons.arrow_back,
      backgroundColor: AppColors.darkGray,
    );
  }
}
