import '../utils/result.dart';
import '../storage/secure_storage.dart';
import '../../features/customer/data/models/cart_model.dart';
import '../../features/customer/data/models/menu_item_model.dart';
import '../../features/customer/data/models/order_model.dart';
import '../../features/customer/data/models/restaurant_model.dart';
import '../../features/customer/data/repositories/customer_repository.dart';
import 'mock_data.dart';
import 'mock_order_service.dart';

class MockCustomerRepository implements CustomerRepository {
  @override
  Future<Result<List<RestaurantModel>>> getRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Success(List.from(mockRestaurants));
  }

  @override
  Future<Result<List<MenuItemModel>>> getRestaurantMenu(int restaurantId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Success(List.from(mockMenus[restaurantId] ?? []));
  }

  @override
  Future<Result<OrderModel>> placeOrder(Cart cart) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final restaurant = mockRestaurants.firstWhere(
      (r) => r.id == cart.restaurantId,
      orElse: () => const RestaurantModel(id: 0, name: 'Unknown', location: 'Unknown'),
    );
    final customerName = await SecureStorage.instance.getUserName() ?? 'Customer';

    final mockOrder = MockOrderService.instance.placeOrder(
      cart: cart,
      restaurantName: restaurant.name,
      restaurantLocation: restaurant.location,
      customerName: customerName,
    );
    return Success(mockOrder.toCustomerOrder());
  }

  @override
  Future<Result<OrderModel>> getOrder(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final order = MockOrderService.instance.getOrderById(orderId);
    if (order == null) return const Failure('Order not found');
    return Success(order.toCustomerOrder());
  }

  @override
  Future<Result<List<OrderModel>>> getMyOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final orders = MockOrderService.instance
        .getCustomerOrders()
        .map((o) => o.toCustomerOrder())
        .toList();
    return Success(orders);
  }
}
