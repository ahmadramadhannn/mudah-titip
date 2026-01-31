import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/profile_request.dart';
import '../../data/models/profile_response.dart';
import '../../data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// BLoC for managing profile state.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileEmailUpdateRequested>(_onEmailUpdateRequested);
    on<ProfilePasswordUpdateRequested>(_onPasswordUpdateRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final cachedProfile = _getCurrentProfile();
    emit(ProfileLoading(profile: cachedProfile));

    try {
      final profile = await _profileRepository.getProfile();
      emit(ProfileLoaded(profile));
    } on Failure catch (e) {
      emit(ProfileError(e.message, profile: cachedProfile));
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile != null) {
      emit(ProfileUpdating(currentProfile));
    }

    try {
      final request = UpdateProfileRequest(
        name: event.name,
        phone: event.phone,
      );
      final profile = await _profileRepository.updateProfile(request);
      emit(ProfileUpdateSuccess(profile, 'Profil berhasil diperbarui'));
    } on Failure catch (e) {
      emit(ProfileError(e.message, profile: currentProfile));
    }
  }

  Future<void> _onEmailUpdateRequested(
    ProfileEmailUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile != null) {
      emit(ProfileUpdating(currentProfile));
    }

    try {
      final request = UpdateEmailRequest(
        newEmail: event.newEmail,
        currentPassword: event.currentPassword,
      );
      final profile = await _profileRepository.updateEmail(request);
      emit(ProfileUpdateSuccess(profile, 'Email berhasil diperbarui'));
    } on Failure catch (e) {
      emit(ProfileError(e.message, profile: currentProfile));
    }
  }

  Future<void> _onPasswordUpdateRequested(
    ProfilePasswordUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentProfile = _getCurrentProfile();
    if (currentProfile != null) {
      emit(ProfileUpdating(currentProfile));
    }

    try {
      final request = UpdatePasswordRequest(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      await _profileRepository.updatePassword(request);
      emit(
        ProfileUpdateSuccess(currentProfile!, 'Password berhasil diperbarui'),
      );
    } on Failure catch (e) {
      emit(ProfileError(e.message, profile: currentProfile));
    }
  }

  ProfileResponse? _getCurrentProfile() {
    final currentState = state;
    if (currentState is ProfileLoaded) return currentState.profile;
    if (currentState is ProfileUpdating) return currentState.profile;
    if (currentState is ProfileUpdateSuccess) return currentState.profile;
    if (currentState is ProfileError) return currentState.profile;
    return null;
  }
}
