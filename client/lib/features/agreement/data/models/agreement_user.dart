import 'package:equatable/equatable.dart';

/// Simplified user model for agreement's proposedBy field.
class AgreementUser extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? role;

  const AgreementUser({
    required this.id,
    required this.name,
    required this.email,
    this.role,
  });

  factory AgreementUser.fromJson(Map<String, dynamic> json) {
    return AgreementUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (role != null) 'role': role,
  };

  @override
  List<Object?> get props => [id, name, email, role];
}
