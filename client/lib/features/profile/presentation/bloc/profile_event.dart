part of 'profile_bloc.dart';

/// Profile events.
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load profile data.
final class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

/// Update profile name and/or phone.
final class ProfileUpdateRequested extends ProfileEvent {
  final String? name;
  final String? phone;

  const ProfileUpdateRequested({this.name, this.phone});

  @override
  List<Object?> get props => [name, phone];
}

/// Update email.
final class ProfileEmailUpdateRequested extends ProfileEvent {
  final String newEmail;
  final String currentPassword;

  const ProfileEmailUpdateRequested({
    required this.newEmail,
    required this.currentPassword,
  });

  @override
  List<Object?> get props => [newEmail, currentPassword];
}

/// Update password.
final class ProfilePasswordUpdateRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ProfilePasswordUpdateRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
