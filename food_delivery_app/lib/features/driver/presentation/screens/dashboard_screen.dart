import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/mock/mock_order_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../data/models/driver_models.dart';
import '../bloc/driver_bloc.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  String _driverName = '';
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    context.read<DriverBloc>().add(LoadDriverOrders());
    MockOrderService.instance.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    MockOrderService.instance.removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    if (!mounted) return;
    context.read<DriverBloc>().add(LoadDriverOrders());
  }

  Future<void> _loadUser() async {
    final name = await SecureStorage.instance.getUserName();
    if (mounted) setState(() => _driverName = name ?? 'Driver');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverBloc, DriverState>(
      listener: (context, state) {
        if (state is DriverActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
          );
        } else if (state is DriverError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Driver Dashboard', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().add(const LogoutRequested()),
            ),
          ],
        ),
        body: Column(
          children: [
            _AvailabilityToggle(
              isOnline: _isOnline,
              onToggle: (val) {
                setState(() => _isOnline = val);
                context.read<DriverBloc>().add(UpdateDriverStatus(val ? 'ONLINE' : 'OFFLINE'));
              },
            ),
            Expanded(
              child: BlocBuilder<DriverBloc, DriverState>(
                builder: (context, state) {
                  if (state is DriverLoading) return const AppLoading(message: 'Loading orders...');
                  if (state is DriverError) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: () => context.read<DriverBloc>().add(LoadDriverOrders()),
                    );
                  }
                  if (state is DriverOrdersLoaded) {
                    if (state.orders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isOnline ? Icons.hourglass_empty : Icons.power_settings_new,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isOnline ? 'Waiting for orders...' : 'Go online to receive orders',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => context.read<DriverBloc>().add(LoadDriverOrders()),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.orders.length,
                        itemBuilder: (context, i) => _DriverOrderCard(order: state.orders[i]),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityToggle extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;
  const _AvailabilityToggle({required this.isOnline, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 12, height: 12,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.success : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'You are Online' : 'You are Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isOnline ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
                Text(
                  isOnline ? 'Ready to receive orders' : 'Toggle to start accepting orders',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            onChanged: onToggle,
            activeColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _DriverOrderCard extends StatelessWidget {
  final DriverOrder order;
  const _DriverOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6)],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.delivery_dining, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Order #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(order.status.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _InfoRow(Icons.restaurant, 'Restaurant', order.restaurantName),
                const SizedBox(height: 8),
                _InfoRow(Icons.location_on_outlined, 'Pickup from', order.restaurantLocation),
                const SizedBox(height: 8),
                _InfoRow(Icons.person_outline, 'Customer', order.customerName),
                const SizedBox(height: 8),
                _InfoRow(Icons.attach_money, 'Total', '\$${order.totalPrice.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                _buildAction(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context) {
    switch (order.status) {
      case OrderStatus.ready:
      case OrderStatus.assigned:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.local_shipping_rounded, color: Colors.white),
            label: const Text('Pick Up Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => context.read<DriverBloc>().add(
                  ConfirmPickup(orderId: order.id, qrToken: order.qrToken ?? ''),
                ),
          ),
        );
      case OrderStatus.pickedUp:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
            label: const Text('Deliver Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => context.read<DriverBloc>().add(
                  ConfirmDelivery(orderId: order.id, qrToken: order.qrToken ?? ''),
                ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontSize: 13)),
        ),
      ],
    );
  }
}
