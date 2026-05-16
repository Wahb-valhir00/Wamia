import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/result.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_models.dart';

abstract class AuthRepository {
  Future<Result<AuthResponse>> login(LoginRequest request);
  Future<Result<AuthResponse>> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<String?> getRole();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._datasource, this._storage);

  @override
  Future<Result<AuthResponse>> login(LoginRequest request) async {
    try {
      final response = await _datasource.login(request);
      await _storage.saveAuthData(
        token: response.token,
        role: response.role,
        userId: response.userId,
        userName: response.name,
      );
      return Success(response);
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<Result<AuthResponse>> register(RegisterRequest request) async {
    try {
      final response = await _datasource.register(request);
      await _storage.saveAuthData(
        token: response.token,
        role: response.role,
        userId: response.userId,
        userName: response.name,
      );
      return Success(response);
    } catch (e) {
      return Failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() => _storage.clearAll();

  @override
  Future<bool> isLoggedIn() => _storage.hasToken();

  @override
  Future<String?> getRole() => _storage.getRole();
}
