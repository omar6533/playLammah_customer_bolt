import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserEvent extends UserEvent {
  final String userId;

  const LoadUserEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateUserEvent extends UserEvent {
  final String userId;
  final String name;
  final String mobile;

  const UpdateUserEvent({
    required this.userId,
    required this.name,
    required this.mobile,
  });

  @override
  List<Object?> get props => [userId, name, mobile];
}

class PurchaseGamesEvent extends UserEvent {
  final String userId;
  final int trialsCount;

  const PurchaseGamesEvent({
    required this.userId,
    required this.trialsCount,
  });

  @override
  List<Object?> get props => [userId, trialsCount];
}

class DecrementTrialEvent extends UserEvent {
  final String userId;

  const DecrementTrialEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
