import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String name;
  final String mobile;
  final int trialsRemaining;
  final int availableGames;
  final String createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.mobile,
    required this.trialsRemaining,
    this.availableGames = 0,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      trialsRemaining: json['trials_remaining'] as int,
      availableGames: json['available_games'] as int? ?? 0,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'mobile': mobile,
      'trials_remaining': trialsRemaining,
      'available_games': availableGames,
      'created_at': createdAt,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? mobile,
    int? trialsRemaining,
    int? availableGames,
    String? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      trialsRemaining: trialsRemaining ?? this.trialsRemaining,
      availableGames: availableGames ?? this.availableGames,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        mobile,
        trialsRemaining,
        availableGames,
        createdAt,
      ];
}
