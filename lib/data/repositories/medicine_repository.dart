import '../datasources/api_client.dart';
import '../mock_data/mock_medicines.dart';
import '../models/medicine_model.dart';
import '../models/base_response_model.dart';

class MedicineRepository {
  final ApiClient _apiClient;

  MedicineRepository(this._apiClient);

  /// Lấy danh sách thuốc (có phân trang)
  Future<List<MedicineModel>> getMedicineList({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final BaseResponse<PaginatedResponse<MedicineModel>> response =
          await _apiClient.getMedicineList(page: page, limit: limit);
      return response.data?.items ?? [];
    } catch (_) {
      // Fallback mock data
      return mockMedicines;
    }
  }

  /// Lấy thuốc theo id
  Future<MedicineModel?> getMedicineById(String id) async {
    try {
      final BaseResponse<MedicineModel> response =
          await _apiClient.getMedicineById(id);
      return response.data;
    } catch (_) {
      // return mockMedicines.firstWhere(
      //   (m) => m.id == id,
      // );
    }
  }

  /// Tìm kiếm thuốc theo tên
  Future<List<MedicineModel>> searchMedicineByName(String name) async {
    try {
      final BaseResponse<PaginatedResponse<MedicineModel>> response =
          await _apiClient.searchMedicineByName(name);
      return response.data?.items ?? [];
    } catch (_) {
      rethrow;
    }
  }
}
