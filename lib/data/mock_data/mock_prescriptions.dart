import 'package:medical_drug/data/models/prescription_model.dart';

final mockPrescriptions = [
  PrescriptionModel(
    id: '1',
    name: 'Đơn thuốc điều trị cảm sốt',
    description: 'Điều trị các triệu chứng sốt, đau đầu',
    doctor: 'TS. Trần Văn B',
    medicines: [
      PrescriptionItem(
        id: '1',
        medicineId: '1',
        quantity: 10,
        time: '4-6 giờ/lần',
        times: ['08:00', '12:00', '16:00', '20:00'],
        description: 'Uống 1-2 viên mỗi lần, tối đa 3 ngày',
      ),
      PrescriptionItem(
        id: '2',
        medicineId: '2',
        quantity: 12,
        time: '8 giờ/lần',
        times: ['08:00', '16:00', '00:00'],
        description: 'Uống 1 viên mỗi lần, 7 ngày liên tiếp',
      ),
    ],
  ),
  PrescriptionModel(
    id: '2',
    name: 'Đơn bổ sung Vitamin C',
    description: 'Tăng cường sức đề kháng',
    doctor: 'TS. Lê Văn D',
    medicines: [
      PrescriptionItem(
        id: '3',
        medicineId: '3',
        quantity: 30,
        time: 'Mỗi sáng',
        times: ['08:00'],
        description: 'Uống 1 viên mỗi sáng, 30 ngày',
      ),
    ],
  ),
];
