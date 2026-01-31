part of 'profile_bloc.dart';

/// Profile state.
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial loading state.
final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading profile data.
final class ProfileLoading extends ProfileState {
  final ProfileResponse? profile;

  const ProfileLoading({this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Profile loaded successfully.
final class ProfileLoaded extends ProfileState {
  final ProfileResponse profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile update in progress.
final class ProfileUpdating extends ProfileState {
  final ProfileResponse profile;

  const ProfileUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Profile update successful.
final class ProfileUpdateSuccess extends ProfileState {
  final ProfileResponse profile;
  final String message;

  const ProfileUpdateSuccess(this.profile, this.message);

  @override
  List<Object?> get props => [profile, message];
}

/// Profile operation failed.
final class ProfileError extends ProfileState {
  final String message;
  final ProfileResponse? profile;

  const ProfileError(this.message, {this.profile});

  @override
  List<Object?> get props => [message, profile];
}
