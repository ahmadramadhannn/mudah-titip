/// Base class for all failures in the app.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Server-side error.
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Network connection error.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet']);
}

/// Authentication error.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sesi telah berakhir, silakan login kembali']);
}

/// Validation error.
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  const ValidationFailure(super.message, {this.fieldErrors});
}

/// Cache error.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal membaca data lokal']);
}
