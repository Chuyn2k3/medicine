import 'package:json_annotation/json_annotation.dart';

part 'prescription_model.g.dart';

@JsonSerializable()
class PrescriptionModel {
  final String? id;
  final String? name;
  final String? description;
  final String? doctor;
  final List<PrescriptionItem>? medicines;

  PrescriptionModel({
    this.id,
    this.name,
    this.description,
    this.doctor,
    this.medicines,
  });
  PrescriptionModel copyWith({
    String? id,
    String? name,
    String? description,
    String? doctor,
    List<PrescriptionItem>? medicines,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      doctor: doctor ?? this.doctor,
      medicines: medicines ?? this.medicines,
    );
  }

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionModelFromJson(json);
  Map<String, dynamic> toJson() => _$PrescriptionModelToJson(this);
}

@JsonSerializable()
class PrescriptionItem {
  final String? id;
  final String? medicineId;
  final int? quantity;
  final String? time;
  final List<DateTime>? times;
  final String? description;

  PrescriptionItem({
    this.id,
    this.medicineId,
    this.quantity,
    this.time,
    this.times,
    this.description,
  });
  PrescriptionItem copyWith({
    String? id,
    String? medicineId,
    int? quantity,
    String? time,
    List<DateTime>? times,
    String? description,
  }) {
    return PrescriptionItem(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      quantity: quantity ?? this.quantity,
      time: time ?? this.time,
      times: times ?? this.times,
      description: description ?? this.description,
    );
  }

  factory PrescriptionItem.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionItemFromJson(json);
  Map<String, dynamic> toJson() => _$PrescriptionItemToJson(this);
}
