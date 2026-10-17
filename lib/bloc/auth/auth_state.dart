import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final String userId;

  const Authenticated({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Signed in to Firebase but the email address isn't verified yet, so the
/// user can't use the app until they click the link in the email.
class EmailVerificationRequired extends AuthState {
  final String email;

  /// True right after registration, when the verification email was just sent.
  final bool emailSent;

  /// Incremented on every failed "I verified" check so the UI can react to
  /// repeated results.
  final int failedChecks;

  const EmailVerificationRequired({required this.email, this.emailSent = false, this.failedChecks = 0});

  @override
  List<Object?> get props => [email, emailSent, failedChecks];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
