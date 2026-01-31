import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/auth_request.dart';
import '../../data/models/user_role.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Bloc for managing authentication state.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final authData = await _authRepository.tryRestoreSession();
    if (authData != null) {
      emit(
        AuthAuthenticated(
          userId: authData.userId,
          name: authData.name,
          email: authData.email,
          role: authData.role,
          shopId: authData.shopId,
        ),
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _authRepository.login(
        LoginRequest(email: event.email, password: event.password),
      );
      emit(
        AuthAuthenticated(
          userId: response.userId,
          name: response.name,
          email: response.email,
          role: response.role,
          shopId: response.shopId,
        ),
      );
    } on Failure catch (e) {
      emit(AuthFailure(e.message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _authRepository.register(
        RegisterRequest(
          name: event.name,
          email: event.email,
          password: event.password,
          phone: event.phone,
          role: event.role,
          shopName: event.shopName,
          shopAddress: event.shopAddress,
          shopPhone: event.shopPhone,
          shopDescription: event.shopDescription,
        ),
      );
      emit(
        AuthAuthenticated(
          userId: response.userId,
          name: response.name,
          email: response.email,
          role: response.role,
          shopId: response.shopId,
        ),
      );
    } on Failure catch (e) {
      emit(AuthFailure(e.message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
