import '../../../../core/utils/enums.dart';

class RestaurantOrderItem {
  final int menuItemId;
  final String menuItemName;
  final int quantity;
  final List<String> optionNames;

  const RestaurantOrderItem({
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.optionNames,
  });

  factory RestaurantOrderItem.fromJson(Map<String, dynamic> json) => RestaurantOrderItem(
        menuItemId: json['menuItemId'] as int,
        menuItemName: json['menuItemName'] as String,
        quantity: json['quantity'] as int,
        optionNames: (json['optionNames'] as List<dynamic>? ?? []).cast<String>(),
      );
}

class RestaurantOrder {
  final int id;
  final String customerName;
  final OrderStatus status;
  final double totalPrice;
  final List<RestaurantOrderItem> items;
  final DateTime createdAt;
  final String? qrToken;

  const RestaurantOrder({
    required this.id,
    required this.customerName,
    required this.status,
    required this.totalPrice,
    required this.items,
    required this.createdAt,
    this.qrToken,
  });

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) => RestaurantOrder(
        id: json['id'] as int,
        customerName: json['customerName'] as String? ?? 'Customer',
        status: OrderStatusX.fromString(json['status'] as String),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => RestaurantOrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        qrToken: json['qrToken'] as String?,
      );

  String get qrData => '{"orderId":$id,"qrToken":"${qrToken ?? ""}"}';
}

class RestaurantMenuItemOption {
  final int? id;
  final String name;
  final double price;

  const RestaurantMenuItemOption({this.id, required this.name, required this.price});

  factory RestaurantMenuItemOption.fromJson(Map<String, dynamic> json) => RestaurantMenuItemOption(
        id: json['id'] as int?,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {'name': name, 'price': price};
}

class RestaurantMenuItem {
  final int? id;
  final String name;
  final double price;
  final List<RestaurantMenuItemOption> options;

  const RestaurantMenuItem({
    this.id,
    required this.name,
    required this.price,
    required this.options,
  });

  factory RestaurantMenuItem.fromJson(Map<String, dynamic> json) => RestaurantMenuItem(
        id: json['id'] as int?,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        options: (json['options'] as List<dynamic>? ?? [])
            .map((e) => RestaurantMenuItemOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'options': options.map((o) => o.toJson()).toList(),
      };
}
