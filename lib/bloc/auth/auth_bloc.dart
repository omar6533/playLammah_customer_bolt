import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/app_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AppService _appService;

  AuthBloc({AppService? appService})
      : _appService = appService ?? AppService(),
        super(const AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<CheckEmailVerifiedEvent>(_onCheckEmailVerified);
    on<LogoutEvent>(_onLogout);
    on<AuthStateChangedEvent>(_onAuthStateChanged);
  }

  AuthState _signedInState(String userId, {bool emailSent = false}) {
    if (_appService.isEmailVerified()) return Authenticated(userId: userId);
    return EmailVerificationRequired(
      email: _appService.getCurrentUserEmail() ?? '',
      emailSent: emailSent,
    );
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final userId = await _appService.restoreSession();
      emit(userId == null ? const Unauthenticated() : _signedInState(userId));
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final result = await _appService.loginUser(
        email: event.email,
        password: event.password,
      );

      if (result['success'] == true) {
        emit(_signedInState(result['userId']));
      } else {
        emit(const AuthError(message: 'تعذر تسجيل الدخول، حاول مرة أخرى'));
      }
    } catch (e) {
      emit(AuthError(message: authErrorMessage(e)));
    }
  }

  Future<void> _onRegister(
      RegisterEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final result = await _appService.registerUser(
        email: event.email,
        password: event.password,
        name: event.name,
        mobile: event.mobile,
      );

      if (result['success'] == true) {
        var sent = true;
        try {
          await _appService.sendEmailVerification();
        } catch (e) {
          // The verify screen offers "resend", so don't fail registration.
          print('⚠️ Verification email failed: $e');
          sent = false;
        }
        emit(_signedInState(result['userId'], emailSent: sent));
      } else {
        emit(const AuthError(message: 'تعذر إنشاء الحساب، حاول مرة أخرى'));
      }
    } catch (e) {
      emit(AuthError(message: authErrorMessage(e)));
    }
  }

  Future<void> _onCheckEmailVerified(
      CheckEmailVerifiedEvent event, Emitter<AuthState> emit) async {
    final current = state;
    if (current is! EmailVerificationRequired) return;
    try {
      if (await _appService.reloadEmailVerified()) {
        final userId = _appService.getCurrentUserId();
        if (userId != null) {
          emit(Authenticated(userId: userId));
          return;
        }
      }
    } catch (_) {
      // Network hiccup: treat as still unverified.
    }
    if (!event.silent) {
      emit(EmailVerificationRequired(
        email: current.email,
        emailSent: current.emailSent,
        failedChecks: current.failedChecks + 1,
      ));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await _appService.logoutUser();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(message: authErrorMessage(e)));
    }
  }

  Future<void> _onAuthStateChanged(
      AuthStateChangedEvent event, Emitter<AuthState> emit) async {
    final userId = event.isAuthenticated ? _appService.getCurrentUserId() : null;
    emit(userId == null ? const Unauthenticated() : _signedInState(userId));
  }
}

String authErrorMessage(Object e) {
  if (e is FirebaseAuthException) {
    switch (e.code) {
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-disabled':
        return 'تم إيقاف هذا الحساب';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مسجل مسبقاً، سجّل الدخول بدلاً من ذلك';
      case 'weak-password':
        return 'كلمة المرور ضعيفة، استخدم 6 أحرف على الأقل';
      case 'too-many-requests':
        return 'محاولات كثيرة، يرجى الانتظار قليلاً ثم المحاولة مرة أخرى';
      case 'network-request-failed':
        return 'تحقق من اتصالك بالإنترنت';
    }
  }
  return 'حدث خطأ غير متوقع، حاول مرة أخرى';
}
