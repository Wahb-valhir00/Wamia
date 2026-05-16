import '../../features/restaurant/data/datasources/restaurant_remote_datasource.dart';
import '../../features/restaurant/data/models/restaurant_models.dart';
import 'mock_order_service.dart';

// In-memory mock menu (managed locally for the restaurant role)
final List<RestaurantMenuItem> _mockMenu = [
  const RestaurantMenuItem(id: 101, name: 'Classic Cheeseburger', price: 8.99, options: [
    RestaurantMenuItemOption(id: 1001, name: 'Extra Cheese', price: 0.99),
    RestaurantMenuItemOption(id: 1002, name: 'Bacon', price: 1.49),
  ]),
  const RestaurantMenuItem(id: 102, name: 'Double Smash Burger', price: 11.99, options: [
    RestaurantMenuItemOption(id: 1003, name: 'Jalapeños', price: 0.50),
  ]),
  const RestaurantMenuItem(id: 103, name: 'Crispy Chicken Burger', price: 9.99, options: []),
  const RestaurantMenuItem(id: 104, name: 'Loaded Fries', price: 4.99, options: [
    RestaurantMenuItemOption(id: 1004, name: 'Cheese Sauce', price: 0.75),
  ]),
  const RestaurantMenuItem(id: 105, name: 'Chocolate Milkshake', price: 5.49, options: []),
  const RestaurantMenuItem(id: 106, name: 'Onion Rings', price: 3.99, options: []),
];

int _nextMenuId = 200;

class MockRestaurantDatasource implements RestaurantRemoteDatasource {
  @override
  Future<List<RestaurantOrder>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockOrderService.instance
        .getRestaurantOrders()
        .map((o) => o.toRestaurantOrder())
        .toList();
  }

  @override
  Future<void> acceptOrder(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockOrderService.instance.acceptOrder(orderId);
  }

  @override
  Future<void> prepareOrder(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockOrderService.instance.prepareOrder(orderId);
  }

  @override
  Future<void> markReady(int orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    MockOrderService.instance.markReady(orderId);
  }

  @override
  Future<List<RestaurantMenuItem>> getMenu() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockMenu);
  }

  @override
  Future<RestaurantMenuItem> addMenuItem(RestaurantMenuItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newItem = RestaurantMenuItem(
      id: _nextMenuId++,
      name: item.name,
      price: item.price,
      options: item.options,
    );
    _mockMenu.add(newItem);
    return newItem;
  }

  @override
  Future<RestaurantMenuItem> updateMenuItem(int id, RestaurantMenuItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockMenu.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final updated = RestaurantMenuItem(id: id, name: item.name, price: item.price, options: item.options);
      _mockMenu[idx] = updated;
      return updated;
    }
    return item;
  }

  @override
  Future<void> deleteMenuItem(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockMenu.removeWhere((m) => m.id == id);
  }
}

// Compatibility export — Stats screen imports this
List<RestaurantOrder> getMockOrdersSnapshot() => MockOrderService.instance
    .getRestaurantOrders()
    .map((o) => o.toRestaurantOrder())
    .toList();
