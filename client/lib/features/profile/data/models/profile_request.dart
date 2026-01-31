import 'package:equatable/equatable.dart';

/// Request model for updating profile name and phone.
class UpdateProfileRequest extends Equatable {
  final String? name;
  final String? phone;

  const UpdateProfileRequest({this.name, this.phone});

  Map<String, dynamic> toJson() {
    return {if (name != null) 'name': name, if (phone != null) 'phone': phone};
  }

  @override
  List<Object?> get props => [name, phone];
}

/// Request model for updating email with password verification.
class UpdateEmailRequest extends Equatable {
  final String newEmail;
  final String currentPassword;

  const UpdateEmailRequest({
    required this.newEmail,
    required this.currentPassword,
  });

  Map<String, dynamic> toJson() {
    return {'newEmail': newEmail, 'currentPassword': currentPassword};
  }

  @override
  List<Object?> get props => [newEmail, currentPassword];
}

/// Request model for changing password.
class UpdatePasswordRequest extends Equatable {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
