import '../datasources/api_client.dart';
import '../mock_data/mock_schedules.dart';
import '../models/schedule_model.dart';
import '../models/base_response_model.dart';

class ScheduleRepository {
  final ApiClient _apiClient;

  ScheduleRepository(this._apiClient);

  /// Lấy danh sách lịch uống
  Future<List<ScheduleModel>> getScheduleList() async {
    try {
      final BaseResponse<List<ScheduleModel>> response =
          await _apiClient.getScheduleList();
      return response.data ?? [];
    } catch (_) {
      return mockSchedules;
    }
  }

  /// Tạo lịch uống mới
  Future<ScheduleModel?> createSchedule(ScheduleModel schedule) async {
    try {
      final BaseResponse<ScheduleModel> response =
          await _apiClient.createSchedule(schedule);
      final created = response.data;
      if (created != null) mockSchedules.add(created);
      return created;
    } catch (_) {
      mockSchedules.add(schedule);
      return schedule;
    }
  }

  /// Cập nhật lịch uống
  Future<ScheduleModel?> updateSchedule(
      String id, ScheduleModel schedule) async {
    try {
      // final BaseResponse<ScheduleModel> response =
      //     await _apiClient.updateSchedule(id, schedule);
      // final updated = response.data;
      // if (updated != null) {
      //   final index = mockSchedules.indexWhere((s) => s.id == id);
      //   if (index != -1) mockSchedules[index] = updated;
      // }
      // return updated;
    } catch (_) {
      final index = mockSchedules.indexWhere((s) => s.id == id);
      if (index != -1) mockSchedules[index] = schedule;
      return schedule;
    }
  }

  /// Xoá lịch uống
  Future<void> deleteSchedule(String id) async {
    try {
      await _apiClient.deleteSchedule(id);
      mockSchedules.removeWhere((s) => s.id == id);
    } catch (_) {
      mockSchedules.removeWhere((s) => s.id == id);
    }
  }
}
