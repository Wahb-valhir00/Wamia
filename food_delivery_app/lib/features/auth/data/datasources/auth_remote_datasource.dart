import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _client;
  AuthRemoteDatasourceImpl(this._client);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final res = await _client.post(
        ApiConstants.login,
        data: request.toJson(),
      );
      return AuthResponse.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final res = await _client.post(
        ApiConstants.register,
        data: request.toJson(),
      );
      return AuthResponse.fromJson(res.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final msg = (e.response?.data is Map)
        ? e.response?.data['message'] ?? 'An error occurred'
        : 'An error occurred';
    return Exception(msg);
  }
}
