import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:medical_drug/services/fcm_service.dart';
import 'package:medical_drug/services/token_manager.dart';
import '../../data/datasources/auth_api_client.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../main.dart';
import '../pages/login_page.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final TokenManager _tokenManager;
  final FcmService _fcmService;

  AuthCubit(this._authRepository, this._tokenManager, this._fcmService)
      : super(const AuthInitial());

  String _normalizePhone(String phone) {
    phone = phone.replaceAll(' ', '');
    if (phone.startsWith('0')) return '+84${phone.substring(1)}';
    if (phone.startsWith('+84')) return phone;
    if (phone.startsWith('84')) return '+$phone';
    return phone;
  }

  Future<void> login(String phone, String password) async {
    try {
      emit(const AuthLoading());
      final normalizedPhone = _normalizePhone(
          phone); // Lấy FCM token (đã được init khi vào app, nếu chưa sẽ lấy từ Firebase)
      final String? fcmToken = await _fcmService.getFcmToken();
      final response = await _authRepository.login(normalizedPhone, password,
          fcmToken: fcmToken);

      await _tokenManager.saveToken(response.accessToken);
      final user = await _authRepository.getCurrentUser(response.accessToken);
      await _tokenManager.saveUserId(user.id);

      emit(AuthAuthenticated(user));
    } catch (e) {
      final msg = (e as AuthException).message;
      emit(AuthError(msg));
    }
  }

  Future<void> register(String phone, String password) async {
    try {
      emit(const AuthLoading());
      final normalizedPhone = _normalizePhone(phone);
      await _authRepository.register(normalizedPhone, password);

      // Chỉ phát state đăng ký thành công, chưa login
      emit(AuthRegistered(phone: normalizedPhone, password: password));
    } catch (e) {
      final msg = (e as AuthException).message;
      emit(AuthError(msg));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      emit(const AuthLoading());
      final token = await _tokenManager.getToken();

      if (token == null || token.isEmpty) {
        emit(const AuthUnauthenticated());
      } else {
        final user = await _authRepository.getCurrentUser(token);
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    try {
      await _tokenManager.clear();
      emit(const AuthUnauthenticated());
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      final msg = (e as AuthException).message;
      emit(AuthError(msg));
    }
  }
}
