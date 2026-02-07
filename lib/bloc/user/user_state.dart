import 'package:equatable/equatable.dart';
import '../../models/user_profile.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final UserProfile userProfile;

  const UserLoaded({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object?> get props => [message];
}
