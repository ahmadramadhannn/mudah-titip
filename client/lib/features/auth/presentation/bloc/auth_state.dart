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

/// User is authenticated with full user info.
final class AuthAuthenticated extends AuthState {
  final int userId;
  final String name;
  final String email;
  final UserRole role;
  final int? shopId;

  const AuthAuthenticated({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.shopId,
  });

  bool get isConsignor => role == UserRole.consignor;
  bool get isShopOwner => role == UserRole.shopOwner;

  @override
  List<Object?> get props => [userId, name, email, role, shopId];
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
