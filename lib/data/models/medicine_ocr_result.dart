// medicine_ocr_result.dart
class MedicineOcrResult {
  final String rawResponse;

  const MedicineOcrResult({
    required this.rawResponse,
  });

  factory MedicineOcrResult.fromJson(Map<String, dynamic> json) {
    return MedicineOcrResult(
      rawResponse: json['response'] as String? ?? '',
    );
  }

  @override
  String toString() => 'MedicineOcrResult(rawResponse: $rawResponse)';
}
