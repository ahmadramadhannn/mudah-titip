import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';

/// Repository for authentication operations.
class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';
  static const _authDataKey = 'auth_data';

  AuthRepository(this._apiClient, this._prefs);

  /// Login with email and password.
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      _apiClient.setAuthToken(authResponse.token);

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Register a new user.
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      _apiClient.setAuthToken(authResponse.token);

      return authResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Check if user is logged in and restore session.
  /// Returns AuthResponse if session is valid, null otherwise.
  Future<AuthResponse?> tryRestoreSession() async {
    final token = _prefs.getString(_tokenKey);
    final authDataJson = _prefs.getString(_authDataKey);

    if (token == null || authDataJson == null) {
      return null;
    }

    try {
      final authData = AuthResponse.fromJson(
        jsonDecode(authDataJson) as Map<String, dynamic>,
      );
      _apiClient.setAuthToken(token);
      return authData;
    } catch (e) {
      await logout();
      return null;
    }
  }

  /// Log out the current user.
  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_authDataKey);
    _apiClient.clearAuthToken();
  }

  /// Get the current cached auth response.
  AuthResponse? get currentAuthData {
    final authDataJson = _prefs.getString(_authDataKey);
    if (authDataJson == null) return null;
    try {
      return AuthResponse.fromJson(
        jsonDecode(authDataJson) as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _prefs.setString(_tokenKey, authResponse.token);
    await _prefs.setString(_authDataKey, jsonEncode(authResponse.toJson()));
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401) {
      return const AuthFailure('Email atau password salah');
    }

    if (statusCode == 400 || statusCode == 422) {
      final message = data is Map ? data['message'] as String? : null;
      return ValidationFailure(message ?? 'Data tidak valid');
    }

    if (statusCode == 409) {
      return const ValidationFailure('Email sudah terdaftar');
    }

    return ServerFailure(
      data is Map
          ? data['message'] as String? ?? 'Terjadi kesalahan'
          : 'Terjadi kesalahan',
      statusCode: statusCode,
    );
  }
}
