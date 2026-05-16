import 'package:flutter/foundation.dart';
import '../utils/enums.dart';
import '../../features/customer/data/models/cart_model.dart';
import '../../features/customer/data/models/order_model.dart';
import '../../features/restaurant/data/models/restaurant_models.dart';
import '../../features/driver/data/models/driver_models.dart';

// ─── Core unified order ───────────────────────────────────────────────────────

class MockOrder {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final String restaurantLocation;
  final String customerName;
  final List<MockOrderItem> items;
  final double totalPrice;
  final String qrToken;
  final DateTime createdAt;
  OrderStatus status;

  MockOrder({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantLocation,
    required this.customerName,
    required this.items,
    required this.totalPrice,
    required this.qrToken,
    required this.createdAt,
    required this.status,
  });

  // Customer view
  OrderModel toCustomerOrder() => OrderModel(
        id: id,
        status: status,
        totalPrice: totalPrice,
        qrToken: qrToken,
        restaurantName: restaurantName,
        createdAt: createdAt,
      );

  // Restaurant view
  RestaurantOrder toRestaurantOrder() => RestaurantOrder(
        id: id,
        customerName: customerName,
        status: status,
        totalPrice: totalPrice,
        items: items
            .map((i) => RestaurantOrderItem(
                  menuItemId: i.menuItemId,
                  menuItemName: i.menuItemName,
                  quantity: i.quantity,
                  optionNames: i.optionNames,
                ))
            .toList(),
        createdAt: createdAt,
        qrToken: qrToken,
      );

  // Driver view
  DriverOrder toDriverOrder() => DriverOrder(
        id: id,
        customerName: customerName,
        restaurantName: restaurantName,
        restaurantLocation: restaurantLocation,
        status: status,
        totalPrice: totalPrice,
        qrToken: qrToken,
      );
}

class MockOrderItem {
  final int menuItemId;
  final String menuItemName;
  final int quantity;
  final List<String> optionNames;

  const MockOrderItem({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.optionNames,
  });
}

// ─── Singleton service ────────────────────────────────────────────────────────

class MockOrderService extends ChangeNotifier {
  MockOrderService._() {
    _seedDemo();
  }
  static final MockOrderService instance = MockOrderService._();

  final List<MockOrder> _orders = [];
  int _nextId = 3000;

  List<MockOrder> get all => List.unmodifiable(_orders);

  // ── Customer ──────────────────────────────────────────────────────────────
  MockOrder placeOrder({
    required Cart cart,
    required String restaurantName,
    required String restaurantLocation,
    required String customerName,
  }) {
    final order = MockOrder(
      id: _nextId++,
      restaurantId: cart.restaurantId,
      restaurantName: restaurantName,
      restaurantLocation: restaurantLocation,
      customerName: customerName,
      totalPrice: cart.total,
      qrToken: 'qr-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      status: OrderStatus.created,
      items: cart.items
          .map((c) => MockOrderItem(
                menuItemId: c.menuItem.id,
                menuItemName: c.menuItem.name,
                quantity: c.quantity,
                optionNames: c.selectedOptions.map((o) => o.name).toList(),
              ))
          .toList(),
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  List<MockOrder> getCustomerOrders() => _orders.toList();

  MockOrder? getOrderById(int id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Restaurant ────────────────────────────────────────────────────────────
  List<MockOrder> getRestaurantOrders() => _orders.toList();

  void acceptOrder(int orderId) => _setStatus(orderId, OrderStatus.accepted);
  void prepareOrder(int orderId) => _setStatus(orderId, OrderStatus.preparing);
  void markReady(int orderId) => _setStatus(orderId, OrderStatus.ready);

  // ── Driver ────────────────────────────────────────────────────────────────
  /// Available for driver = READY or ASSIGNED or PICKED_UP (active deliveries)
  List<MockOrder> getDriverOrders() => _orders
      .where((o) =>
          o.status == OrderStatus.ready ||
          o.status == OrderStatus.assigned ||
          o.status == OrderStatus.pickedUp)
      .toList();

  void pickUpOrder(int orderId) => _setStatus(orderId, OrderStatus.pickedUp);
  void deliverOrder(int orderId) => _setStatus(orderId, OrderStatus.delivered);

  // ── Internals ─────────────────────────────────────────────────────────────
  void _setStatus(int orderId, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx].status = status;
      notifyListeners();
    }
  }

  void _seedDemo() {
    _orders.addAll([
      MockOrder(
        id: 2001,
        restaurantId: 1,
        restaurantName: 'Burger Bliss',
        restaurantLocation: 'Downtown, 12 Main St',
        customerName: 'Ali Ben Salem',
        totalPrice: 24.97,
        qrToken: 'qr-2001',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        status: OrderStatus.created,
        items: const [
          MockOrderItem(menuItemId: 101, menuItemName: 'Classic Cheeseburger', quantity: 2, optionNames: ['Extra Cheese']),
          MockOrderItem(menuItemId: 104, menuItemName: 'Loaded Fries', quantity: 1, optionNames: []),
        ],
      ),
      MockOrder(
        id: 2002,
        restaurantId: 1,
        restaurantName: 'Burger Bliss',
        restaurantLocation: 'Downtown, 12 Main St',
        customerName: 'Sara Mansour',
        totalPrice: 18.48,
        qrToken: 'qr-2002',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        status: OrderStatus.accepted,
        items: const [
          MockOrderItem(menuItemId: 102, menuItemName: 'Double Smash Burger', quantity: 1, optionNames: ['Jalapeños']),
          MockOrderItem(menuItemId: 105, menuItemName: 'Chocolate Milkshake', quantity: 1, optionNames: []),
        ],
      ),
      MockOrder(
        id: 2003,
        restaurantId: 2,
        restaurantName: 'Pizza Palace',
        restaurantLocation: 'Uptown, 45 Oak Ave',
        customerName: 'Karim Toumi',
        totalPrice: 31.96,
        qrToken: 'qr-2003',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        status: OrderStatus.preparing,
        items: const [
          MockOrderItem(menuItemId: 201, menuItemName: 'Margherita Pizza', quantity: 2, optionNames: []),
          MockOrderItem(menuItemId: 205, menuItemName: 'Garlic Bread', quantity: 1, optionNames: []),
        ],
      ),
      MockOrder(
        id: 2004,
        restaurantId: 2,
        restaurantName: 'Pizza Palace',
        restaurantLocation: 'Uptown, 45 Oak Ave',
        customerName: 'Nour Belhaj',
        totalPrice: 14.48,
        qrToken: 'qr-2004',
        createdAt: DateTime.now().subtract(const Duration(minutes: 28)),
        status: OrderStatus.ready,
        items: const [
          MockOrderItem(menuItemId: 202, menuItemName: 'Pepperoni Feast', quantity: 1, optionNames: []),
        ],
      ),
    ]);
  }
}
