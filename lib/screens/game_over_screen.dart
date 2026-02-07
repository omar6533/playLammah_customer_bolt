import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_state.dart';
import '../utils/responsive_helper.dart';
import '../widgets/primary_button.dart';

@RoutePage()
class GameOverScreen extends StatelessWidget {
  const GameOverScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenPadding = ResponsiveHelper.getScreenPadding(context);

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      body: SafeArea(
        child: BlocBuilder<GameBloc, GameState>(
          builder: (context, state) {
            if (state is! GameOver) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              );
            }

            return SingleChildScrollView(
              padding: screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSpacing.xxl),
                  _buildWinnerSection(context, state),
                  SizedBox(height: AppSpacing.xxl),
                  _buildScoreboard(context, state),
                  SizedBox(height: AppSpacing.xxl),
                  _buildActionButtons(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWinnerSection(BuildContext context, GameOver state) {
    final isDraw = state.leftTeamScore == state.rightTeamScore;
    final winnerColor =
        state.winner == 'left' ? AppColors.primaryRed : AppColors.primaryYellow;

    return Column(
      children: [
        Icon(
          isDraw ? Icons.handshake : Icons.emoji_events,
          size: ResponsiveHelper.getResponsiveValue(
            context,
            mobile: 80,
            tablet: 100,
            desktop: 120,
          ),
          color: isDraw ? AppColors.darkGray : winnerColor,
        ),
        SizedBox(height: AppSpacing.lg),
        Container(
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDraw ? AppColors.darkGray : winnerColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            isDraw ? 'تعادل!' : 'الفائز!',
            style: AppTextStyles.extraLargeTvBold.copyWith(
              color: AppColors.white,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 36,
                tablet: 48,
                desktop: 60,
              ),
            ),
          ),
        ),
        if (!isDraw) ...[
          SizedBox(height: AppSpacing.md),
          Text(
            state.winner == 'left'
                ? state.gameRecord.leftTeamName
                : state.gameRecord.rightTeamName,
            style: AppTextStyles.extraLargeTvBold.copyWith(
              color: AppColors.darkGray,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 28,
                tablet: 36,
                desktop: 44,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildScoreboard(BuildContext context, GameOver state) {
    return Container(
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
        children: [
          Text(
            'النتيجة النهائية',
            style: AppTextStyles.largeTvBold.copyWith(
              color: AppColors.darkGray,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          ResponsiveHelper.isLandscape(context)
              ? _buildScoreBoardLandscape(state)
              : _buildScoreBoardPortrait(state),
        ],
      ),
    );
  }

  Widget _buildScoreBoardPortrait(GameOver state) {
    return Column(
      children: [
        _buildTeamScoreCard(
          state.gameRecord.leftTeamName,
          state.leftTeamScore,
          AppColors.primaryRed,
          state.winner == 'left',
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          'VS',
          style: AppTextStyles.largeTvBold.copyWith(
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        _buildTeamScoreCard(
          state.gameRecord.rightTeamName,
          state.rightTeamScore,
          AppColors.primaryYellow,
          state.winner == 'right',
        ),
      ],
    );
  }

  Widget _buildScoreBoardLandscape(GameOver state) {
    return Row(
      children: [
        Expanded(
          child: _buildTeamScoreCard(
            state.gameRecord.leftTeamName,
            state.leftTeamScore,
            AppColors.primaryRed,
            state.winner == 'left',
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'VS',
            style: AppTextStyles.largeTvBold.copyWith(
              color: AppColors.darkGray,
            ),
          ),
        ),
        Expanded(
          child: _buildTeamScoreCard(
            state.gameRecord.rightTeamName,
            state.rightTeamScore,
            AppColors.primaryYellow,
            state.winner == 'right',
          ),
        ),
      ],
    );
  }

  Widget _buildTeamScoreCard(
      String teamName, int score, Color color, bool isWinner) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: isWinner ? 4 : 2,
        ),
      ),
      child: Column(
        children: [
          if (isWinner) Icon(Icons.emoji_events, color: color, size: 32),
          if (isWinner) SizedBox(height: AppSpacing.sm),
          Text(
            teamName,
            style: AppTextStyles.mediumBold.copyWith(
              color: AppColors.darkGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score',
              style: AppTextStyles.extraLargeTvBold.copyWith(
                color: AppColors.white,
                fontSize: 48,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameOver state) {
    return Column(
      children: [
        PrimaryButton(
          text: 'العودة للرئيسية',
          onPressed: () {
            context.router.pushAndPopUntil(
              const LandingRoute(),
              predicate: (_) => false,
            );
          },
          icon: Icons.home,
          backgroundColor: AppColors.primaryRed,
        ),
        SizedBox(height: AppSpacing.md),
        PrimaryButton(
          text: 'مشاركة النتيجة',
          onPressed: () {
            // TODO: Implement share functionality
          },
          icon: Icons.share,
          backgroundColor: AppColors.darkGray,
        ),
      ],
    );
  }
}
