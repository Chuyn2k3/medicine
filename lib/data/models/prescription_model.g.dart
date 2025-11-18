// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrescriptionModel _$PrescriptionModelFromJson(Map<String, dynamic> json) =>
    PrescriptionModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      doctor: json['doctor'] as String?,
      medicines: (json['medicines'] as List<dynamic>?)
          ?.map((e) => PrescriptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PrescriptionModelToJson(PrescriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'doctor': instance.doctor,
      'medicines': instance.medicines,
    };

PrescriptionItem _$PrescriptionItemFromJson(Map<String, dynamic> json) =>
    PrescriptionItem(
      id: json['id'] as String?,
      medicineId: json['medicineId'] as String?,
      quantity: (json['quantity'] as num?)?.toInt(),
      time: json['time'] as String?,
      times: (json['times'] as List<dynamic>?)
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$PrescriptionItemToJson(PrescriptionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicineId': instance.medicineId,
      'quantity': instance.quantity,
      'time': instance.time,
      'times': instance.times?.map((e) => e.toIso8601String()).toList(),
      'description': instance.description,
    };
