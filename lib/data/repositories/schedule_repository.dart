import '../datasources/api_client.dart';
import '../models/prescription_model.dart';
import '../models/base_response_model.dart';

class ScheduleRepository {
  final ApiClient _apiClient;

  ScheduleRepository(this._apiClient);

  /// Lấy danh sách lịch uống thuốc theo user
  Future<List<PrescriptionModel>> getScheduleList() async {
    final response = await _apiClient.getScheduleList();
    return response.data ?? [];
  }

  Future<PrescriptionModel?> createSchedule(PrescriptionModel schedule) async {
    final response = await _apiClient.createSchedule(schedule);
    return response.data;
  }

  Future<PrescriptionModel?> updateSchedule(
      String id, Map<String, dynamic> body) async {
    final response = await _apiClient.updateSchedule(id, body);
    return response.data;
  }

  Future<void> deleteSchedule(String id) async {
    await _apiClient.deleteSchedule(id);
  }
}
