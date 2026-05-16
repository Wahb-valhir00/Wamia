import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../customer/presentation/screens/qr_code_screen.dart';
import '../../data/models/restaurant_models.dart';
import '../bloc/restaurant_dashboard_bloc.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    _TabDef('New', OrderStatus.created, Color(0xFF95A5A6)),
    _TabDef('Accepted', OrderStatus.accepted, Color(0xFF3498DB)),
    _TabDef('Preparing', OrderStatus.preparing, Color(0xFFF39C12)),
    _TabDef('Ready', OrderStatus.ready, Color(0xFF27AE60)),
    _TabDef('Done', null, Color(0xFF7F8C8D)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RestaurantDashboardBloc, RestaurantDashboardState>(
      builder: (context, state) {
        List<RestaurantOrder> allOrders = [];
        bool loading = false;
        String? error;

        if (state is RestaurantDashboardLoading) loading = true;
        if (state is RestaurantDashboardError) error = state.message;
        if (state is OrdersLoaded) allOrders = state.orders;

        return Column(
          children: [
            // Tab bar
            Container(
              color: AppColors.surface,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: _tabs.map((t) {
                  final count = _countFor(allOrders, t);
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t.label),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: t.color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Tab views
            Expanded(
              child: loading
                  ? const AppLoading(message: 'Loading orders...')
                  : error != null
                      ? AppErrorWidget(
                          message: error,
                          onRetry: () => context.read<RestaurantDashboardBloc>().add(LoadRestaurantOrders()),
                        )
                      : TabBarView(
                          controller: _tabController,
                          children: _tabs.map((t) {
                            final filtered = _filterOrders(allOrders, t);
                            return _OrderList(orders: filtered, emptyLabel: t.label);
                          }).toList(),
                        ),
            ),
          ],
        );
      },
    );
  }

  int _countFor(List<RestaurantOrder> orders, _TabDef tab) {
    return _filterOrders(orders, tab).length;
  }

  List<RestaurantOrder> _filterOrders(List<RestaurantOrder> orders, _TabDef tab) {
    if (tab.status == null) {
      return orders.where((o) =>
          o.status == OrderStatus.assigned ||
          o.status == OrderStatus.pickedUp ||
          o.status == OrderStatus.delivered).toList();
    }
    return orders.where((o) => o.status == tab.status).toList();
  }
}

class _TabDef {
  final String label;
  final OrderStatus? status;
  final Color color;
  const _TabDef(this.label, this.status, this.color);
}

// ─── Order List ───────────────────────────────────────────────────────────────

class _OrderList extends StatelessWidget {
  final List<RestaurantOrder> orders;
  final String emptyLabel;
  const _OrderList({required this.orders, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('No $emptyLabel orders',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async =>
          context.read<RestaurantDashboardBloc>().add(LoadRestaurantOrders()),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: orders.length,
        itemBuilder: (context, i) => _OrderCard(order: orders[i]),
      ),
    );
  }
}

// ─── Order Card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatefulWidget {
  final RestaurantOrder order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  late Timer _timer;
  late Duration _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = DateTime.now().difference(widget.order.createdAt);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed = DateTime.now().difference(widget.order.createdAt));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Color get _statusColor {
    switch (widget.order.status) {
      case OrderStatus.created: return AppColors.statusCreated;
      case OrderStatus.accepted: return AppColors.statusAccepted;
      case OrderStatus.preparing: return AppColors.statusPreparing;
      case OrderStatus.ready: return AppColors.statusReady;
      default: return AppColors.textSecondary;
    }
  }

  String get _timerText {
    final m = _elapsed.inMinutes;
    final s = _elapsed.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Color get _timerColor {
    if (_elapsed.inMinutes < 10) return AppColors.success;
    if (_elapsed.inMinutes < 20) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _statusColor, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                // Order ID
                Text('#${order.id}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Text(order.status.displayName,
                      style: TextStyle(
                          color: _statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _timerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 13, color: _timerColor),
                      const SizedBox(width: 3),
                      Text(_timerText,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _timerColor,
                              fontFeatures: const [FontFeature.tabularFigures()])),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Customer ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
            child: Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(order.customerName,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),

          const Divider(height: 16, thickness: 0.5, indent: 14, endIndent: 14),

          // ── Items ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text('${item.quantity}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.menuItemName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          if (item.optionNames.isNotEmpty)
                            Text(item.optionNames.join(' · '),
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),

          // ── Total ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text('\$${order.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),

          // ── Action Buttons ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: _ActionButtons(order: order),
          ),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  final RestaurantOrder order;
  const _ActionButtons({required this.order});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RestaurantDashboardBloc>();

    switch (order.status) {
      case OrderStatus.created:
        return Row(
          children: [
            Expanded(
              child: _OutlineBtn(
                label: 'Reject',
                icon: Icons.close_rounded,
                color: AppColors.error,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _SolidBtn(
                label: 'Accept Order',
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                onTap: () => bloc.add(AcceptOrder(order.id)),
              ),
            ),
          ],
        );

      case OrderStatus.accepted:
        return _SolidBtn(
          label: 'Start Preparing',
          icon: Icons.local_fire_department_rounded,
          color: AppColors.statusPreparing,
          onTap: () => bloc.add(PrepareOrder(order.id)),
        );

      case OrderStatus.preparing:
        return _SolidBtn(
          label: 'Mark as Ready ✓',
          icon: Icons.done_all_rounded,
          color: AppColors.statusReady,
          onTap: () => bloc.add(MarkOrderReady(order.id)),
        );

      case OrderStatus.ready:
        return _SolidBtn(
          label: 'Show Pickup QR',
          icon: Icons.qr_code_2_rounded,
          color: AppColors.driverColor,
          onTap: () => _showQr(context),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  void _showQr(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Pickup QR Code',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Driver scans this to confirm pickup',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            QrCodeWidget(data: order.qrData),
            const SizedBox(height: 20),
            Text('Order #${order.id}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Button helpers ───────────────────────────────────────────────────────────

class _SolidBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SolidBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        onPressed: onTap,
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _OutlineBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: onTap,
      ),
    );
  }
}
