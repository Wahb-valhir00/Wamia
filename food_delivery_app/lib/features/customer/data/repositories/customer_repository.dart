import '../../../../core/utils/result.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/restaurant_model.dart';
import '../models/menu_item_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';

abstract class CustomerRepository {
  Future<Result<List<RestaurantModel>>> getRestaurants();
  Future<Result<List<MenuItemModel>>> getRestaurantMenu(int restaurantId);
  Future<Result<OrderModel>> placeOrder(Cart cart);
  Future<Result<OrderModel>> getOrder(int orderId);
  Future<Result<List<OrderModel>>> getMyOrders();
}

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDatasource _datasource;
  CustomerRepositoryImpl(this._datasource);

  @override
  Future<Result<List<RestaurantModel>>> getRestaurants() async {
    try {
      return Success(await _datasource.getRestaurants());
    } catch (e) {
      return Failure(_msg(e));
    }
  }

  @override
  Future<Result<List<MenuItemModel>>> getRestaurantMenu(int restaurantId) async {
    try {
      return Success(await _datasource.getRestaurantMenu(restaurantId));
    } catch (e) {
      return Failure(_msg(e));
    }
  }

  @override
  Future<Result<OrderModel>> placeOrder(Cart cart) async {
    try {
      final data = {
        'restaurantId': cart.restaurantId,
        'items': cart.items.map((i) => i.toOrderJson()).toList(),
      };
      return Success(await _datasource.placeOrder(data));
    } catch (e) {
      return Failure(_msg(e));
    }
  }

  @override
  Future<Result<OrderModel>> getOrder(int orderId) async {
    try {
      return Success(await _datasource.getOrder(orderId));
    } catch (e) {
      return Failure(_msg(e));
    }
  }

  @override
  Future<Result<List<OrderModel>>> getMyOrders() async {
    try {
      return Success(await _datasource.getMyOrders());
    } catch (e) {
      return Failure(_msg(e));
    }
  }

  String _msg(Object e) => e.toString().replaceFirst('Exception: ', '');
}
