import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String mobile;

  const RegisterEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.mobile,
  });

  @override
  List<Object?> get props => [email, password, name, mobile];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class AuthStateChangedEvent extends AuthEvent {
  final bool isAuthenticated;

  const AuthStateChangedEvent({required this.isAuthenticated});

  @override
  List<Object?> get props => [isAuthenticated];
}
