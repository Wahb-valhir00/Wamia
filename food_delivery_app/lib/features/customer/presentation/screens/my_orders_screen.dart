import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/mock/mock_order_service.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../data/models/order_model.dart';
import '../bloc/order_bloc.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const FetchMyOrders());
    MockOrderService.instance.addListener(_onChange);
  }

  @override
  void dispose() {
    MockOrderService.instance.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (!mounted) return;
    context.read<OrderBloc>().add(const FetchMyOrders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) return const AppLoading();
          if (state is OrderError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<OrderBloc>().add(const FetchMyOrders()),
            );
          }
          if (state is MyOrdersLoaded) {
            if (state.orders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, size: 64, color: AppColors.textSecondary),
                    SizedBox(height: 16),
                    Text('No orders yet', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, i) => _OrderCard(
                order: state.orders[i],
                onTap: () => context.push('/customer/order/${state.orders[i].id}'),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.delivered: return AppColors.success;
      case OrderStatus.preparing:
      case OrderStatus.ready: return AppColors.warning;
      case OrderStatus.pickedUp:
      case OrderStatus.assigned: return AppColors.driverColor;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order.id}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(order.status.displayName,
                      style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.restaurantName, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('MMM d, hh:mm a').format(order.createdAt),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                Text('\$${order.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
