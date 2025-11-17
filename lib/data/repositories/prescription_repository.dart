import '../datasources/api_client.dart';
import '../mock_data/mock_prescriptions.dart';
import '../models/prescription_model.dart';
import '../models/base_response_model.dart';

class PrescriptionRepository {
  final ApiClient _apiClient;

  PrescriptionRepository(this._apiClient);

  /// Lấy danh sách đơn thuốc
  Future<List<PrescriptionModel>> getPrescriptionList() async {
    try {
      final BaseResponse<List<PrescriptionModel>> response =
          await _apiClient.getPrescriptionList();
      return response.data ?? [];
    } catch (_) {
      return mockPrescriptions;
    }
  }

  /// Lấy đơn thuốc theo id
  Future<PrescriptionModel?> getPrescriptionById(String id) async {
    try {
      final BaseResponse<PrescriptionModel> response =
          await _apiClient.getPrescriptionById(id);
      return response.data;
    } catch (_) {
      return mockPrescriptions.firstWhere(
        (p) => p.id == id,
      );
    }
  }
}
