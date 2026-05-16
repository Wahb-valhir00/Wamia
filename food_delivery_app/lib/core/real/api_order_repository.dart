import 'package:dio/dio.dart';
import '../utils/result.dart';
import '../../features/customer/data/datasources/customer_remote_datasource.dart';
import '../../features/customer/data/models/cart_model.dart';
import '../../features/customer/data/models/menu_item_model.dart';
import '../../features/customer/data/models/order_model.dart';
import '../../features/customer/data/models/restaurant_model.dart';
import '../../features/customer/data/repositories/customer_repository.dart';

// REAL BACKEND — CustomerRepository implementation.
// Used when isMockMode = false.
// All methods call the Spring Boot API via CustomerRemoteDatasource.
class ApiOrderRepository implements CustomerRepository {
  final CustomerRemoteDatasource _datasource;

  ApiOrderRepository(this._datasource);

  // REAL: GET /api/restaurants
  @override
  Future<Result<List<RestaurantModel>>> getRestaurants() async {
    try {
      return Success(await _datasource.getRestaurants());
    } on DioException catch (e) {
      return Failure(_dioMessage(e));
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // REAL: GET /api/restaurants/{id}/menu
  @override
  Future<Result<List<MenuItemModel>>> getRestaurantMenu(int restaurantId) async {
    try {
      return Success(await _datasource.getRestaurantMenu(restaurantId));
    } on DioException catch (e) {
      return Failure(_dioMessage(e));
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // REAL: POST /api/orders
  // Payload: { restaurantId, items: [{ menuItemId, quantity, optionIds[] }] }
  // Response envelope: { success, data: OrderResponse }
  @override
  Future<Result<OrderModel>> placeOrder(Cart cart) async {
    try {
      final data = {
        'restaurantId': cart.restaurantId,
        'items': cart.items.map((i) => i.toOrderJson()).toList(),
      };
      return Success(await _datasource.placeOrder(data));
    } on DioException catch (e) {
      return Failure(_dioMessage(e));
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // REAL: GET /api/orders/{id}
  @override
  Future<Result<OrderModel>> getOrder(int orderId) async {
    try {
      return Success(await _datasource.getOrder(orderId));
    } on DioException catch (e) {
      return Failure(_dioMessage(e));
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // REAL: GET /api/orders/my
  @override
  Future<Result<List<OrderModel>>> getMyOrders() async {
    try {
      return Success(await _datasource.getMyOrders());
    } on DioException catch (e) {
      return Failure(_dioMessage(e));
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
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
