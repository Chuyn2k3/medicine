import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:medical_drug/services/token_manager.dart';
import '../../core/constants/app_constants.dart';
import '../models/base_response_model.dart';
import '../models/chat_message_model.dart';
import '../models/medicine_model.dart';
import '../models/prescription_model.dart';
import '../models/schedule_model.dart';

class ApiClient {
  late Dio _dio;
  final TokenManager? _tokenManager;

  ApiClient({TokenManager? tokenManager}) : _tokenManager = tokenManager {
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
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenManager?.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          _logRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) {
          _logError(error);
          return handler.next(error);
        },
      ),
    );
  }

  // ------------------- Logging -------------------
  void _logRequest(RequestOptions options) {
    developer.log(
      '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔵 API REQUEST
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Method: ${options.method}
Path: ${options.path}
Full URL: ${options.uri}

Headers:
${_formatHeaders(options.headers)}

Query Parameters:
${options.queryParameters.isEmpty ? 'None' : _formatMap(options.queryParameters)}

Body/Data:
${options.data is FormData ? 'FormData' : _formatJson(options.data)}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''',
      name: 'ApiClient',
      level: 800,
    );
  }

  void _logResponse(Response response) {
    developer.log(
      '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🟢 API RESPONSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status Code: ${response.statusCode}
Path: ${response.requestOptions.path}

Response Headers:
${_formatHeaders(response.headers.map)}

Response Body:
${_formatJson(response.data)}

Time: ${DateTime.now()}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''',
      name: 'ApiClient',
      level: 800,
    );
  }

  void _logError(DioException error) {
    developer.log(
      '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 API ERROR
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Error Type: ${error.type}
Status Code: ${error.response?.statusCode ?? 'N/A'}
Path: ${error.requestOptions.path}
Message: ${error.message}

Error Details:
${error.error}

Response:
${_formatJson(error.response?.data)}

Time: ${DateTime.now()}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''',
      name: 'ApiClient',
      level: 1000,
    );
  }

  String _formatHeaders(Map<String, dynamic> headers) {
    if (headers.isEmpty) return 'None';
    return headers.entries.map((e) => '  ${e.key}: ${e.value}').join('\n');
  }

  String _formatMap(Map<String, dynamic> map) {
    return map.entries.map((e) => '  ${e.key}: ${e.value}').join('\n');
  }

  String _formatJson(dynamic data) {
    if (data == null) return 'null';
    if (data is String) return data;
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    return data.toString();
  }

  // ------------------- User APIs -------------------
  Future<BaseResponse<Map<String, dynamic>>> register(
      String phone, String password) async {
    final response = await _dio.post(
      '/auth/register',
      data: {'phone': phone, 'password': password},
    );
    return BaseResponse.fromJson(
      response.data,
      (json) => Map<String, dynamic>.from(json as Map),
    );
  }

  Future<BaseResponse<Map<String, dynamic>>> login(
      String phone, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );
    return BaseResponse.fromJson(
      response.data,
      (json) => Map<String, dynamic>.from(json as Map),
    );
  }

  Future<BaseResponse<Map<String, dynamic>>> getMe() async {
    final response = await _dio.get('/auth/me');
    return BaseResponse.fromJson(
      response.data,
      (json) => Map<String, dynamic>.from(json as Map),
    );
  }

  // ------------------- Medicine APIs -------------------
  Future<BaseResponse<PaginatedResponse<MedicineModel>>> getMedicineList({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dio.get('/medicines', queryParameters: {
      'page': page,
      'limit': limit,
    });

    return BaseResponse.fromJson(
      response.data,
      (json) => PaginatedResponse<MedicineModel>.fromJson(
        json as Map<String, dynamic>,
        (item) => MedicineModel.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  Future<BaseResponse<MedicineModel>> getMedicineById(String id) async {
    final response = await _dio.get('/medicines/$id');
    return BaseResponse.fromJson(
      response.data,
      (json) => MedicineModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<PaginatedResponse<MedicineModel>>> searchMedicineByName(
      String name) async {
    final response = await _dio.get('/medicines/by-name/$name');
    return BaseResponse.fromJson(
      response.data,
      (json) => PaginatedResponse<MedicineModel>.fromJson(
        json as Map<String, dynamic>,
        (item) => MedicineModel.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  // ------------------- Prescription APIs -------------------
  Future<BaseResponse<List<PrescriptionModel>>> getPrescriptionList() async {
    final response = await _dio.get('/prescriptions');
    return BaseResponse.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) =>
              PrescriptionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<BaseResponse<PrescriptionModel>> getPrescriptionById(String id) async {
    final response = await _dio.get('/prescriptions/$id');
    return BaseResponse.fromJson(
      response.data,
      (json) => PrescriptionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // ------------------- Schedule APIs -------------------
  Future<BaseResponse<List<ScheduleModel>>> getScheduleList() async {
    final response = await _dio.get('/schedules');
    return BaseResponse.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) => ScheduleModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<BaseResponse<ScheduleModel>> createSchedule(
      ScheduleModel schedule) async {
    final response = await _dio.post('/schedules', data: schedule.toJson());
    return BaseResponse.fromJson(
      response.data,
      (json) => ScheduleModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<void>> deleteSchedule(String id) async {
    final response = await _dio.delete('/schedules/$id');
    return BaseResponse.fromJson(response.data, (_) => null);
  }

  // ------------------- Chat APIs -------------------
  Future<BaseResponse<ChatMessageModel>> sendChatMessage(String message,
      {bool isMedicationQuestion = false}) async {
    final endpoint = isMedicationQuestion
        ? '/assistant/medication-instruction'
        : '/assistant/chat';
    final response = await _dio.post(endpoint, data: {'message': message});
    return BaseResponse.fromJson(
      response.data,
      (json) => ChatMessageModel.fromJson(json as Map<String, dynamic>),
    );
  }

  Future<BaseResponse<List<ChatMessageModel>>> getChatHistory() async {
    final response = await _dio.get('/chat/history');
    return BaseResponse.fromJson(
      response.data,
      (json) => (json as List)
          .map(
              (item) => ChatMessageModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
