import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/app_service.dart';
import 'question_event.dart';
import 'question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  final AppService _appService;

  QuestionBloc({AppService? appService})
      : _appService = appService ?? AppService(),
        super(const QuestionInitial()) {
    on<LoadQuestionsForGameEvent>(_onLoadQuestionsForGame);
    on<LoadQuestionByIdEvent>(_onLoadQuestionById);
    on<MarkQuestionAnsweredEvent>(_onMarkAnswered);
    on<ResetQuestionsEvent>(_onResetQuestions);
  }

  Future<void> _onLoadQuestionsForGame(
      LoadQuestionsForGameEvent event, Emitter<QuestionState> emit) async {
    emit(const QuestionLoading());
    try {
      final allQuestions = await _appService.getQuestionsForSubCategories(
        event.selectedSubcategoryIds,
      );

      emit(QuestionLoaded(
        questions: allQuestions,
        currentQuestion: allQuestions.isNotEmpty ? allQuestions.first : null,
        answeredQuestionIds: [],
      ));
    } catch (e) {
      emit(QuestionError(message: e.toString()));
    }
  }

  Future<void> _onLoadQuestionById(
      LoadQuestionByIdEvent event, Emitter<QuestionState> emit) async {
    final state = this.state;
    if (state is! QuestionLoaded) return;

    try {
      final question = await _appService.getQuestionById(event.questionId);

      emit(QuestionLoaded(
        questions: state.questions,
        currentQuestion: question,
        answeredQuestionIds: state.answeredQuestionIds,
      ));
    } catch (e) {
      emit(QuestionError(message: e.toString()));
    }
  }

  Future<void> _onMarkAnswered(
      MarkQuestionAnsweredEvent event, Emitter<QuestionState> emit) async {
    final state = this.state;
    if (state is! QuestionLoaded) return;

    final answeredIds = [...state.answeredQuestionIds, event.questionId];

    emit(QuestionLoaded(
      questions: state.questions,
      currentQuestion: state.currentQuestion,
      answeredQuestionIds: answeredIds,
    ));
  }

  Future<void> _onResetQuestions(
      ResetQuestionsEvent event, Emitter<QuestionState> emit) async {
    emit(const QuestionInitial());
  }
}
