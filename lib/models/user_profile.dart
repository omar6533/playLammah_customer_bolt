import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String name;
  final String mobile;
  final int trialsRemaining;
  final String createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.mobile,
    required this.trialsRemaining,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      trialsRemaining: json['trials_remaining'] as int,
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
      'created_at': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        mobile,
        trialsRemaining,
        createdAt,
      ];
}
