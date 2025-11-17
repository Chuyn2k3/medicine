import 'package:json_annotation/json_annotation.dart';

part 'medicine_model.g.dart';

@JsonSerializable()
class MedicineModel {
  final String id;
  final String? name;
  final String? dosage;
  final String? description;
  final String? userManual;
  final int? quantity;

  MedicineModel({
    required this.id,
    this.name,
    this.dosage,
    this.description,
    this.userManual,
    this.quantity,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) =>
      _$MedicineModelFromJson(json);
  Map<String, dynamic> toJson() => _$MedicineModelToJson(this);
}
