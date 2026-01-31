import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/failures.dart';
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
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
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401) {
      return const AuthFailure('Sesi telah berakhir, silakan login kembali');
    }

    if (statusCode == 400 || statusCode == 422) {
      final message = data is Map ? data['message'] as String? : null;
      return ValidationFailure(message ?? 'Data tidak valid');
    }

    return ServerFailure(
      data is Map
          ? data['message'] as String? ?? 'Terjadi kesalahan'
          : 'Terjadi kesalahan',
      statusCode: statusCode,
    );
  }
}
