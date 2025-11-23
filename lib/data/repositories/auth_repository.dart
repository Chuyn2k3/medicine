import '../datasources/auth_api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final AuthApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<LoginResponse> login(
    String phone,
    String password, {
    String? fcmToken,
  }) async {
    try {
      return await _apiClient.login(phone, password, fcmToken: fcmToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> register(String phone, String password) async {
    try {
      return await _apiClient.register(phone, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getCurrentUser(String token) async {
    try {
      return await _apiClient.getCurrentUser(token);
    } catch (e) {
      rethrow;
    }
  }
}
