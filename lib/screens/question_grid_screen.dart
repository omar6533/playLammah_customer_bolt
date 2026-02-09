import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trivia_game/bloc/game/game_event.dart';
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
import '../models/sub_category.dart';
import '../utils/responsive_helper.dart';
import '../utils/orientation_manager.dart';
import '../services/app_service.dart';

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
  Map<String, SubCategory> _subcategories = {};
  bool _isCompletingGame = false;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<QuestionBloc>()
            .add(LoadQuestionsEvent(gameId: widget.gameId));
        _checkGameCompletion();
      }
    });
  }

  void _checkGameCompletion() {
    if (_isCompletingGame) return;

    final gameBloc = context.read<GameBloc>();
    final questionBloc = context.read<QuestionBloc>();

    final gameState = gameBloc.state;
    final questionState = questionBloc.state;

    if (gameState is GameInProgress && questionState is QuestionLoaded) {
      final totalQuestions = questionState.questions.length;
      final playedQuestions = gameState.playedQuestions.length;

      debugPrint(
          '🎯 Checking game completion: $playedQuestions / $totalQuestions questions played');

      if (playedQuestions >= totalQuestions) {
        debugPrint('🏁 All questions answered! Completing game...');
        _isCompletingGame = true;

        final leftScore = gameState.leftTeam.score;
        final rightScore = gameState.rightTeam.score;

        String winner;
        if (leftScore > rightScore) {
          winner = gameState.leftTeam.name;
        } else if (rightScore > leftScore) {
          winner = gameState.rightTeam.name;
        } else {
          winner = 'tie';
        }

        gameBloc.add(
          CompleteGameEvent(
            gameId: widget.gameId,
            winner: winner,
          ),
        );
      }
    }
  }

  Future<void> _loadSubcategories() async {
    try {
      final appService = AppService();
      final categories = await appService.getMainCategories();
      for (final category in categories) {
        final subcategories =
            await appService.getSubCategoriesForMainCategory(category.id);
        for (final sub in subcategories) {
          _subcategories[sub.id] = sub;
        }
      }
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameScreenWrapper(
      child: BlocListener<GameBloc, GameState>(
        listener: (context, state) {
          if (state is GameOver) {
            context.router.push(GameOverRoute(gameId: widget.gameId));
          }
        },
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
                    // Check if game is complete whenever the UI rebuilds
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _checkGameCompletion();
                      }
                    });

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
      title: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameInProgress) {
            final gameRecord = state.gameRecord;
            final currentTeamName = gameRecord.currentTurn == 'left'
                ? gameRecord.leftTeamName
                : gameRecord.rightTeamName;
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: gameRecord.currentTurn == 'left'
                    ? AppColors.primaryRed.withOpacity(0.3)
                    : AppColors.primaryYellow.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: Text(
                'دور فريق : $currentTeamName',
                style: AppTextStyles.largeTvBold,
              ),
            );
          }
          return Text('لوحة الأسئلة', style: AppTextStyles.largeTvBold);
        },
      ),
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
    final subcategories = groupedQuestions.keys.toList();

    // Group subcategories into pairs (2 per column)
    final List<List<String>> columnPairs = [];
    for (int i = 0; i < subcategories.length; i += 2) {
      if (i + 1 < subcategories.length) {
        columnPairs.add([subcategories[i], subcategories[i + 1]]);
      } else {
        columnPairs.add([subcategories[i]]);
      }
    }

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.all(AppSpacing.md),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: columnPairs.map((pair) {
                      return Column(
                        children: pair.map((subCategoryId) {
                          final questions = groupedQuestions[subCategoryId]!;
                          return Padding(
                            padding: EdgeInsets.only(bottom: AppSpacing.lg),
                            child: _buildCategoryRow(
                                gameState, subCategoryId, questions),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          _buildTeamCards(gameState),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    GameInProgress gameState,
    String subCategoryId,
    List<Question> questions,
  ) {
    // Get questions by point value
    final q200Left = questions.firstWhere((q) => q.points == 200,
        orElse: () => questions[0]);
    final q400Left = questions.firstWhere((q) => q.points == 400,
        orElse: () => questions[1]);
    final q600Left = questions.firstWhere((q) => q.points == 600,
        orElse: () => questions[2]);
    final q200Right = questions.firstWhere((q) => q.points == 800,
        orElse: () => questions[0]);
    final q400Right = questions.firstWhere((q) => q.points == 1000,
        orElse: () => questions[1]);
    final q600Right = questions.length > 5 ? questions[5] : questions[2];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          // Row 1: 200 | Icon | 800
          Row(
            children: [
              _buildQuestionCell(gameState, q200Left),
              Container(
                width: 80,
                height: 64,
                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getIconForSubcategory(subCategoryId),
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              _buildQuestionCell(gameState, q200Right),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          // Row 2: 400 | Category Name | 1000
          Row(
            children: [
              _buildQuestionCell(gameState, q400Left),
              Container(
                width: 80,
                height: 48,
                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    _getNameForSubcategory(subCategoryId),
                    style: AppTextStyles.smallRegular.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              _buildQuestionCell(gameState, q400Right),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          // Row 3: 600 | Empty | 600
          Row(
            children: [
              _buildQuestionCell(gameState, q600Left),
              SizedBox(
                width: 80,
                height: 64,
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
              ),
              _buildQuestionCell(gameState, q600Right),
            ],
          ),
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

  Widget _buildQuestionCell(GameInProgress gameState, Question question) {
    final isPlayed = gameState.playedQuestions.contains(question.id);

    return Container(
      width: 80,
      height: 64,
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
          decoration: BoxDecoration(
            color: isPlayed ? const Color(0xFFD3D3D3) : const Color(0xFFD0D0E0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              '${question.points}',
              style: AppTextStyles.largeTvBold.copyWith(
                color: isPlayed ? Colors.grey.shade500 : AppColors.primaryRed,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCards(GameInProgress gameState) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      color: const Color(0xFFE8E8E8),
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
    final gameBloc = context.read<GameBloc>();
    final gameState = gameBloc.state;
    if (gameState is! GameInProgress) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            teamName,
            style: AppTextStyles.mediumBold.copyWith(
              color: const Color(0xFF333333),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => _decrementScore(isLeft, gameState),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.remove, color: AppColors.white, size: 20),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Text(
                '$score',
                style: AppTextStyles.extraLargeTvBold.copyWith(
                  color: AppColors.primaryRed,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              InkWell(
                onTap: () => _incrementScore(isLeft, gameState),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: AppColors.white, size: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'وسائل المساعدة',
            style: AppTextStyles.smallRegular.copyWith(
              color: const Color(0xFF999999),
              fontSize: 12,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLifelineButton(
                Icons.people_outline,
                'استشارة الجمهور',
                () => _showLifelineDialog(
                    'استشارة الجمهور', 'سيتم عرض رأي الجمهور للفريق'),
              ),
              SizedBox(width: AppSpacing.xs),
              _buildLifelineButton(
                Icons.phone_outlined,
                'الاتصال بصديق',
                () => _showLifelineDialog(
                    'الاتصال بصديق', 'سيتم السماح للفريق بالاتصال بصديق'),
              ),
              SizedBox(width: AppSpacing.xs),
              _buildLifelineButton(
                Icons.back_hand_outlined,
                'تجميد الوقت',
                () => _showLifelineDialog(
                    'تجميد الوقت', 'سيتم إيقاف العد التنازلي مؤقتاً'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLifelineButton(
      IconData icon, String tooltip, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFCCCCCC),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  void _incrementScore(bool isLeft, GameInProgress gameState) {
    final gameBloc = context.read<GameBloc>();
    int newLeftScore = gameState.leftTeam.score;
    int newRightScore = gameState.rightTeam.score;

    if (isLeft) {
      newLeftScore += 100;
    } else {
      newRightScore += 100;
    }

    gameBloc.add(
      UpdateScoreEvent(
        gameId: widget.gameId,
        leftTeamScore: newLeftScore,
        rightTeamScore: newRightScore,
        currentTurn: gameState.gameRecord.currentTurn,
      ),
    );
  }

  void _decrementScore(bool isLeft, GameInProgress gameState) {
    final gameBloc = context.read<GameBloc>();
    int newLeftScore = gameState.leftTeam.score;
    int newRightScore = gameState.rightTeam.score;

    if (isLeft) {
      newLeftScore = (newLeftScore - 100).clamp(0, 999999);
    } else {
      newRightScore = (newRightScore - 100).clamp(0, 999999);
    }

    gameBloc.add(
      UpdateScoreEvent(
        gameId: widget.gameId,
        leftTeamScore: newLeftScore,
        rightTeamScore: newRightScore,
        currentTurn: gameState.gameRecord.currentTurn,
      ),
    );
  }

  void _showLifelineDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: AppTextStyles.mediumBold.copyWith(
            color: AppColors.primaryRed,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          style: AppTextStyles.mediumRegular.copyWith(
            color: const Color(0xFF333333),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'حسناً',
              style: AppTextStyles.mediumBold.copyWith(
                color: AppColors.primaryRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIconForSubcategory(String subCategoryId) {
    return _subcategories[subCategoryId]?.icon ?? '📁';
  }

  String _getNameForSubcategory(String subCategoryId) {
    return _subcategories[subCategoryId]?.nameAr ?? '';
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
