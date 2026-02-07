import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/routes/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_state.dart';
import '../bloc/question/question_bloc.dart';
import '../bloc/question/question_event.dart';
import '../bloc/question/question_state.dart';
import '../models/question.dart';
import '../utils/responsive_helper.dart';
import '../utils/orientation_manager.dart';

@RoutePage()
class QuestionGridScreen extends StatefulWidget {
  final String gameId;

  const QuestionGridScreen({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  State<QuestionGridScreen> createState() => _QuestionGridScreenState();
}

class _QuestionGridScreenState extends State<QuestionGridScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<QuestionBloc>()
            .add(LoadQuestionsEvent(gameId: widget.gameId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameScreenWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: _buildAppBar(),
        body: BlocBuilder<GameBloc, GameState>(
          builder: (context, gameState) {
            if (gameState is! GameInProgress) {
              return const Center(
                child:
                    CircularProgressIndicator(color: AppColors.primaryYellow),
              );
            }

            return BlocBuilder<QuestionBloc, QuestionState>(
              builder: (context, questionState) {
                if (questionState is QuestionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryYellow),
                  );
                }

                if (questionState is QuestionError) {
                  return Center(
                    child: Text(
                      questionState.message,
                      style: AppTextStyles.mediumRegular
                          .copyWith(color: AppColors.white),
                    ),
                  );
                }

                if (questionState is QuestionLoaded) {
                  return ResponsiveHelper.isLandscape(context)
                      ? _buildLandscapeLayout(gameState, questionState)
                      : _buildPortraitLayout(gameState, questionState);
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryRed,
      foregroundColor: AppColors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.router.pop(),
      ),
      title: Text('لوحة الأسئلة', style: AppTextStyles.largeTvBold),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app),
          onPressed: () => _showExitDialog(),
        ),
      ],
    );
  }

  Widget _buildPortraitLayout(
      GameInProgress gameState, QuestionLoaded questionState) {
    return _buildQuestionGrid(gameState, questionState);
  }

  Widget _buildLandscapeLayout(
      GameInProgress gameState, QuestionLoaded questionState) {
    return Row(
      children: [
        Container(
          width: 120,
          color: AppColors.primaryRed,
          child: _buildScoreBoardVertical(gameState, left: true),
        ),
        Expanded(
          child: _buildQuestionGrid(gameState, questionState),
        ),
        Container(
          width: 120,
          color: AppColors.primaryYellow,
          child: _buildScoreBoardVertical(gameState, left: false),
        ),
      ],
    );
  }

  Widget _buildScoreBoard(GameInProgress gameState) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      color: AppColors.darkGray.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTeamScore(
            gameState.leftTeam.name,
            gameState.leftTeam.score,
            AppColors.primaryRed,
            gameState.gameRecord.currentTurn == 'left',
          ),
          Container(
            width: 2,
            height: 60,
            color: AppColors.white.withOpacity(0.3),
          ),
          _buildTeamScore(
            gameState.rightTeam.name,
            gameState.rightTeam.score,
            AppColors.primaryYellow,
            gameState.gameRecord.currentTurn == 'right',
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBoardVertical(GameInProgress gameState,
      {required bool left}) {
    final team = left ? gameState.leftTeam : gameState.rightTeam;
    final color = left ? AppColors.primaryRed : AppColors.primaryYellow;
    final isActive =
        gameState.gameRecord.currentTurn == (left ? 'left' : 'right');

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: left ? 3 : 1,
            child: Text(
              team.name,
              style: AppTextStyles.largeTvBold.copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: AppColors.white, width: 3)
                  : null,
            ),
            child: Text(
              '${team.score}',
              style: AppTextStyles.extraLargeTvBold.copyWith(
                color: color,
                fontSize: 40,
              ),
            ),
          ),
          if (isActive) ...[
            SizedBox(height: AppSpacing.sm),
            Icon(Icons.arrow_forward, color: AppColors.white, size: 32),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamScore(
      String teamName, int score, Color color, bool isActive) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(
          children: [
            Text(
              teamName,
              style: AppTextStyles.mediumBold.copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.xs),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$score',
                style: AppTextStyles.extraLargeTvBold.copyWith(
                  color: AppColors.white,
                  fontSize: 32,
                ),
              ),
            ),
            if (isActive) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                'دوره',
                style: AppTextStyles.smallRegular.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionGrid(
      GameInProgress gameState, QuestionLoaded questionState) {
    final groupedQuestions =
        _groupQuestionsBySubcategory(questionState.questions);

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: groupedQuestions.entries.map((entry) {
                  return _buildSubcategorySection(
                    gameState,
                    entry.key,
                    entry.value,
                  );
                }).toList(),
              ),
            ),
          ),
          _buildTeamCards(gameState),
        ],
      ),
    );
  }

  Map<String, List<Question>> _groupQuestionsBySubcategory(
      List<Question> questions) {
    final Map<String, List<Question>> grouped = {};
    for (final question in questions) {
      if (!grouped.containsKey(question.subCategoryId)) {
        grouped[question.subCategoryId] = [];
      }
      grouped[question.subCategoryId]!.add(question);
    }

    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => a.points.compareTo(b.points));
    }

    return grouped;
  }

  Widget _buildSubcategorySection(
    GameInProgress gameState,
    String subCategoryId,
    List<Question> questions,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: questions.map((question) {
          final isPlayed = gameState.playedQuestions.contains(question.id);
          final index = questions.indexOf(question);
          final isMiddle = index == 1;

          return Expanded(
            child: Column(
              children: [
                if (index == 0) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForSubcategory(subCategoryId),
                      size: 48,
                      color: _getColorForSubcategory(subCategoryId),
                    ),
                  ),
                ],
                if (isMiddle) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryRed,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getNameForSubcategory(subCategoryId),
                      style: AppTextStyles.mediumBold.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                if (index == 2) ...[
                  SizedBox(height: 62),
                ],
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: isPlayed
                        ? null
                        : () {
                            context.router.push(
                              QuestionDisplayRoute(
                                gameId: widget.gameId,
                                questionId: question.id,
                              ),
                            );
                          },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: isPlayed
                            ? const Color(0xFFD3D3D3)
                            : const Color(0xFFD0D0E0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          isPlayed ? '' : '${question.points}',
                          style: AppTextStyles.extraLargeTvBold.copyWith(
                            color: AppColors.primaryRed,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTeamCards(GameInProgress gameState) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      color: AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildTeamCard(
              gameState.leftTeam.name,
              gameState.leftTeam.score,
              true,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildTeamCard(
              gameState.rightTeam.name,
              gameState.rightTeam.score,
              false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(String teamName, int score, bool isLeft) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD0D0D0), width: 1),
      ),
      child: Column(
        children: [
          Text(
            teamName,
            style: AppTextStyles.largeTvBold.copyWith(
              color: const Color(0xFF333333),
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              '$score',
              style: AppTextStyles.extraLargeTvBold.copyWith(
                color: AppColors.primaryRed,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'وسائل المساعدة',
            style: AppTextStyles.mediumBold.copyWith(
              color: const Color(0xFF666666),
              fontSize: 14,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLifelineButton(Icons.people),
              SizedBox(width: AppSpacing.sm),
              _buildLifelineButton(Icons.phone),
              SizedBox(width: AppSpacing.sm),
              _buildLifelineButton(Icons.power_settings_new),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifelineButton(IconData icon) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFB0B0B0),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 24,
        color: AppColors.white,
      ),
    );
  }

  IconData _getIconForSubcategory(String subCategoryId) {
    final iconMap = {
      'sub_ancient_history': Icons.account_balance,
      'sub_modern_history': Icons.article,
      'sub_islamic_history': Icons.mosque,
      'sub_biology': Icons.biotech,
      'sub_chemistry': Icons.science,
      'sub_physics': Icons.science_outlined,
    };
    return iconMap[subCategoryId] ?? Icons.category;
  }

  Color _getColorForSubcategory(String subCategoryId) {
    final colorMap = {
      'sub_ancient_history': Colors.amber,
      'sub_modern_history': Colors.grey,
      'sub_islamic_history': Colors.brown,
      'sub_biology': Colors.pink,
      'sub_chemistry': Colors.green,
      'sub_physics': Colors.purple,
    };
    return colorMap[subCategoryId] ?? AppColors.primaryRed;
  }

  String _getNameForSubcategory(String subCategoryId) {
    final nameMap = {
      'sub_ancient_history': 'التاريخ القديم',
      'sub_modern_history': 'التاريخ الحديث',
      'sub_islamic_history': 'التاريخ الإسلامي',
      'sub_biology': 'علم الأحياء',
      'sub_chemistry': 'الكيمياء',
      'sub_physics': 'الفيزياء',
    };
    return nameMap[subCategoryId] ?? '';
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إنهاء اللعبة', style: AppTextStyles.largeTvBold),
        content: Text(
          'هل تريد حقاً الخروج من اللعبة؟',
          style: AppTextStyles.mediumRegular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: AppTextStyles.mediumBold),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.router.popUntilRoot();
            },
            child: Text(
              'خروج',
              style: AppTextStyles.mediumBold
                  .copyWith(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}
