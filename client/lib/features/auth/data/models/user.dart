import 'package:equatable/equatable.dart';
import 'user_role.dart';

/// User model matching backend User entity.
class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isConsignor => role == UserRole.consignor;
  bool get isShopOwner => role == UserRole.shopOwner;

  @override
  List<Object?> get props => [id, name, email, phone, role, createdAt, updatedAt];
}
