import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../bloc/question/question_bloc.dart';
import '../bloc/question/question_state.dart';
import '../bloc/game/game_bloc.dart';
import '../bloc/game/game_event.dart';
import '../bloc/game/game_state.dart';
import '../utils/orientation_manager.dart';
import '../models/question.dart';
import '../widgets/game_navbar.dart';
import '../widgets/game_team_panel.dart';
import '../widgets/question_answer_card.dart';
import '../widgets/team_answer_selector.dart';

const _kTimerSeconds = 30;

@RoutePage()
class QuestionDisplayScreen extends StatefulWidget {
  final String gameId;
  final String questionId;

  const QuestionDisplayScreen({
    super.key,
    required this.gameId,
    required this.questionId,
  });

  @override
  State<QuestionDisplayScreen> createState() => _QuestionDisplayScreenState();
}

class _QuestionDisplayScreenState extends State<QuestionDisplayScreen> {
  bool _showAnswer = false;
  bool _selectingTeam = false;
  bool _isSubmitting = false;

  // Countdown timer state
  int _secondsRemaining = _kTimerSeconds;
  bool _timerRunning = true;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _startTimer() {
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _countdown?.cancel();
          _timerRunning = false;
        }
      });
    });
  }

  void _toggleTimer() {
    setState(() {
      _timerRunning = !_timerRunning;
      if (_timerRunning) {
        _startTimer();
      } else {
        _countdown?.cancel();
      }
    });
  }

  void _resetTimer() {
    _countdown?.cancel();
    setState(() {
      _secondsRemaining = _kTimerSeconds;
      _timerRunning = true;
    });
    _startTimer();
  }

  String get _timerDisplay {
    final m = _secondsRemaining ~/ 60;
    final s = _secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Score controls ────────────────────────────────────────────────────────

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

  // ── Dialogs ───────────────────────────────────────────────────────────────

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

  // ── Point awarding ────────────────────────────────────────────────────────

  void _handleTeamSelection(String winner, int points) {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _awardPointsFlow(winner, points);
  }

  Future<void> _awardPointsFlow(String winner, int points) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryRed),
        ),
      ),
    );

    try {
      await _awardPoints(winner, points);
      if (!mounted) return;
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      if (context.read<GameBloc>().state is GameInProgress) {
        context.router.pop();
      }
    } catch (e) {
      debugPrint('❌ Error awarding points: $e');
      if (!mounted) return;
      Navigator.of(context).pop();
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _awardPoints(String winner, int points) async {
    final gameBloc = context.read<GameBloc>();
    final questionBloc = context.read<QuestionBloc>();
    if (gameBloc.state is! GameInProgress) return;

    gameBloc.add(AwardPointsEvent(
      gameId: widget.gameId,
      questionId: widget.questionId,
      winner: winner,
      points: points,
    ));

    try {
      await gameBloc.stream.firstWhere((state) {
        if (state is GameError) throw Exception(state.message);
        return state is GameInProgress &&
            state.playedQuestions.contains(widget.questionId);
      }).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('⚠️ Sync warning: $e');
    }

    final questionState = questionBloc.state;
    if (questionState is QuestionLoaded) {
      final updated = gameBloc.state;
      if (updated is GameInProgress &&
          updated.playedQuestions.length >= questionState.questions.length) {
        final lScore = updated.leftTeam.score;
        final rScore = updated.rightTeam.score;
        final gameWinner = lScore > rScore
            ? updated.leftTeam.name
            : rScore > lScore
                ? updated.rightTeam.name
                : 'tie';
        gameBloc
            .add(CompleteGameEvent(gameId: widget.gameId, winner: gameWinner));
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GameScreenWrapper(
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
                          style: const TextStyle(color: AppColors.primaryRed)));
                }
                if (questionState is! QuestionLoaded) {
                  return const SizedBox.shrink();
                }

                final question = questionState.questions.firstWhere(
                  (q) => q.id == widget.questionId,
                  orElse: () => questionState.questions.first,
                );
                final isRightTurn = gameState.gameRecord.currentTurn == 'right';
                final currentTeamName = isRightTurn
                    ? gameState.rightTeam.name
                    : gameState.leftTeam.name;

                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    children: [
                      GameNavbar(
                        currentTeamName: currentTeamName,
                        onExit: _showExitDialog,
                        onEndGame: () => _showWinnerDialog(gameState),
                        onHome: () => context.router.pop(),
                        homeLabel: 'الرجوع للوحة',
                      ),
                      Expanded(
                        child: _buildMainContent(context, gameState, question),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, GameInProgress gameState, Question question) {
    final isDesktop = MediaQuery.sizeOf(context).width > 768;

    final mainCard = _selectingTeam
        ? TeamAnswerSelector(
            rightTeamName: gameState.rightTeam.name,
            leftTeamName: gameState.leftTeam.name,
            isSubmitting: _isSubmitting,
            onSelectRight: () => _handleTeamSelection('right', question.points),
            onSelectLeft: () => _handleTeamSelection('left', question.points),
            onNobody: () => _handleTeamSelection('none', question.points),
          )
        : QuestionAnswerCard(
            timerDisplay: _timerDisplay,
            timerRunning: _timerRunning,
            points: question.points,
            questionTextAr: question.questionTextAr,
            mediaUrl: question.mediaUrl,
            showAnswer: _showAnswer,
            answerAr: question.answerAr,
            isSubmitting: _isSubmitting,
            onToggleTimer: _toggleTimer,
            onResetTimer: _resetTimer,
            onShowAnswer: () => setState(() {
              _showAnswer = true;
              _countdown?.cancel();
              _timerRunning = false;
            }),
            onSelectTeam: () => setState(() => _selectingTeam = true),
          );

    if (!isDesktop) return mainCard;

    return Row(
      children: [
        // RTL first = physical RIGHT → team panel (read-only or with score controls)
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
        // RTL second = physical LEFT → main card
        Expanded(child: mainCard),
      ],
    );
  }
}
