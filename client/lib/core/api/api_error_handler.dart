import 'package:dio/dio.dart';
import '../error/failures.dart';

/// Centralized handler for API (Dio) errors.
///
/// This utility class provides consistent error handling across all repositories,
/// converting [DioException] to appropriate [Failure] types.
class ApiErrorHandler {
  ApiErrorHandler._();

  /// Handles a [DioException] and returns the appropriate [Failure].
  ///
  /// Error mapping:
  /// - Connection errors → [NetworkFailure]
  /// - 401 Unauthorized → [AuthFailure]
  /// - 400/422 Validation → [ValidationFailure]
  /// - 409 Conflict → [ValidationFailure] (e.g., duplicate email)
  /// - Other errors → [ServerFailure]
  static Failure handleDioError(DioException e) {
    // Network connectivity issues
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Authentication error
    if (statusCode == 401) {
      final message = _extractMessage(data);
      return AuthFailure(
        message ?? 'Sesi telah berakhir, silakan login kembali',
      );
    }

    // Validation errors
    if (statusCode == 400 || statusCode == 422) {
      final message = _extractMessage(data);
      return ValidationFailure(message ?? 'Data tidak valid');
    }

    // Conflict (e.g., duplicate email)
    if (statusCode == 409) {
      final message = _extractMessage(data);
      return ValidationFailure(message ?? 'Data sudah ada');
    }

    // Not found
    if (statusCode == 404) {
      return const ServerFailure('Data tidak ditemukan', statusCode: 404);
    }

    // Generic server error
    return ServerFailure(
      _extractMessage(data) ?? 'Terjadi kesalahan',
      statusCode: statusCode,
    );
  }

  /// Extracts error message from response data.
  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      return data['message'] as String?;
    }
    return null;
  }
}
