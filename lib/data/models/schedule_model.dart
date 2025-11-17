import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable()
class ScheduleModel {
  final String id;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final List<String> times; // e.g., ["08:00", "14:00", "20:00"]
  final DateTime startDate;
  final DateTime? endDate;
  final String? notes;
  final bool isCompleted;

  ScheduleModel({
    required this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.times,
    required this.startDate,
    this.endDate,
    this.notes,
    this.isCompleted = false,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);
}
