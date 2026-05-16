import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/restaurant_models.dart';

abstract class RestaurantRemoteDatasource {
  Future<List<RestaurantOrder>> getOrders();
  Future<void> acceptOrder(int orderId);
  Future<void> prepareOrder(int orderId);
  Future<void> markReady(int orderId);
  Future<List<RestaurantMenuItem>> getMenu();
  Future<RestaurantMenuItem> addMenuItem(RestaurantMenuItem item);
  Future<RestaurantMenuItem> updateMenuItem(int id, RestaurantMenuItem item);
  Future<void> deleteMenuItem(int id);
}

class RestaurantRemoteDatasourceImpl implements RestaurantRemoteDatasource {
  final ApiClient _client;
  RestaurantRemoteDatasourceImpl(this._client);

  @override
  Future<List<RestaurantOrder>> getOrders() async {
    final res = await _client.get(ApiConstants.restaurantOrders);
    return (res.data['data'] as List).map((e) => RestaurantOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> acceptOrder(int orderId) => _client.put(ApiConstants.acceptOrder(orderId));

  @override
  Future<void> prepareOrder(int orderId) => _client.put(ApiConstants.prepareOrder(orderId));

  @override
  Future<void> markReady(int orderId) => _client.put(ApiConstants.readyOrder(orderId));

  @override
  Future<List<RestaurantMenuItem>> getMenu() async {
    final res = await _client.get(ApiConstants.menuItems);
    return (res.data['data'] as List).map((e) => RestaurantMenuItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<RestaurantMenuItem> addMenuItem(RestaurantMenuItem item) async {
    final res = await _client.post(ApiConstants.menuItems, data: item.toJson());
    return RestaurantMenuItem.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<RestaurantMenuItem> updateMenuItem(int id, RestaurantMenuItem item) async {
    final res = await _client.put(ApiConstants.menuItemById(id), data: item.toJson());
    return RestaurantMenuItem.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMenuItem(int id) => _client.delete(ApiConstants.menuItemById(id));
}
