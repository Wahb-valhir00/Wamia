import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/mock/mock_order_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/restaurant_dashboard_bloc.dart';
import 'orders_screen.dart';
import 'menu_management_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  const RestaurantDashboardScreen({super.key});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  int _currentTab = 0;
  String _restaurantName = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    context.read<RestaurantDashboardBloc>().add(LoadRestaurantOrders());
    MockOrderService.instance.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    MockOrderService.instance.removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    if (!mounted) return;
    if (_currentTab == 0) {
      context.read<RestaurantDashboardBloc>().add(LoadRestaurantOrders());
    }
    setState(() {}); // refresh stats tab too
  }

  Future<void> _loadUser() async {
    final name = await SecureStorage.instance.getUserName();
    if (mounted) setState(() => _restaurantName = name ?? 'Restaurant');
  }

  void _onTabTap(int i) {
    setState(() => _currentTab = i);
    if (i == 0) context.read<RestaurantDashboardBloc>().add(LoadRestaurantOrders());
    if (i == 1) context.read<RestaurantDashboardBloc>().add(LoadMenu());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RestaurantDashboardBloc, RestaurantDashboardState>(
      listener: (context, state) {
        if (state is OrderActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (state is RestaurantDashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_restaurantName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Text('Wamia Delivery 🛵',
                      style: TextStyle(fontSize: 10, color: Colors.white70)),
                ],
              ),
            ],
          ),
          actions: [
            // Live indicator dot
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('Open', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentTab,
          children: const [
            RestaurantOrdersScreen(),
            MenuManagementScreen(),
            StatsScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentTab,
          onTap: _onTabTap,
        ),
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavDef(Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Orders'),
      _NavDef(Icons.menu_book_rounded, Icons.menu_book_outlined, 'Menu'),
      _NavDef(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Stats'),
      _NavDef(Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          active ? items[i].activeIcon : items[i].icon,
                          color: active ? AppColors.primary : AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                          color: active ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavDef {
  final IconData activeIcon;
  final IconData icon;
  final String label;
  const _NavDef(this.activeIcon, this.icon, this.label);
}
