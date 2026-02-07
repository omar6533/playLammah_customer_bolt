import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String subCategoryId;
  final String questionText;
  final String questionTextAr;
  final String answer;
  final String answerAr;
  final int points;
  final bool isActive;
  final int order;
  final String? mediaUrl;
  final String? mediaType;

  const Question({
    required this.id,
    required this.subCategoryId,
    required this.questionText,
    required this.questionTextAr,
    required this.answer,
    required this.answerAr,
    required this.points,
    required this.isActive,
    required this.order,
    this.mediaUrl,
    this.mediaType,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      subCategoryId: json['sub_category_id'] as String,
      questionText: json['question_text'] as String,
      questionTextAr: json['question_text_ar'] as String,
      answer: json['answer'] as String,
      answerAr: json['answer_ar'] as String,
      points: json['points'] as int,
      isActive: json['is_active'] as bool,
      order: json['order'] as int,
      mediaUrl: json['media_url'] as String?,
      mediaType: json['media_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sub_category_id': subCategoryId,
      'question_text': questionText,
      'question_text_ar': questionTextAr,
      'answer': answer,
      'answer_ar': answerAr,
      'points': points,
      'is_active': isActive,
      'order': order,
      'media_url': mediaUrl,
      'media_type': mediaType,
    };
  }

  @override
  List<Object?> get props => [
        id,
        subCategoryId,
        questionText,
        questionTextAr,
        answer,
        answerAr,
        points,
        isActive,
        order,
        mediaUrl,
        mediaType,
      ];
}
