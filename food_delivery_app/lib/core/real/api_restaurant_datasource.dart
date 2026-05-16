import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../../features/restaurant/data/datasources/restaurant_remote_datasource.dart';
import '../../features/restaurant/data/models/restaurant_models.dart';

// REAL BACKEND — RestaurantRemoteDatasource implementation.
// Used when isMockMode = false.
// All methods call the Spring Boot API.
// DioExceptions are caught and re-thrown as readable Exception messages.
class ApiRestaurantDatasource implements RestaurantRemoteDatasource {
  final ApiClient _client;

  ApiRestaurantDatasource(this._client);

  // REAL: GET /api/orders/restaurant
  // Returns all orders for the authenticated restaurant owner.
  // Response envelope: { success, data: [OrderResponse] }
  // Status values match OrderStatus enum: CREATED, ACCEPTED, PREPARING, READY, ASSIGNED, PICKED_UP, DELIVERED
  @override
  Future<List<RestaurantOrder>> getOrders() async {
    try {
      final res = await _client.get(ApiConstants.restaurantOrders);
      final list = res.data['data'] as List? ?? [];
      return list
          .map((e) => RestaurantOrder.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  // REAL: PUT /api/orders/{id}/accept  (CREATED → ACCEPTED)
  @override
  Future<void> acceptOrder(int orderId) async {
    try {
      await _client.put(ApiConstants.acceptOrder(orderId));
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  // REAL: PUT /api/orders/{id}/prepare  (ACCEPTED → PREPARING)
  @override
  Future<void> prepareOrder(int orderId) async {
    try {
      await _client.put(ApiConstants.prepareOrder(orderId));
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  // REAL: PUT /api/orders/{id}/ready  (PREPARING → READY → ASSIGNED via auto-assign)
  @override
  Future<void> markReady(int orderId) async {
    try {
      await _client.put(ApiConstants.readyOrder(orderId));
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  // REAL: GET /api/menu-items
  @override
  Future<List<RestaurantMenuItem>> getMenu() async {
    try {
      final res = await _client.get(ApiConstants.menuItems);
      final list = res.data['data'] as List? ?? [];
      return list
          .map((e) => RestaurantMenuItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  // REAL: POST /api/menu-items
  @override
  Future<RestaurantMenuItem> addMenuItem(RestaurantMenuItem item) async {
    try {
      final res = await _client.post(ApiConstants.menuItems, data: item.toJson());
      return RestaurantMenuItem.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  // REAL: PUT /api/menu-items/{id}
  @override
  Future<RestaurantMenuItem> updateMenuItem(int id, RestaurantMenuItem item) async {
    try {
      final res = await _client.put(ApiConstants.menuItemById(id), data: item.toJson());
      return RestaurantMenuItem.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  // REAL: DELETE /api/menu-items/{id}
  @override
  Future<void> deleteMenuItem(int id) async {
    try {
      await _client.delete(ApiConstants.menuItemById(id));
    } on DioException catch (e) {
      throw Exception(_dioMessage(e));
    }
  }

  String _dioMessage(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response!.data['message'] as String;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Cannot reach server. Check your connection.';
      default:
        return 'Request failed. Please try again.';
    }
  }
}
