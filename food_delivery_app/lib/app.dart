import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/customer/presentation/bloc/cart_bloc.dart';
import 'features/customer/presentation/bloc/order_bloc.dart';
import 'features/customer/presentation/bloc/restaurant_bloc.dart';
import 'features/driver/presentation/bloc/driver_bloc.dart';
import 'features/restaurant/presentation/bloc/restaurant_dashboard_bloc.dart';

class FoodDeliveryApp extends StatefulWidget {
  const FoodDeliveryApp({super.key});

  @override
  State<FoodDeliveryApp> createState() => _FoodDeliveryAppState();
}

class _FoodDeliveryAppState extends State<FoodDeliveryApp> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>();
    _authBloc.add(const AuthCheckRequested());
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authBloc),
        BlocProvider<RestaurantBloc>(create: (_) => sl()),
        BlocProvider<CartBloc>(create: (_) => sl()),
        BlocProvider<OrderBloc>(create: (_) => sl()),
        BlocProvider<RestaurantDashboardBloc>(create: (_) => sl()),
        BlocProvider<DriverBloc>(create: (_) => sl()),
      ],
      child: _AppView(authBloc: _authBloc),
    );
  }
}

class _AppView extends StatefulWidget {
  final AuthBloc authBloc;
  const _AppView({required this.authBloc});

  @override
  State<_AppView> createState() => _AppViewState();
}

class _AppViewState extends State<_AppView> {
  late final _router = buildAppRouter(widget.authBloc);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Wamia Delivery',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      routerConfig: _router,
      builder: (context, child) => child ?? const SizedBox(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
    );
  }
}
