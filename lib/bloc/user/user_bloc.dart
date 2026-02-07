import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/app_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AppService _appService;

  UserBloc({AppService? appService})
      : _appService = appService ?? AppService(),
        super(const UserInitial()) {
    on<LoadUserEvent>(_onLoadUser);
    on<UpdateUserEvent>(_onUpdateUser);
    on<PurchaseGamesEvent>(_onPurchaseGames);
    on<DecrementTrialEvent>(_onDecrementTrial);
  }

  Future<void> _onLoadUser(LoadUserEvent event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      final user = await _appService.getUserProfile(event.userId);
      if (user != null) {
        emit(UserLoaded(userProfile: user));
      } else {
        emit(const UserError(message: 'User not found'));
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUser(
      UpdateUserEvent event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is! UserLoaded) return;

    try {
      await _appService.updateUserProfile(
        userId: event.userId,
        name: event.name,
        mobile: event.mobile,
      );

      final updatedUser = await _appService.getUserProfile(event.userId);
      if (updatedUser != null) {
        emit(UserLoaded(userProfile: updatedUser));
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onPurchaseGames(
      PurchaseGamesEvent event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is! UserLoaded) return;

    try {
      await _appService.purchaseTrials(
        userId: event.userId,
        trialsCount: event.trialsCount,
      );

      final updatedUser = await _appService.getUserProfile(event.userId);
      if (updatedUser != null) {
        emit(UserLoaded(userProfile: updatedUser));
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onDecrementTrial(
      DecrementTrialEvent event, Emitter<UserState> emit) async {
    final state = this.state;
    if (state is! UserLoaded) return;

    try {
      await _appService.decrementTrial(event.userId);

      final updatedUser = await _appService.getUserProfile(event.userId);
      if (updatedUser != null) {
        emit(UserLoaded(userProfile: updatedUser));
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }
}
