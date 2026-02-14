import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/team.dart';
import '../../services/app_service.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final AppService _appService;
  final String userId;

  GameBloc({AppService? appService, this.userId = ''})
      : _appService = appService ?? AppService(),
        super(const GameInitial()) {
    on<CreateGameEvent>(_onCreateGame);
    on<LoadGameEvent>(_onLoadGame);
    on<UpdateScoreEvent>(_onUpdateScore);
    on<AnswerQuestionEvent>(_onAnswerQuestion);
    on<CompleteGameEvent>(_onCompleteGame);
    on<ResumeGameEvent>(_onResumeGame);
    on<ReplayGameEvent>(_onReplayGame);
    on<AwardPointsEvent>(_onAwardPoints);
  }

  Future<void> _onAwardPoints(
      AwardPointsEvent event, Emitter<GameState> emit) async {
    final state = this.state;
    if (state is! GameInProgress) return;

    try {
      final gameRecord = state.gameRecord;
      int newLeftScore = gameRecord.leftTeamScore;
      int newRightScore = gameRecord.rightTeamScore;
      String newTurn = gameRecord.currentTurn;

      // 1. Calculate new score and turn
      if (event.winner == 'left') {
        newLeftScore += event.points;
        newTurn = 'right';
      } else if (event.winner == 'right') {
        newRightScore += event.points;
        newTurn = 'left';
      } else {
        newTurn = gameRecord.currentTurn == 'left' ? 'right' : 'left';
      }

      // 2. Perform service updates
      await _appService.updateGameScore(
        gameId: event.gameId,
        leftTeamScore: newLeftScore,
        rightTeamScore: newRightScore,
        currentTurn: newTurn,
      );

      await _appService.addPlayedQuestion(
        gameId: event.gameId,
        questionId: event.questionId,
      );

      // 3. Update local state
      final updatedQuestions = [...state.playedQuestions, event.questionId];
      final updatedGameRecord = state.gameRecord.copyWith(
        leftTeamScore: newLeftScore,
        rightTeamScore: newRightScore,
        currentTurn: newTurn,
        playedQuestions: updatedQuestions,
      );

      print(
          '🏆 Atomic Award Success - L: $newLeftScore, R: $newRightScore, Turn: $newTurn');

      emit(GameInProgress(
        gameId: event.gameId,
        gameRecord: updatedGameRecord,
        leftTeam: state.leftTeam.copyWith(score: newLeftScore),
        rightTeam: state.rightTeam.copyWith(score: newRightScore),
        playedQuestions: updatedQuestions,
      ));
    } catch (e) {
      emit(GameError(message: e.toString()));
    }
  }

  Future<void> _onCreateGame(
      CreateGameEvent event, Emitter<GameState> emit) async {
    emit(const GameLoading());
    try {
      final gameId = await _appService.createGame(
        userId: userId,
        gameName: event.gameName,
        leftTeamName: event.leftTeamName,
        rightTeamName: event.rightTeamName,
        selectedSubcategories: event.selectedSubcategories,
      );

      final gameRecord = await _appService.getGame(gameId);
      if (gameRecord == null) throw Exception('Game not found');

      emit(GameInProgress(
        gameId: gameId,
        gameRecord: gameRecord,
        leftTeam: Team(
          id: 'left',
          name: event.leftTeamName,
          score: 0,
        ),
        rightTeam: Team(
          id: 'right',
          name: event.rightTeamName,
          score: 0,
        ),
        playedQuestions: [],
      ));
    } catch (e) {
      emit(GameError(message: e.toString()));
    }
  }

  Future<void> _onLoadGame(LoadGameEvent event, Emitter<GameState> emit) async {
    emit(const GameLoading());
    try {
      final gameRecord = await _appService.getGame(event.gameId);
      if (gameRecord == null) throw Exception('Game not found');

      final leftTeam = Team(
        id: 'left',
        name: gameRecord.leftTeamName,
        score: gameRecord.leftTeamScore,
      );

      final rightTeam = Team(
        id: 'right',
        name: gameRecord.rightTeamName,
        score: gameRecord.rightTeamScore,
      );

      if (gameRecord.status == 'completed') {
        emit(GameOver(
          gameId: event.gameId,
          gameRecord: gameRecord,
          winner: gameRecord.winner,
          leftTeamScore: gameRecord.leftTeamScore,
          rightTeamScore: gameRecord.rightTeamScore,
        ));
      } else {
        emit(GameInProgress(
          gameId: event.gameId,
          gameRecord: gameRecord,
          leftTeam: leftTeam,
          rightTeam: rightTeam,
          playedQuestions: gameRecord.playedQuestions,
        ));
      }
    } catch (e) {
      emit(GameError(message: e.toString()));
    }
  }

  Future<void> _onUpdateScore(
      UpdateScoreEvent event, Emitter<GameState> emit) async {
    final state = this.state;
    if (state is! GameInProgress) return;

    try {
      print(
          '📊 UpdateScoreEvent - Left: ${event.leftTeamScore}, Right: ${event.rightTeamScore}, Turn: ${event.currentTurn}');

      await _appService.updateGameScore(
        gameId: event.gameId,
        leftTeamScore: event.leftTeamScore,
        rightTeamScore: event.rightTeamScore,
        currentTurn: event.currentTurn,
      );

      final updatedGameRecord = state.gameRecord.copyWith(
        leftTeamScore: event.leftTeamScore,
        rightTeamScore: event.rightTeamScore,
        currentTurn: event.currentTurn,
      );

      print(
          '📊 Emitting GameInProgress - Left: ${updatedGameRecord.leftTeamName} (${event.leftTeamScore}), Right: ${updatedGameRecord.rightTeamName} (${event.rightTeamScore}), Turn: ${event.currentTurn}');

      emit(GameInProgress(
        gameId: event.gameId,
        gameRecord: updatedGameRecord,
        leftTeam: state.leftTeam.copyWith(score: event.leftTeamScore),
        rightTeam: state.rightTeam.copyWith(score: event.rightTeamScore),
        playedQuestions: state.playedQuestions,
      ));
    } catch (e) {
      emit(GameError(message: e.toString()));
    }
  }

  Future<void> _onAnswerQuestion(
      AnswerQuestionEvent event, Emitter<GameState> emit) async {
    final state = this.state;
    if (state is! GameInProgress) return;

    try {
      print(
          '❓ AnswerQuestionEvent - Current state: Left: ${state.gameRecord.leftTeamName} (${state.gameRecord.leftTeamScore}), Right: ${state.gameRecord.rightTeamName} (${state.gameRecord.rightTeamScore}), Turn: ${state.gameRecord.currentTurn}');

      await _appService.addPlayedQuestion(
          gameId: event.gameId, questionId: event.questionId);

      final updatedQuestions = [...state.playedQuestions, event.questionId];
      final updatedGameRecord = state.gameRecord.copyWith(
        playedQuestions: updatedQuestions,
      );

      print(
          '❓ Emitting GameInProgress - Left: ${updatedGameRecord.leftTeamName} (${updatedGameRecord.leftTeamScore}), Right: ${updatedGameRecord.rightTeamName} (${updatedGameRecord.rightTeamScore}), Turn: ${updatedGameRecord.currentTurn}');

      emit(GameInProgress(
        gameId: event.gameId,
        gameRecord: updatedGameRecord,
        leftTeam: state.leftTeam,
        rightTeam: state.rightTeam,
        playedQuestions: updatedQuestions,
      ));
    } catch (e) {
      emit(GameError(message: e.toString()));
    }
  }

  Future<void> _onCompleteGame(
      CompleteGameEvent event, Emitter<GameState> emit) async {
    final state = this.state;
    if (state is! GameInProgress) return;

    try {
      final left = state.leftTeam.score;
      final right = state.rightTeam.score;

      final computedWinner =
          left == right ? 'draw' : (left > right ? 'left' : 'right');

      await _appService.completeGame(
        gameId: event.gameId,
        winner: computedWinner,
      );

      final gameRecord = await _appService.getGame(event.gameId);
      if (gameRecord == null) throw Exception('Game not found');

      emit(GameOver(
        gameId: event.gameId,
        gameRecord: gameRecord,
        winner: computedWinner,
        leftTeamScore: left,
        rightTeamScore: right,
      ));
    } catch (e) {
      emit(GameError(message: e.toString()));
    }
  }

  Future<void> _onResumeGame(
      ResumeGameEvent event, Emitter<GameState> emit) async {
    await _onLoadGame(LoadGameEvent(gameId: event.gameId), emit);
  }

  Future<void> _onReplayGame(
      ReplayGameEvent event, Emitter<GameState> emit) async {
    emit(const GameLoading());
    try {
      await _appService.replayGame(event.gameId);

      final updatedGame = await _appService.getGame(event.gameId);
      if (updatedGame == null) throw Exception('Game not found');

      emit(GameInProgress(
        gameId: event.gameId,
        gameRecord: updatedGame,
        leftTeam: Team(
          id: 'left',
          name: updatedGame.leftTeamName,
          score: 0,
        ),
        rightTeam: Team(
          id: 'right',
          name: updatedGame.rightTeamName,
          score: 0,
        ),
        playedQuestions: [],
      ));
    } catch (e) {
      emit(GameError(message: e.toString()));
    }
  }
}
