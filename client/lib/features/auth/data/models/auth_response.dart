import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// Auth response from login/register endpoints.
class AuthResponse extends Equatable {
  final String token;
  final String tokenType;
  final int userId;
  final String name;
  final String email;
  final UserRole role;
  int? shopId;

  AuthResponse({
    required this.token,
    required this.tokenType,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.shopId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String,
      userId: json['userId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String),
      shopId: json['shopId'] as int?,
    );
  }

  @override
  List<Object?> get props => [
    token,
    tokenType,
    userId,
    name,
    email,
    role,
    shopId,
  ];
}
