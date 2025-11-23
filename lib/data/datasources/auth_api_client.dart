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
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: false,
      maxWidth: 200,
    ));
  }

  Future<LoginResponse> login(
    String phone,
    String password, {
    String? fcmToken,
  }) async {
    try {
      final body = <String, dynamic>{
        'phone': phone,
        'password': password,
      };
      if (fcmToken != null && fcmToken.isNotEmpty) {
        body['fcmToken'] = fcmToken; // BE đọc trường này
      }
      final response = await _dio.post(
        '/auth/login',
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw AuthException("Số điện thoại hoặc mật khẩu không chính xác");
      }
      throw AuthException("Login thất bại");
    } on DioError catch (e) {
      if (e.response != null) {
        final msg = e.response?.data['message'] ?? "Lỗi server";
        throw AuthException(msg);
      }
      rethrow;
    }
  }

  Future<UserModel> register(String phone, String password) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'phone': phone,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else if (response.statusCode == 409) {
        throw AuthException("Số điện thoại đã được đăng ký");
      }
      throw AuthException("Đăng ký thất bại");
    } on DioError catch (e) {
      if (e.response != null) {
        final msg = e.response?.data['message'] ?? "Lỗi server";
        throw AuthException(msg);
      }
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
      throw AuthException("Không lấy được thông tin người dùng");
    } on DioError catch (e) {
      throw AuthException("Không lấy được thông tin người dùng: ${e.message}");
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
