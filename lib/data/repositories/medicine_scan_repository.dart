import 'dart:io';

import '../datasources/api_client.dart';
import '../models/medicine_ocr_result.dart';

class MedicineScanRepository {
  final ApiClient _apiClient;

  MedicineScanRepository(this._apiClient);

  Future<MedicineOcrResult> extractFromImage(File imageFile) async {
    try {
      final result = await _apiClient.extractMedicineFromImage(imageFile);
      return result;
    } catch (_) {
      rethrow;
    }
  }
}
