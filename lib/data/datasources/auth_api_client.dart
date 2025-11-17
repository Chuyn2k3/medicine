import 'package:dio/dio.dart';
import 'package:medical_drug/data/models/user_model.dart';
import '../../core/constants/app_constants.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class AuthApiClient {
  late Dio _dio;

  AuthApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeout),
        contentType: Headers.jsonContentType,
      ),
    );
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: false,
        maxWidth: 200,
      ),
    );
  }

  Future<LoginResponse> login(String phone, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      }
      throw Exception('Login failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> register(String phone, String password) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'phone': phone,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
      throw Exception('Registration failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser(String token) async {
    try {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.get('/auth/me');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
      throw Exception('Failed to fetch user');
    } catch (e) {
      rethrow;
    }
  }
}
