import '../config/env_config.dart';

/// API endpoint constants for the Mudah Titip backend.
class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL from environment configuration.
  static String get baseUrl => EnvConfig.baseUrl;

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Products
  static const String products = '/products';
  static const String myProducts = '/products/my';
  static String product(String id) => '/products/$id';
  static const String searchProducts = '/products/search';

  // Consignments
  static const String consignments = '/consignments';
  static const String myConsignments = '/consignments/my';
  static String consignment(String id) => '/consignments/$id';
  static String consignmentStatus(String id) => '/consignments/$id/status';
  static const String expiringSoon = '/consignments/expiring';

  // Sales
  static const String sales = '/sales';
  static const String mySales = '/sales/my';
  static const String salesSummary = '/sales/summary';

  // Agreements
  static const String proposeAgreement = '/agreements/propose';
  static String counterAgreement(String id) => '/agreements/$id/counter';
  static String acceptAgreement(String id) => '/agreements/$id/accept';
  static String rejectAgreement(String id) => '/agreements/$id/reject';
  static const String pendingAgreements = '/agreements/pending';
  static String settlement(String consignmentId) =>
      '/agreements/settlement/$consignmentId';

  // Profile
  static const String profile = '/profile';
  static const String profileEmail = '/profile/email';
  static const String profilePassword = '/profile/password';
}
