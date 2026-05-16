class ApiConstants {
  ApiConstants._();

  // 10.0.2.2 = Android emulator → localhost
  // localhost = Chrome / web
  static const String baseUrl = 'http://localhost:8081/api';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Customer
  static const String restaurants = '/restaurants';
  static String restaurantMenu(int id) => '/restaurants/$id/menu';
  static const String orders = '/orders';
  static String orderById(int id) => '/orders/$id';

  // Restaurant — GET /api/orders/restaurant (backend route, not /restaurant/orders)
  static const String restaurantOrders = '/orders/restaurant';
  static String acceptOrder(int id) => '/orders/$id/accept';
  static String prepareOrder(int id) => '/orders/$id/prepare';
  static String readyOrder(int id) => '/orders/$id/ready';

  // Menu management
  static const String menuItems = '/menu-items';
  static String menuItemById(int id) => '/menu-items/$id';

  // Driver
  static const String driverOrders = '/driver/orders';
  static String pickupOrder(int id) => '/orders/$id/pickup';
  static String deliverOrder(int id) => '/orders/$id/deliver';
  static const String driverStatus = '/driver/status';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
