import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/cart_model.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/order_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Cart'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: () => context.read<CartBloc>().add(const ClearCart()),
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderPlaced) {
            context.read<CartBloc>().add(const ClearCart());
            context.go('/customer/order/${state.order.id}');
          } else if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (cartState.cart.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 72, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text('Your cart is empty', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => context.go('/customer/home'),
                      child: const Text('Browse Restaurants', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.cart.items.length,
                    itemBuilder: (context, i) => _CartItemTile(item: cartState.cart.items[i]),
                  ),
                ),
                _OrderSummary(cart: cartState.cart),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fastfood, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menuItem.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                if (item.selectedOptions.isNotEmpty)
                  Text(item.selectedOptions.map((o) => o.name).join(', '),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text('\$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: () => context.read<CartBloc>().add(UpdateCartItemQuantity(
                      menuItemId: item.menuItem.id,
                      quantity: item.quantity - 1,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _QuantityButton(
                icon: Icons.add,
                onTap: () => context.read<CartBloc>().add(UpdateCartItemQuantity(
                      menuItemId: item.menuItem.id,
                      quantity: item.quantity + 1,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final Cart cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text('\$${cart.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 4),
            const Row(
              children: [
                Icon(Icons.payments_outlined, size: 14, color: AppColors.textSecondary),
                SizedBox(width: 4),
                Text('Cash on Delivery', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 16),
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: state is OrderLoading
                    ? null
                    : () => context.read<OrderBloc>().add(PlaceOrder(cart)),
                child: state is OrderLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Place Order', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
