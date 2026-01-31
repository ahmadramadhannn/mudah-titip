import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_error_handler.dart';
import '../models/profile_request.dart';
import '../models/profile_response.dart';

/// Repository for profile operations.
class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  /// Get current user's profile.
  Future<ProfileResponse> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Update profile (name and/or phone).
  Future<ProfileResponse> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.profile,
        data: request.toJson(),
      );
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Update email (requires password verification).
  Future<ProfileResponse> updateEmail(UpdateEmailRequest request) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.profileEmail,
        data: request.toJson(),
      );
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }

  /// Change password (requires current password verification).
  Future<void> updatePassword(UpdatePasswordRequest request) async {
    try {
      await _apiClient.put(
        ApiEndpoints.profilePassword,
        data: request.toJson(),
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.handleDioError(e);
    }
  }
}
