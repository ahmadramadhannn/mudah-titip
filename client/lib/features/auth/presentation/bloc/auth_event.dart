part of 'auth_bloc.dart';

/// Authentication events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user has an active session on app start.
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User logged in successfully.
final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// User registration requested.
final class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final UserRole role;
  final String? shopName;
  final String? shopAddress;
  final String? shopPhone;
  final String? shopDescription;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    required this.role,
    this.shopName,
    this.shopAddress,
    this.shopPhone,
    this.shopDescription,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        password,
        phone,
        role,
        shopName,
        shopAddress,
        shopPhone,
        shopDescription,
      ];
}

/// User logout requested.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
