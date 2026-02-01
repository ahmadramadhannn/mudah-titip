import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_endpoints.dart';

/// Dio API client with interceptors for auth tokens, locale, and error handling.
class ApiClient {
  late final Dio _dio;
  String? _authToken;
  String _locale = 'id'; // Default to Indonesian

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_localeInterceptor());
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());

    // Initialize locale from platform
    _initializeLocale();
  }

  Dio get dio => _dio;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  /// Set the locale for API requests
  void setLocale(String locale) {
    _locale = locale;
  }

  /// Get current locale
  String get locale => _locale;

  /// Initialize locale from platform settings
  void _initializeLocale() {
    try {
      final platformLocale = PlatformDispatcher.instance.locale;
      // Use just the language code (en, id, etc.)
      _locale = platformLocale.languageCode;
    } catch (_) {
      _locale = 'id'; // Fallback to Indonesian
    }
  }

  InterceptorsWrapper _localeInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Accept-Language'] = _locale;
        handler.next(options);
      },
    );
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid - could trigger logout here
          clearAuthToken();
        }
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print('→ ${options.method} ${options.path}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('← ${response.statusCode} ${response.requestOptions.path}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('✕ ${error.response?.statusCode} ${error.message}');
        }
        handler.next(error);
      },
    );
  }

  // Convenience methods
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.put<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.patch<T>(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete<T>(path, queryParameters: queryParameters);
  }
}
