import '../models/schedule_model.dart';

final mockSchedules = [
  ScheduleModel(
    id: '1',
    medicineId: '1',
    medicineName: 'Paracetamol 500mg',
    dosage: '500mg',
    times: ['08:00', '14:00', '20:00'],
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
    notes: 'Uống sau ăn',
    isCompleted: false,
  ),
  ScheduleModel(
    id: '2',
    medicineId: '2',
    medicineName: 'Amoxicillin 250mg',
    dosage: '250mg',
    times: ['07:00', '15:00', '23:00'],
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
    notes: 'Kháng sinh - uống đủ liều',
    isCompleted: false,
  ),
  ScheduleModel(
    id: '3',
    medicineId: '3',
    medicineName: 'Vitamin C 1000mg',
    dosage: '1000mg',
    times: ['08:00'],
    startDate: DateTime.now(),
    endDate: null,
    notes: 'Bổ sung hàng ngày',
    isCompleted: false,
  ),
];
