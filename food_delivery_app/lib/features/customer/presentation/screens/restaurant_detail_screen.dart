import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/menu_item_model.dart';
import '../bloc/restaurant_bloc.dart';
import '../bloc/cart_bloc.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
    required this.restaurantName,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RestaurantBloc>().add(LoadRestaurantMenu(widget.restaurantId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.restaurantName),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              final count = state.cart.itemCount;
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: count > 0 ? () => context.push('/customer/cart') : null,
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Text('$count',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<RestaurantBloc, RestaurantState>(
        builder: (context, state) {
          if (state is RestaurantLoading) return const AppLoading();
          if (state is RestaurantError) return AppErrorWidget(message: state.message);
          if (state is RestaurantMenuLoaded) {
            if (state.menu.isEmpty) {
              return const Center(child: Text('No menu items available'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.menu.length,
              itemBuilder: (context, i) => _MenuItemCard(
                item: state.menu[i],
                restaurantId: widget.restaurantId,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.cart.isEmpty) return const SizedBox.shrink();
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 8, offset: Offset(0, -2))],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => context.push('/customer/cart'),
                child: Text(
                  'View Cart · \$${state.cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItemCard extends StatefulWidget {
  final MenuItemModel item;
  final int restaurantId;

  const _MenuItemCard({required this.item, required this.restaurantId});

  @override
  State<_MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<_MenuItemCard> {
  final Set<int> _selectedOptionIds = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.item.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('\$${widget.item.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: _addToCart,
                  child: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            if (widget.item.options.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Customize:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: widget.item.options.map((opt) {
                  final selected = _selectedOptionIds.contains(opt.id);
                  return FilterChip(
                    label: Text('${opt.name} (+\$${opt.price.toStringAsFixed(2)})'),
                    selected: selected,
                    onSelected: (val) => setState(() {
                      if (val) {
                        _selectedOptionIds.add(opt.id);
                      } else {
                        _selectedOptionIds.remove(opt.id);
                      }
                    }),
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    final selectedOptions = widget.item.options.where((o) => _selectedOptionIds.contains(o.id)).toList();
    context.read<CartBloc>().add(AddToCart(
          restaurantId: widget.restaurantId,
          menuItem: widget.item,
          selectedOptions: selectedOptions,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item.name} added to cart'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
