import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/mock/mock_restaurant_datasource.dart';
import '../../../../core/utils/enums.dart';
import '../../data/models/restaurant_models.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = isMockMode ? getMockOrdersSnapshot() : <RestaurantOrder>[];
    final today = DateTime.now();

    final todayOrders = orders.where((o) =>
        o.createdAt.year == today.year &&
        o.createdAt.month == today.month &&
        o.createdAt.day == today.day).toList();

    final completedToday = todayOrders
        .where((o) => o.status == OrderStatus.delivered || o.status == OrderStatus.ready)
        .toList();

    final revenue = completedToday.fold<double>(0, (sum, o) => sum + o.totalPrice);
    final avgOrder = completedToday.isEmpty ? 0.0 : revenue / completedToday.length;
    final pending = todayOrders
        .where((o) =>
            o.status == OrderStatus.created ||
            o.status == OrderStatus.accepted ||
            o.status == OrderStatus.preparing)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Today\'s Overview'),
          const SizedBox(height: 12),

          // Top 2 big stats
          Row(
            children: [
              Expanded(
                child: _BigStatCard(
                  label: 'Total Orders',
                  value: '${todayOrders.length}',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BigStatCard(
                  label: 'Revenue',
                  value: '\$${revenue.toStringAsFixed(2)}',
                  icon: Icons.payments_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmallStatCard(
                  label: 'Completed',
                  value: '${completedToday.length}',
                  icon: Icons.check_circle_outline_rounded,
                  color: AppColors.statusReady,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallStatCard(
                  label: 'Pending',
                  value: '$pending',
                  icon: Icons.hourglass_bottom_rounded,
                  color: AppColors.statusPreparing,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallStatCard(
                  label: 'Avg Order',
                  value: '\$${avgOrder.toStringAsFixed(2)}',
                  icon: Icons.trending_up_rounded,
                  color: AppColors.statusAccepted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const _SectionTitle('Order Breakdown'),
          const SizedBox(height: 12),
          _StatusBreakdown(orders: todayOrders),

          const SizedBox(height: 24),
          const _SectionTitle('Recent Completed Orders'),
          const SizedBox(height: 12),
          if (completedToday.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No completed orders today',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            ...completedToday.take(5).map((o) => _CompletedOrderRow(order: o)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }
}

class _BigStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _BigStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _SmallStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatusBreakdown extends StatelessWidget {
  final List<RestaurantOrder> orders;
  const _StatusBreakdown({required this.orders});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      ('New', OrderStatus.created, AppColors.statusCreated),
      ('Accepted', OrderStatus.accepted, AppColors.statusAccepted),
      ('Preparing', OrderStatus.preparing, AppColors.statusPreparing),
      ('Ready', OrderStatus.ready, AppColors.statusReady),
      ('Delivered', OrderStatus.delivered, AppColors.statusDelivered),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        children: statuses.map((s) {
          final count = orders.where((o) => o.status == s.$2).length;
          final pct = orders.isEmpty ? 0.0 : count / orders.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(color: s.$3, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                SizedBox(width: 70, child: Text(s.$1, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(s.$3),
                      minHeight: 7,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24,
                  child: Text('$count',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CompletedOrderRow extends StatelessWidget {
  final RestaurantOrder order;
  const _CompletedOrderRow({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${order.id} · ${order.customerName}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                Text('${order.items.length} item(s)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('\$${order.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 14)),
        ],
      ),
    );
  }
}
