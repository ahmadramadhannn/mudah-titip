/// Environment types for the application.
enum Environment {
  /// Local development environment
  dev,

  /// Staging/testing environment
  staging,

  /// Production environment
  prod,
}

/// Environment configuration for the application.
///
/// Provides environment-specific settings such as API base URL.
/// Set [current] before the app starts to configure the environment.
///
/// Example:
/// ```dart
/// void main() {
///   EnvConfig.current = Environment.prod;
///   runApp(MyApp());
/// }
/// ```
class EnvConfig {
  EnvConfig._();

  /// Current environment. Defaults to [Environment.dev].
  static Environment current = Environment.dev;

  /// API base URL for the current environment.
  static String get baseUrl => switch (current) {
    Environment.dev => 'http://localhost:8080/api',
    Environment.staging => 'https://staging.mudahtitip.com/api',
    Environment.prod => 'https://api.mudahtitip.com/api',
  };

  /// Whether the current environment is development.
  static bool get isDev => current == Environment.dev;

  /// Whether the current environment is production.
  static bool get isProd => current == Environment.prod;

  /// Whether debug features should be enabled.
  static bool get enableDebugFeatures => current != Environment.prod;
}
