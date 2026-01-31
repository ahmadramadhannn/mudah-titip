import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_role.dart';

/// Response model matching backend ProfileResponse.
class ProfileResponse extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileResponse({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: UserRole.fromString(json['role'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create a copy with updated fields.
  ProfileResponse copyWith({
    String? name,
    String? email,
    String? phone,
    bool clearPhone = false,
  }) {
    return ProfileResponse(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: clearPhone ? null : (phone ?? this.phone),
      role: role,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isConsignor => role == UserRole.consignor;
  bool get isShopOwner => role == UserRole.shopOwner;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    role,
    createdAt,
    updatedAt,
  ];
}
