/// API endpoint constants for the Mudah Titip backend.
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - adjust for different environments
  static const String baseUrl = 'http://localhost:8080/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Products
  static const String products = '/products';
  static const String myProducts = '/products/my';
  static String product(int id) => '/products/$id';
  static const String searchProducts = '/products/search';

  // Consignments
  static const String consignments = '/consignments';
  static const String myConsignments = '/consignments/my';
  static String consignment(int id) => '/consignments/$id';
  static String consignmentStatus(int id) => '/consignments/$id/status';
  static const String expiringSoon = '/consignments/expiring-soon';

  // Sales
  static const String sales = '/sales';
  static const String mySales = '/sales/my';
  static const String salesSummary = '/sales/summary';

  // Agreements
  static const String proposeAgreement = '/agreements/propose';
  static String counterAgreement(int id) => '/agreements/$id/counter';
  static String acceptAgreement(int id) => '/agreements/$id/accept';
  static String rejectAgreement(int id) => '/agreements/$id/reject';
  static const String pendingAgreements = '/agreements/pending';
  static String settlement(int consignmentId) =>
      '/agreements/settlement/$consignmentId';
}
