import 'package:equatable/equatable.dart';
import '../../models/question.dart';

abstract class QuestionState extends Equatable {
  const QuestionState();

  @override
  List<Object?> get props => [];
}

class QuestionInitial extends QuestionState {
  const QuestionInitial();
}

class QuestionLoading extends QuestionState {
  const QuestionLoading();
}

class QuestionLoaded extends QuestionState {
  final List<Question> questions;
  final Question? currentQuestion;
  final List<String> answeredQuestionIds;

  const QuestionLoaded({
    required this.questions,
    this.currentQuestion,
    required this.answeredQuestionIds,
  });

  @override
  List<Object?> get props => [questions, currentQuestion, answeredQuestionIds];
}

class QuestionError extends QuestionState {
  final String message;

  const QuestionError({required this.message});

  @override
  List<Object?> get props => [message];
}
