import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:medical_drug/data/models/medicine_ocr_result.dart';
import 'package:medical_drug/services/token_manager.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../../core/constants/app_constants.dart';
import '../models/base_response_model.dart';
import '../models/chat_message_model.dart';
import '../models/medicine_model.dart';
import '../models/prescription_model.dart';

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
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenManager?.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // _logRequest(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // _logResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) {
          // _logError(error);
          return handler.next(error);
        },
      ),
    );
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

  Future<BaseResponse<MedicineModel>> searchMedicineByName(String name) async {
    final response = await _dio.get('/medicines/by-name/$name');
    return BaseResponse.fromJson(
      response.data,
      (json) => MedicineModel.fromJson(json as Map<String, dynamic>),
    );
  }

  // ------------------- Medicine OCR APIs -------------------
  Future<MedicineOcrResult> extractMedicineFromImage(File imageFile) async {
    final fileName = imageFile.path.split('/').last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    // Ở đây dùng full URL nên sẽ bỏ qua baseUrl
    final response = await _dio.post(
      'https://hydrogenous-captiously-jeanie.ngrok-free.dev/extract_medicine',
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        contentType: 'multipart/form-data',
      ),
    );

    // response.data dạng: { "response": "..." }
    return MedicineOcrResult.fromJson(
      Map<String, dynamic>.from(response.data as Map),
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
  /// Lấy danh sách lịch uống theo user
  Future<BaseResponse<List<PrescriptionModel>>> getScheduleList() async {
    final response = await _dio.get('/prescriptions'); // API trả prescription
    return BaseResponse.fromJson(
      response.data,
      (json) => (json as List)
          .map((item) =>
              PrescriptionModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Tạo lịch mới
  Future<BaseResponse<PrescriptionModel>> createSchedule(
      PrescriptionModel schedule) async {
    final response = await _dio.post('/prescriptions', data: schedule.toJson());
    return BaseResponse.fromJson(
      response.data,
      (json) => PrescriptionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Cập nhật lịch
  Future<BaseResponse<PrescriptionModel>> updateSchedule(
      String id, Map<String, dynamic> body) async {
    final response = await _dio.patch('/prescriptions/$id', data: body);
    return BaseResponse.fromJson(
      response.data,
      (json) => PrescriptionModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Xoá lịch
  Future<BaseResponse<void>> deleteSchedule(String id) async {
    final response = await _dio.delete('/prescriptions/$id');
    return BaseResponse.fromJson(response.data, (_) {});
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
