import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_loading.dart';
import '../bloc/order_bloc.dart';
import 'qr_code_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _fetch();
    // Poll every 10 seconds for status updates
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
  }

  void _fetch() => context.read<OrderBloc>().add(FetchOrder(widget.orderId));

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order #${widget.orderId}'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.go('/customer/home'),
        ),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) return const AppLoading(message: 'Loading order...');
          if (state is OrderError) return AppErrorWidget(message: state.message, onRetry: _fetch);
          if (state is OrderLoaded || state is OrderPlaced) {
            final order = state is OrderLoaded ? state.order : (state as OrderPlaced).order;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusBanner(status: order.status),
                  const SizedBox(height: 24),
                  _StepTracker(currentStatus: order.status),
                  const SizedBox(height: 24),
                  _OrderDetails(
                    orderId: order.id,
                    restaurantName: order.restaurantName,
                    total: order.totalPrice,
                    createdAt: order.createdAt,
                  ),
                  const SizedBox(height: 24),
                  // Show QR code for delivery confirmation
                  if (order.status == OrderStatus.assigned ||
                      order.status == OrderStatus.pickedUp) ...[
                    const Text('Delivery QR Code',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    const Text('Show this QR to the driver upon delivery',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    QrCodeWidget(data: order.qrData),
                  ],
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final OrderStatus status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (status) {
      case OrderStatus.created:
        color = AppColors.statusCreated; icon = Icons.hourglass_empty;
        break;
      case OrderStatus.accepted:
        color = AppColors.statusAccepted; icon = Icons.check_circle_outline;
        break;
      case OrderStatus.preparing:
        color = AppColors.statusPreparing; icon = Icons.restaurant;
        break;
      case OrderStatus.ready:
        color = AppColors.statusReady; icon = Icons.done_all;
        break;
      case OrderStatus.assigned:
        color = AppColors.statusAssigned; icon = Icons.delivery_dining;
        break;
      case OrderStatus.pickedUp:
        color = AppColors.statusPickedUp; icon = Icons.local_shipping;
        break;
      case OrderStatus.delivered:
        color = AppColors.statusDelivered; icon = Icons.home;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Order Status', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(status.displayName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepTracker extends StatelessWidget {
  final OrderStatus currentStatus;
  const _StepTracker({required this.currentStatus});

  static const _steps = [
    OrderStatus.created,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.assigned,
    OrderStatus.pickedUp,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _steps.indexOf(currentStatus);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(_steps.length, (i) {
          final done = i <= currentIdx;
          final active = i == currentIdx;
          final step = _steps[i];
          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: done ? AppColors.primary : AppColors.divider,
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  if (i < _steps.length - 1)
                    Container(width: 2, height: 24, color: done ? AppColors.primary : AppColors.divider),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: i < _steps.length - 1 ? 24 : 0),
                  child: Text(
                    step.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: done ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  final int orderId;
  final String restaurantName;
  final double total;
  final DateTime createdAt;
  const _OrderDetails({
    required this.orderId,
    required this.restaurantName,
    required this.total,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _Row('Order ID', '#$orderId'),
          const Divider(height: 16),
          _Row('Restaurant', restaurantName),
          const Divider(height: 16),
          _Row('Total', '\$${total.toStringAsFixed(2)}'),
          const Divider(height: 16),
          _Row('Payment', 'Cash on Delivery'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
