import 'package:json_annotation/json_annotation.dart';

part 'prescription_model.g.dart';

@JsonSerializable()
class PrescriptionModel {
  final String id;
  final String name;
  final String description;
  final String doctor;
  final List<PrescriptionItem> medicines;

  PrescriptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.doctor,
    required this.medicines,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrescriptionModelToJson(this);
}

@JsonSerializable()
class PrescriptionItem {
  final String id;
  final String medicineId;
  final int quantity;
  final String time;
  final List<String> times;
  final String description;

  PrescriptionItem({
    required this.id,
    required this.medicineId,
    required this.quantity,
    required this.time,
    required this.times,
    required this.description,
  });

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionItemFromJson(json);
  Map<String, dynamic> toJson() => _$PrescriptionItemToJson(this);
}
