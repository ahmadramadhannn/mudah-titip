part of 'auth_bloc.dart';

/// Authentication state.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state, checking for existing session.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Checking for existing session.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
final class AuthAuthenticated extends AuthState {
  final String name;

  const AuthAuthenticated(this.name);

  @override
  List<Object?> get props => [name];
}

/// User is not authenticated.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication failed.
final class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
