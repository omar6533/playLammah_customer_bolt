import 'package:equatable/equatable.dart';
import '../../models/game_record.dart';
import '../../models/team.dart';

abstract class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {
  const GameInitial();
}

class GameLoading extends GameState {
  const GameLoading();
}

class GameInProgress extends GameState {
  final String gameId;
  final GameRecord gameRecord;
  final Team leftTeam;
  final Team rightTeam;
  final List<String> playedQuestions;

  const GameInProgress({
    required this.gameId,
    required this.gameRecord,
    required this.leftTeam,
    required this.rightTeam,
    required this.playedQuestions,
  });

  @override
  List<Object?> get props => [
        gameId,
        gameRecord,
        leftTeam,
        rightTeam,
        playedQuestions,
      ];
}

class GameOver extends GameState {
  final String gameId;
  final GameRecord gameRecord;
  final String? winner;
  final int leftTeamScore;
  final int rightTeamScore;

  const GameOver({
    required this.gameId,
    required this.gameRecord,
    this.winner,
    required this.leftTeamScore,
    required this.rightTeamScore,
  });

  @override
  List<Object?> get props => [
        gameId,
        gameRecord,
        winner,
        leftTeamScore,
        rightTeamScore,
      ];
}

class GameError extends GameState {
  final String message;

  const GameError({required this.message});

  @override
  List<Object?> get props => [message];
}
