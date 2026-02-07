import 'package:equatable/equatable.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class CreateGameEvent extends GameEvent {
  final String gameName;
  final String leftTeamName;
  final String rightTeamName;
  final List<String> selectedSubcategories;

  const CreateGameEvent({
    required this.gameName,
    required this.leftTeamName,
    required this.rightTeamName,
    required this.selectedSubcategories,
  });

  @override
  List<Object?> get props => [
        gameName,
        leftTeamName,
        rightTeamName,
        selectedSubcategories,
      ];
}

class LoadGameEvent extends GameEvent {
  final String gameId;

  const LoadGameEvent({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class UpdateScoreEvent extends GameEvent {
  final String gameId;
  final int leftTeamScore;
  final int rightTeamScore;
  final String currentTurn;

  const UpdateScoreEvent({
    required this.gameId,
    required this.leftTeamScore,
    required this.rightTeamScore,
    required this.currentTurn,
  });

  @override
  List<Object?> get props => [gameId, leftTeamScore, rightTeamScore, currentTurn];
}

class AnswerQuestionEvent extends GameEvent {
  final String gameId;
  final String questionId;

  const AnswerQuestionEvent({
    required this.gameId,
    required this.questionId,
  });

  @override
  List<Object?> get props => [gameId, questionId];
}

class CompleteGameEvent extends GameEvent {
  final String gameId;
  final String? winner;

  const CompleteGameEvent({
    required this.gameId,
    this.winner,
  });

  @override
  List<Object?> get props => [gameId, winner];
}

class ResumeGameEvent extends GameEvent {
  final String gameId;

  const ResumeGameEvent({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class ReplayGameEvent extends GameEvent {
  final String gameId;

  const ReplayGameEvent({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}
