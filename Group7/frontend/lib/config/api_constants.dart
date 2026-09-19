class ApiConstants {
  // Use http://localhost:5001/api for iOS Simulator / Web / Desktop / macOS
  // Use http://10.0.2.2:5001/api for Android Emulator
  // Or replace with your local Wi-Fi IP (e.g., http://192.168.1.5:5001/api) for physical phone testing
  static const String baseUrl = 'http://localhost:5001/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String me = '$baseUrl/auth/me';

  // Restaurant endpoints
  static const String restaurants = '$baseUrl/restaurants';

  // Food Item endpoints
  static const String foodItems = '$baseUrl/food-items';

  // Order endpoints
  static const String orders = '$baseUrl/orders';
  static const String myOrders = '$baseUrl/orders/my-orders';

  // Admin endpoints
  static const String adminStats = '$baseUrl/admin/dashboard-stats';
  static const String adminUsers = '$baseUrl/admin/users';
  static const String adminOrders = '$baseUrl/admin/orders';
  static const String adminReports = '$baseUrl/admin/reports';
}
