import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/customer/presentation/screens/cart_screen.dart';
import '../../features/customer/presentation/screens/home_screen.dart';
import '../../features/customer/presentation/screens/my_orders_screen.dart';
import '../../features/customer/presentation/screens/order_tracking_screen.dart';
import '../../features/customer/presentation/screens/restaurant_detail_screen.dart';
import '../../features/driver/presentation/screens/dashboard_screen.dart';
import '../../features/driver/presentation/screens/qr_scanner_screen.dart';
import '../../features/restaurant/presentation/screens/dashboard_screen.dart';
import '../utils/enums.dart';

GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthBlocListenable(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      if (authState is AuthLoading || authState is AuthInitial) return null;

      if (authState is AuthUnauthenticated) {
        return isOnAuth ? null : '/login';
      }

      if (authState is AuthAuthenticated && isOnAuth) {
        final role = UserRoleX.fromString(authState.authResponse.role);
        switch (role) {
          case UserRole.customer:
            return '/customer/home';
          case UserRole.restaurant:
            return '/restaurant/dashboard';
          case UserRole.driver:
            return '/driver/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Customer routes
      GoRoute(path: '/customer/home', builder: (_, __) => const CustomerHomeScreen()),
      GoRoute(
        path: '/customer/restaurant/:id',
        builder: (_, state) {
          final id = int.parse(state.pathParameters['id']!);
          final name = state.uri.queryParameters['name'] ?? 'Restaurant';
          return RestaurantDetailScreen(restaurantId: id, restaurantName: name);
        },
      ),
      GoRoute(path: '/customer/cart', builder: (_, __) => const CartScreen()),
      GoRoute(path: '/customer/orders', builder: (_, __) => const MyOrdersScreen()),
      GoRoute(
        path: '/customer/order/:id',
        builder: (_, state) => OrderTrackingScreen(
          orderId: int.parse(state.pathParameters['id']!),
        ),
      ),

      // Restaurant routes
      GoRoute(path: '/restaurant/dashboard', builder: (_, __) => const RestaurantDashboardScreen()),

      // Driver routes
      GoRoute(path: '/driver/dashboard', builder: (_, __) => const DriverDashboardScreen()),
      GoRoute(
        path: '/driver/scan-qr',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QrScannerScreen(
            orderId: extra['orderId'] as int,
            type: extra['type'] as String,
          );
        },
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}

class _AuthBlocListenable extends ChangeNotifier {
  _AuthBlocListenable(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
