import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../models/auth_request.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

/// Repository for authentication operations.
class AuthRepository {
  final ApiClient _apiClient;
  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

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
  Future<User?> tryRestoreSession() async {
    final token = _prefs.getString(_tokenKey);
    final userData = _prefs.getString(_userKey);

    if (token == null || userData == null) {
      return null;
    }

    _apiClient.setAuthToken(token);

    try {
      // TODO: Call /api/auth/me endpoint if available to validate token
      // For now, just parse cached user data
      return User.fromJson(jsonDecode(userData) as Map<String, dynamic>);
    } catch (e) {
      await logout();
      return null;
    }
  }

  /// Log out the current user.
  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
    _apiClient.clearAuthToken();
  }

  /// Get the current cached user.
  User? get currentUser {
    final userData = _prefs.getString(_userKey);
    if (userData == null) return null;
    return User.fromJson(jsonDecode(userData) as Map<String, dynamic>);
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _prefs.setString(_tokenKey, authResponse.token);
    await _prefs.setString(_userKey, jsonEncode(authResponse.user.toJson()));
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
      data is Map ? data['message'] as String? ?? 'Terjadi kesalahan' : 'Terjadi kesalahan',
      statusCode: statusCode,
    );
  }
}
