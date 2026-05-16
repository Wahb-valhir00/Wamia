import 'menu_item_model.dart';

class CartItem {
  final MenuItemModel menuItem;
  final int quantity;
  final List<MenuOptionModel> selectedOptions;

  const CartItem({
    required this.menuItem,
    required this.quantity,
    required this.selectedOptions,
  });

  double get subtotal =>
      (menuItem.price + selectedOptions.fold(0.0, (sum, o) => sum + o.price)) * quantity;

  CartItem copyWith({int? quantity, List<MenuOptionModel>? selectedOptions}) {
    return CartItem(
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
      selectedOptions: selectedOptions ?? this.selectedOptions,
    );
  }

  Map<String, dynamic> toOrderJson() => {
        'menuItemId': menuItem.id,
        'quantity': quantity,
        'optionIds': selectedOptions.map((o) => o.id).toList(),
      };
}

class Cart {
  final int restaurantId;
  final List<CartItem> items;

  const Cart({required this.restaurantId, required this.items});

  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;

  Cart copyWith({int? restaurantId, List<CartItem>? items}) => Cart(
        restaurantId: restaurantId ?? this.restaurantId,
        items: items ?? this.items,
      );

  static const Cart empty = Cart(restaurantId: -1, items: []);
}
