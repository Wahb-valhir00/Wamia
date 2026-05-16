import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/restaurant_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';

abstract class CustomerRemoteDatasource {
  Future<List<RestaurantModel>> getRestaurants();
  Future<List<MenuItemModel>> getRestaurantMenu(int restaurantId);
  Future<OrderModel> placeOrder(Map<String, dynamic> orderData);
  Future<OrderModel> getOrder(int orderId);
  Future<List<OrderModel>> getMyOrders();
}

class CustomerRemoteDatasourceImpl implements CustomerRemoteDatasource {
  final ApiClient _client;
  CustomerRemoteDatasourceImpl(this._client);

  @override
  Future<List<RestaurantModel>> getRestaurants() async {
    final res = await _client.get(ApiConstants.restaurants);
    return (res.data['data'] as List).map((e) => RestaurantModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<MenuItemModel>> getRestaurantMenu(int restaurantId) async {
    final res = await _client.get(ApiConstants.restaurantMenu(restaurantId));
    return (res.data['data'] as List).map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<OrderModel> placeOrder(Map<String, dynamic> orderData) async {
    final res = await _client.post(ApiConstants.orders, data: orderData);
    return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> getOrder(int orderId) async {
    final res = await _client.get(ApiConstants.orderById(orderId));
    return OrderModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<OrderModel>> getMyOrders() async {
    final res = await _client.get('${ApiConstants.orders}/my');
    return (res.data['data'] as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
