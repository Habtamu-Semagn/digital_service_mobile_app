import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthProfileUpdateRequested>(_onAuthProfileUpdateRequested);
    on<AuthPasswordChangeRequested>(_onAuthPasswordChangeRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final isAuthenticated = await authRepository.isAuthenticated();

    if (isAuthenticated) {
      final result = await authRepository.getCurrentUser();

      result.fold(
        (failure) => emit(AuthUnauthenticated()),
        (user) {
          if (user.role.toUpperCase() == 'CITIZEN') {
            emit(AuthAuthenticated(user: user));
          } else {
            // Log out non-citizen users if they are somehow authenticated on mobile
            authRepository.logout();
            emit(AuthUnauthenticated());
          }
        },
      );
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.login(event.phoneNumber, event.password);

    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) {
        if (user.role.toUpperCase() == 'CITIZEN') {
          emit(AuthAuthenticated(user: user));
        } else {
          // Block Admin/Officer login on mobile
          authRepository.logout();
          emit(const AuthError(
            message: 'Mobile access is restricted to Citizens only. Please use the web dashboard.',
          ));
        }
      },
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await authRepository.logout();

    result.fold(
      (failure) {
        // Even if server request fails, we are locally logged out
        emit(AuthUnauthenticated());
      },
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    emit(AuthLoading());

    final result = await authRepository.updateProfile(event.name, event.phoneNumber);

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
        if (currentState is AuthAuthenticated) {
          emit(currentState);
        }
      },
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onAuthPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    emit(AuthLoading());

    final result = await authRepository.changePassword(
      event.currentPassword,
      event.newPassword,
    );

    result.fold(
      (failure) {
        emit(AuthError(message: failure.message));
        if (currentState is AuthAuthenticated) {
          emit(currentState);
        }
      },
      (_) => emit(AuthPasswordChangeSuccess()),
    );
  }
}
