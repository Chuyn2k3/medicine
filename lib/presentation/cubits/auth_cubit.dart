import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:medical_drug/services/token_manager.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final TokenManager _tokenManager;

  AuthCubit(this._authRepository, this._tokenManager) : super(AuthInitial());

  Future<void> login(String phone, String password) async {
    try {
      emit(AuthLoading());
      final response = await _authRepository.login(phone, password);

      // Save token
      await _tokenManager.saveToken(response.accessToken);

      // Fetch current user
      final user = await _authRepository.getCurrentUser(response.accessToken);
      await _tokenManager.saveUserId(user.id);

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> register(String phone, String password) async {
    try {
      emit(AuthLoading());
      final user = await _authRepository.register(phone, password);

      // Auto-login after registration
      final loginResponse = await _authRepository.login(phone, password);
      await _tokenManager.saveToken(loginResponse.accessToken);
      await _tokenManager.saveUserId(user.id);

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      emit(AuthLoading());
      final token = await _tokenManager.getToken();

      if (token == null || token.isEmpty) {
        emit(AuthUnauthenticated());
      } else {
        final user = await _authRepository.getCurrentUser(token);
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    try {
      await _tokenManager.clear();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
