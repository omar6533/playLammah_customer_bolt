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
    on<LogoutEvent>(_onLogout);
    on<AuthStateChangedEvent>(_onAuthStateChanged);
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final userId = _appService.getCurrentUserId();
      if (userId != null) {
        emit(Authenticated(userId: userId));
      } else {
        emit(const Unauthenticated());
      }
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
        emit(Authenticated(userId: result['userId']));
      } else {
        emit(const AuthError(message: 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
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
        emit(Authenticated(userId: result['userId']));
      } else {
        emit(const AuthError(message: 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await _appService.logoutUser();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onAuthStateChanged(
      AuthStateChangedEvent event, Emitter<AuthState> emit) async {
    if (event.isAuthenticated) {
      final userId = _appService.getCurrentUserId();
      if (userId != null) {
        emit(Authenticated(userId: userId));
      } else {
        emit(const Unauthenticated());
      }
    } else {
      emit(const Unauthenticated());
    }
  }
}
