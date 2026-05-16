import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/customer/data/datasources/customer_remote_datasource.dart';
import '../../features/customer/data/repositories/customer_repository.dart';
import '../../features/customer/presentation/bloc/cart_bloc.dart';
import '../../features/customer/presentation/bloc/order_bloc.dart';
import '../../features/customer/presentation/bloc/restaurant_bloc.dart';
import '../../features/driver/data/datasources/driver_remote_datasource.dart';
import '../../features/driver/presentation/bloc/driver_bloc.dart';
import '../../features/restaurant/data/datasources/restaurant_remote_datasource.dart';
import '../../features/restaurant/presentation/bloc/restaurant_dashboard_bloc.dart';
import '../config/app_config.dart';
import '../mock/mock_auth_repository.dart';
import '../mock/mock_customer_repository.dart';
import '../mock/mock_driver_datasource.dart';
import '../mock/mock_restaurant_datasource.dart';
import '../network/api_client.dart';
import '../real/api_order_repository.dart';
import '../real/api_restaurant_datasource.dart';
import '../storage/secure_storage.dart';

final sl = GetIt.instance;

void setupDependencies() {
  // Core — always registered
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage.instance);

  if (isMockMode) {
    // MOCK MODE: fully offline, all data comes from MockOrderService in memory
    _registerMock();
  } else {
    // REAL MODE: network calls to Spring Boot at ApiConstants.baseUrl
    _registerReal();
  }

  // Blocs — identical registration regardless of mode;
  // they depend on abstract interfaces, not concrete implementations
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl()));
  sl.registerFactory<RestaurantBloc>(() => RestaurantBloc(sl()));
  sl.registerLazySingleton<CartBloc>(() => CartBloc());
  sl.registerFactory<OrderBloc>(() => OrderBloc(sl()));
  sl.registerFactory<RestaurantDashboardBloc>(() => RestaurantDashboardBloc(sl()));
  sl.registerFactory<DriverBloc>(() => DriverBloc(sl()));
}

// ─── MOCK MODE ────────────────────────────────────────────────────────────────
// No network calls. All order data lives in MockOrderService (ChangeNotifier singleton).
// Switch to real mode by setting isMockMode = false in core/config/app_config.dart.

void _registerMock() {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // MOCK: login matches 3 hardcoded accounts (customer / restaurant / driver)
  sl.registerLazySingleton<AuthRepository>(() => MockAuthRepository(sl()));

  // MOCK: getRestaurants/getMenu from mock_data.dart; placeOrder/getMyOrders via MockOrderService
  sl.registerLazySingleton<CustomerRepository>(() => MockCustomerRepository());

  // MOCK: getOrders/accept/prepare/markReady via MockOrderService; menu via in-memory list
  sl.registerLazySingleton<RestaurantRemoteDatasource>(() => MockRestaurantDatasource());

  // MOCK: getAssignedOrders/pickup/deliver via MockOrderService (not integrated in this slice)
  sl.registerLazySingleton<DriverRemoteDatasource>(() => MockDriverDatasource());
}

// ─── REAL BACKEND MODE ────────────────────────────────────────────────────────
// Integrated in this slice:
//   • Customer: POST /api/orders  (place order)
//   • Customer: GET  /api/orders/my  (list orders)
//   • Restaurant: GET /api/orders/restaurant  (list orders)
//   • Restaurant: PUT /api/orders/{id}/accept|prepare|ready
// Not yet integrated (still safe — blocs/screens unchanged):
//   • Driver pickup/delivery
//   • QR scanning
//   • Notifications

void _registerReal() {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Auth: POST /api/auth/login, POST /api/auth/register
  sl.registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl()));

  // Customer catalog + orders — REAL BACKEND
  // ApiOrderRepository wraps CustomerRemoteDatasourceImpl with clean DioException → Result mapping
  sl.registerLazySingleton<CustomerRemoteDatasource>(() => CustomerRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<CustomerRepository>(() => ApiOrderRepository(sl()));

  // Restaurant orders + menu management — REAL BACKEND
  // ApiRestaurantDatasource uses GET /api/orders/restaurant (fixed endpoint)
  sl.registerLazySingleton<RestaurantRemoteDatasource>(() => ApiRestaurantDatasource(sl()));

  // Driver datasource registered but not yet switched to real integration
  sl.registerLazySingleton<DriverRemoteDatasource>(() => DriverRemoteDatasourceImpl(sl()));
}
