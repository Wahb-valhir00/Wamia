import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.addAll([
      AuthInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => print('[API] $o'),
      ),
    ]);
  }

  factory ApiClient() {
    _instance ??= ApiClient._();
    return _instance!;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) => _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) => _dio.post(path, data: data, queryParameters: queryParameters);

  Future<Response> put(
    String path, {
    dynamic data,
  }) => _dio.put(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);

  String _handleError(DioException e) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response!.data['message'];
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
