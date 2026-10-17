import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../routes/app_router.dart';
import '../theme/app_colors.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_event.dart';
import '../bloc/game/game_state.dart';
import '../bloc/question/question_bloc.dart';
import '../bloc/question/question_event.dart';
import '../bloc/question/question_state.dart';
import '../models/question.dart';
import '../models/sub_category.dart';
import '../utils/orientation_manager.dart';
import '../services/app_service.dart';
import '../widgets/game_navbar.dart';
import '../widgets/question_category_card.dart';
import '../widgets/game_team_panel.dart';
import '../utils/game_board.dart';

@RoutePage()
class QuestionGridScreen extends StatefulWidget {
  final String gameId;
  const QuestionGridScreen({super.key, required this.gameId});

  @override
  State<QuestionGridScreen> createState() => _QuestionGridScreenState();
}

class _QuestionGridScreenState extends State<QuestionGridScreen> {
  final Map<String, SubCategory> _subcategories = {};
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<QuestionBloc>()
            .add(LoadQuestionsEvent(gameId: widget.gameId));
      }
    });
  }

  Future<void> _loadSubcategories() async {
    try {
      final appService = AppService();
      final categories = await appService.getMainCategories();
      for (final category in categories) {
        final subs =
            await appService.getSubCategoriesForMainCategory(category.id);
        for (final sub in subs) {
          _subcategories[sub.id] = sub;
        }
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading subcategories: $e');
    }
  }

  void _incrementScore(bool isLeft, GameInProgress state) {
    context.read<GameBloc>().add(UpdateScoreEvent(
          gameId: widget.gameId,
          leftTeamScore:
              isLeft ? state.leftTeam.score + 100 : state.leftTeam.score,
          rightTeamScore:
              isLeft ? state.rightTeam.score : state.rightTeam.score + 100,
          currentTurn: state.gameRecord.currentTurn,
        ));
  }

  void _decrementScore(bool isLeft, GameInProgress state) {
    context.read<GameBloc>().add(UpdateScoreEvent(
          gameId: widget.gameId,
          leftTeamScore: isLeft
              ? (state.leftTeam.score - 100).clamp(0, 999999)
              : state.leftTeam.score,
          rightTeamScore: isLeft
              ? state.rightTeam.score
              : (state.rightTeam.score - 100).clamp(0, 999999),
          currentTurn: state.gameRecord.currentTurn,
        ));
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إنهاء اللعبة',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.primaryRed, fontWeight: FontWeight.w800)),
        content: const Text('هل تريد حقاً الخروج من اللعبة؟',
            textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.router.popUntilRoot();
            },
            child: const Text('خروج',
                style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  void _showWinnerDialog(GameInProgress state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('إظهار الفائز',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.primaryRed, fontWeight: FontWeight.w800)),
        content: const Text('هل تريد إنهاء اللعبة وإظهار الفائز؟',
            textAlign: TextAlign.center),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final winner = state.leftTeam.score > state.rightTeam.score
                  ? state.leftTeam.name
                  : state.rightTeam.score > state.leftTeam.score
                      ? state.rightTeam.name
                      : 'tie';
              context.read<GameBloc>().add(
                  CompleteGameEvent(gameId: widget.gameId, winner: winner));
            },
            child: const Text('إنهاء',
                style: TextStyle(color: AppColors.primaryRed)),
          ),
        ],
      ),
    );
  }

  static List<Question> _mockQuestionsForPlaceholder(String catId) {
    const pts = [200, 200, 400, 400, 600, 600];
    return List.generate(
        6,
        (i) => Question(
              id: '${catId}_q$i',
              subCategoryId: catId,
              questionText: 'Question ${pts[i]}',
              questionTextAr: 'سؤال ${pts[i]}',
              answer: 'Answer',
              answerAr: 'الجواب',
              points: pts[i],
              isActive: true,
              order: i,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return GameScreenWrapper(
      child: BlocListener<GameBloc, GameState>(
        listenWhen: (prev, curr) =>
            (curr is GameOver && prev is! GameOver) ||
            (curr is GameError && prev is! GameError),
        listener: (context, state) {
          if (state is GameOver) {
            context.router.replace(const GameOverRoute());
          } else if (state is GameError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.primaryRed),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocBuilder<GameBloc, GameState>(
            builder: (context, gameState) {
              if (gameState is! GameInProgress) {
                return const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primaryRed));
              }
              return BlocBuilder<QuestionBloc, QuestionState>(
                builder: (context, questionState) {
                  if (questionState is QuestionLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryRed));
                  }
                  if (questionState is QuestionError) {
                    return Center(
                        child: Text(questionState.message,
                            style:
                                const TextStyle(color: AppColors.primaryRed)));
                  }
                  if (questionState is QuestionLoaded) {
                    return _buildLayout(gameState, questionState);
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

  Widget _buildLayout(GameInProgress gameState, QuestionLoaded questionState) {
    final isRightTurn = gameState.gameRecord.currentTurn == 'right';
    final currentTeamName =
        isRightTurn ? gameState.rightTeam.name : gameState.leftTeam.name;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          GameNavbar(
            currentTeamName: currentTeamName,
            onExit: _showExitDialog,
            onEndGame: () => _showWinnerDialog(gameState),
            onHome: () => context.router.popUntilRoot(),
          ),
          Expanded(
            child: Row(
              children: [
                // RTL: first child = physical RIGHT → team panel
                GameTeamPanel(
                  rightTeamName: gameState.rightTeam.name,
                  rightTeamScore: gameState.rightTeam.score,
                  isRightActive: gameState.gameRecord.currentTurn == 'right',
                  leftTeamName: gameState.leftTeam.name,
                  leftTeamScore: gameState.leftTeam.score,
                  isLeftActive: gameState.gameRecord.currentTurn == 'left',
                  onIncrementRight: () => _incrementScore(false, gameState),
                  onDecrementRight: () => _decrementScore(false, gameState),
                  onIncrementLeft: () => _incrementScore(true, gameState),
                  onDecrementLeft: () => _decrementScore(true, gameState),
                ),
                // Second child = physical LEFT → category grid
                Expanded(
                  flex: 3,
                  child: _buildCategoryGrid(gameState, questionState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(
      GameInProgress gameState, QuestionLoaded questionState) {
    final board = buildGameBoard(questionState.questions, widget.gameId);

    int pad = 0;
    while (board.length < 6) {
      final id = '__placeholder_${pad++}';
      final mock = _mockQuestionsForPlaceholder(id);
      board.add(BoardCategory(id, [mock[0], mock[2], mock[4]], [mock[1], mock[3], mock[5]]));
      _subcategories.putIfAbsent(
        id,
        () => SubCategory(
          id: id,
          mainCategoryId: 'mock',
          name: 'Misc',
          nameAr: 'أسئلة متنوعة',
          icon: '🎯',
          isActive: true,
          order: 99,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(child: _buildGridRow(gameState, board.take(3).toList())),
          Expanded(child: _buildGridRow(gameState, board.skip(3).take(3).toList())),
        ],
      ),
    );
  }

  Widget _buildGridRow(GameInProgress gameState, List<BoardCategory> categories) {
    return Row(
      children: categories.map((category) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: QuestionCategoryCard(
              subCategoryId: category.subCategoryId,
              leftQuestions: category.left,
              rightQuestions: category.right,
              playedQuestions: gameState.playedQuestions,
              subcategory: _subcategories[category.subCategoryId],
              gameId: widget.gameId,
              isNavigating: _isNavigating,
              onNavigatingChanged: (val) {
                if (mounted) setState(() => _isNavigating = val);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}
