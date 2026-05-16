import '../storage/secure_storage.dart';
import '../utils/result.dart';
import '../../features/auth/data/models/auth_models.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import 'mock_data.dart';

class MockAuthRepository implements AuthRepository {
  final SecureStorage _storage;
  MockAuthRepository(this._storage);

  @override
  Future<Result<AuthResponse>> login(LoginRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));

    AuthResponse? response;

    // Customer
    if (request.email == mockEmail && request.password == mockPassword) {
      response = AuthResponse(
        token: mockToken,
        role: 'ROLE_CUSTOMER',
        userId: mockUserId,
        name: mockUserName,
      );
    }
    // Restaurant
    else if (request.email == mockRestaurantEmail &&
        request.password == mockRestaurantPassword) {
      response = AuthResponse(
        token: mockRestaurantToken,
        role: 'ROLE_RESTAURANT',
        userId: mockRestaurantUserId,
        name: mockRestaurantName,
      );
    }
    // Driver
    else if (request.email == mockDriverEmail &&
        request.password == mockDriverPassword) {
      response = AuthResponse(
        token: mockDriverToken,
        role: 'ROLE_DRIVER',
        userId: mockDriverUserId,
        name: mockDriverName,
      );
    }

    if (response != null) {
      await _storage.saveAuthData(
        token: response.token,
        role: response.role,
        userId: response.userId,
        userName: response.name,
      );
      return Success(response);
    }
    return const Failure('Invalid email or password');
  }

  @override
  Future<Result<AuthResponse>> register(RegisterRequest request) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const Failure('Registration is disabled in demo mode');
  }

  @override
  Future<void> logout() => _storage.clearAll();

  @override
  Future<bool> isLoggedIn() => _storage.hasToken();

  @override
  Future<String?> getRole() => _storage.getRole();
}
