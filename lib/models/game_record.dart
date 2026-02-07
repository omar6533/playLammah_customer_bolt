import 'package:equatable/equatable.dart';

class GameRecord extends Equatable {
  final String id;
  final String userId;
  final String gameName;
  final String leftTeamName;
  final String rightTeamName;
  final int leftTeamScore;
  final int rightTeamScore;
  final String currentTurn;
  final String status;
  final String? winner;
  final List<String> playedQuestions;
  final List<String> selectedSubcategories;
  final int playCount;
  final String createdAt;
  final String updatedAt;
  final String? completedAt;

  const GameRecord({
    required this.id,
    required this.userId,
    required this.gameName,
    required this.leftTeamName,
    required this.rightTeamName,
    required this.leftTeamScore,
    required this.rightTeamScore,
    required this.currentTurn,
    required this.status,
    this.winner,
    required this.playedQuestions,
    required this.selectedSubcategories,
    required this.playCount,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  GameRecord copyWith({
    String? id,
    String? userId,
    String? gameName,
    String? leftTeamName,
    String? rightTeamName,
    int? leftTeamScore,
    int? rightTeamScore,
    String? currentTurn,
    String? status,
    String? winner,
    List<String>? playedQuestions,
    List<String>? selectedSubcategories,
    int? playCount,
    String? createdAt,
    String? updatedAt,
    String? completedAt,
  }) {
    return GameRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameName: gameName ?? this.gameName,
      leftTeamName: leftTeamName ?? this.leftTeamName,
      rightTeamName: rightTeamName ?? this.rightTeamName,
      leftTeamScore: leftTeamScore ?? this.leftTeamScore,
      rightTeamScore: rightTeamScore ?? this.rightTeamScore,
      currentTurn: currentTurn ?? this.currentTurn,
      status: status ?? this.status,
      winner: winner ?? this.winner,
      playedQuestions: playedQuestions ?? this.playedQuestions,
      selectedSubcategories:
          selectedSubcategories ?? this.selectedSubcategories,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      gameName: json['game_name'] as String,
      leftTeamName: json['left_team_name'] as String,
      rightTeamName: json['right_team_name'] as String,
      leftTeamScore: json['left_team_score'] as int,
      rightTeamScore: json['right_team_score'] as int,
      currentTurn: json['current_turn'] as String,
      status: json['status'] as String,
      winner: json['winner'] as String?,
      playedQuestions: List<String>.from(json['played_questions'] as List),
      selectedSubcategories:
          List<String>.from(json['selected_subcategories'] as List),
      playCount: json['play_count'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      completedAt: json['completed_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'game_name': gameName,
      'left_team_name': leftTeamName,
      'right_team_name': rightTeamName,
      'left_team_score': leftTeamScore,
      'right_team_score': rightTeamScore,
      'current_turn': currentTurn,
      'status': status,
      'winner': winner,
      'played_questions': playedQuestions,
      'selected_subcategories': selectedSubcategories,
      'play_count': playCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'completed_at': completedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        gameName,
        leftTeamName,
        rightTeamName,
        leftTeamScore,
        rightTeamScore,
        currentTurn,
        status,
        winner,
        playedQuestions,
        selectedSubcategories,
        playCount,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
