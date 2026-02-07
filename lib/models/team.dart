import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final String id;
  final String name;
  final int score;

  const Team({
    required this.id,
    required this.name,
    required this.score,
  });

  Team copyWith({
    String? id,
    String? name,
    int? score,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
    );
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      score: json['score'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'score': score,
    };
  }

  @override
  List<Object?> get props => [id, name, score];
}
