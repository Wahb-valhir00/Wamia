import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/cart_model.dart';
import '../../data/models/menu_item_model.dart';

// --- Events ---
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final int restaurantId;
  final MenuItemModel menuItem;
  final List<MenuOptionModel> selectedOptions;
  const AddToCart({
    required this.restaurantId,
    required this.menuItem,
    required this.selectedOptions,
  });
  @override
  List<Object?> get props => [restaurantId, menuItem, selectedOptions];
}

class RemoveFromCart extends CartEvent {
  final int menuItemId;
  const RemoveFromCart(this.menuItemId);
  @override
  List<Object?> get props => [menuItemId];
}

class UpdateCartItemQuantity extends CartEvent {
  final int menuItemId;
  final int quantity;
  const UpdateCartItemQuantity({required this.menuItemId, required this.quantity});
  @override
  List<Object?> get props => [menuItemId, quantity];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

// --- States ---
class CartState extends Equatable {
  final Cart cart;
  const CartState(this.cart);
  @override
  List<Object?> get props => [cart];
}

// --- Bloc ---
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState(Cart.empty)) {
    on<AddToCart>(_onAdd);
    on<RemoveFromCart>(_onRemove);
    on<UpdateCartItemQuantity>(_onUpdate);
    on<ClearCart>(_onClear);
  }

  void _onAdd(AddToCart event, Emitter<CartState> emit) {
    final cart = state.cart;

    // Clear cart if switching restaurant
    if (cart.restaurantId != -1 && cart.restaurantId != event.restaurantId) {
      emit(CartState(Cart(
        restaurantId: event.restaurantId,
        items: [CartItem(menuItem: event.menuItem, quantity: 1, selectedOptions: event.selectedOptions)],
      )));
      return;
    }

    final existing = cart.items.indexWhere((i) => i.menuItem.id == event.menuItem.id);
    final List<CartItem> updated = List.from(cart.items);

    if (existing >= 0) {
      updated[existing] = updated[existing].copyWith(quantity: updated[existing].quantity + 1);
    } else {
      updated.add(CartItem(
        menuItem: event.menuItem,
        quantity: 1,
        selectedOptions: event.selectedOptions,
      ));
    }

    emit(CartState(cart.copyWith(restaurantId: event.restaurantId, items: updated)));
  }

  void _onRemove(RemoveFromCart event, Emitter<CartState> emit) {
    final updated = state.cart.items.where((i) => i.menuItem.id != event.menuItemId).toList();
    emit(CartState(state.cart.copyWith(items: updated)));
  }

  void _onUpdate(UpdateCartItemQuantity event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.menuItemId));
      return;
    }
    final updated = state.cart.items.map((i) {
      if (i.menuItem.id == event.menuItemId) return i.copyWith(quantity: event.quantity);
      return i;
    }).toList();
    emit(CartState(state.cart.copyWith(items: updated)));
  }

  void _onClear(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState(Cart.empty));
  }
}
