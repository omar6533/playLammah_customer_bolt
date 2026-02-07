import 'package:equatable/equatable.dart';

abstract class QuestionEvent extends Equatable {
  const QuestionEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuestionsEvent extends QuestionEvent {
  final String gameId;

  const LoadQuestionsEvent({
    required this.gameId,
  });

  @override
  List<Object?> get props => [gameId];
}

class LoadQuestionsForGameEvent extends QuestionEvent {
  final List<String> selectedSubcategoryIds;

  const LoadQuestionsForGameEvent({
    required this.selectedSubcategoryIds,
  });

  @override
  List<Object?> get props => [selectedSubcategoryIds];
}

class LoadQuestionByIdEvent extends QuestionEvent {
  final String questionId;

  const LoadQuestionByIdEvent({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}

class MarkQuestionAnsweredEvent extends QuestionEvent {
  final String questionId;

  const MarkQuestionAnsweredEvent({required this.questionId});

  @override
  List<Object?> get props => [questionId];
}

class ResetQuestionsEvent extends QuestionEvent {
  const ResetQuestionsEvent();
}
