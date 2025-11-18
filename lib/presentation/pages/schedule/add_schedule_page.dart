// screens/schedule/add_schedule_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_drug/core/theme/app_colors.dart';
import 'package:medical_drug/data/models/prescription_model.dart';
import '../../cubits/medicine_cubit.dart';
import '../../cubits/schedule_cubit.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({Key? key}) : super(key: key);

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _doctorController = TextEditingController();
  final _descController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  final List<MedicineEntry> _entries = [MedicineEntry()];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MedicineCubit>().getMedicineList());
  }

  void _addMedicine() => setState(() => _entries.add(MedicineEntry()));

  void _removeMedicine(int index) {
    if (_entries.length > 1) {
      setState(() => _entries.removeAt(index));
    }
  }

  void _selectDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (isStart)
          _startDate = date;
        else
          _endDate = date;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_entries.any((e) => e.medicineId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thuốc cho tất cả mục')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final List<PrescriptionItem> items = [];

    // Duyệt từng ngày từ startDate đến endDate
    DateTime currentDay =
        DateTime(_startDate.year, _startDate.month, _startDate.day);
    final endDay = _endDate != null
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day)
        : currentDay;

    while (!currentDay.isAfter(endDay)) {
      final dateStr =
          "${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}";

      for (final entry in _entries) {
        // Tạo danh sách giờ trong ngày hiện tại
        final List<DateTime> dayTimes = entry.times.map((timeStr) {
          final parts = timeStr.split(':');
          return DateTime(
            currentDay.year,
            currentDay.month,
            currentDay.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          ).toUtc();
        }).toList();

        items.add(PrescriptionItem(
          medicineId: entry.medicineId!,
          quantity: entry.quantity,
          time: dateStr, // ← NGÀY: "2025-12-12"
          times: dayTimes, // ← Mảng giờ đầy đủ trong ngày
          description: entry.note.isEmpty ? null : entry.note,
        ));
      }

      currentDay = currentDay.add(const Duration(days: 1));
    }

    final prescription = PrescriptionModel(
      id: null,
      name: _nameController.text.isEmpty
          ? "Lịch uống thuốc mới"
          : _nameController.text,
      description: _descController.text,
      doctor: _doctorController.text,
      medicines: items,
    );

    try {
      await context.read<ScheduleCubit>().createSchedule(prescription);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm lịch uống thuốc thành công!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Lịch Uống Thuốc'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên đơn thuốc (ví dụ: Đơn viêm họng)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Bác sĩ kê đơn (tuỳ chọn)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (tuỳ chọn)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildDateTile('Bắt đầu', _startDate, true)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildDateTile('Kết thúc (tuỳ chọn)',
                          _endDate ?? _startDate, false)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Danh sách thuốc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ..._entries
                  .asMap()
                  .entries
                  .map((e) => _buildMedicineEntry(e.key, e.value))
                  .toList(),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _addMedicine,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm thuốc'),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('HOÀN TẤT – TẠO LỊCH',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime date, bool isStart) {
    return GestureDetector(
      onTap: () => _selectDate(isStart: isStart),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineEntry(int index, MedicineEntry entry) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildMedicineDropdown(entry)),
                if (_entries.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeMedicine(index),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...entry.times
                .asMap()
                .entries
                .map((t) => _buildTimeRow(index, t.key, t.value))
                .toList(),
            TextButton.icon(
              onPressed: () => setState(() => entry.times.add('12:00')),
              icon: const Icon(Icons.add),
              label: const Text('Thêm giờ uống'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: entry.quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Số lượng mỗi lần (viên/viên)'),
              onChanged: (v) => entry.quantity = int.tryParse(v) ?? 1,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: entry.note,
              decoration: const InputDecoration(
                  labelText: 'Ghi chú (sau ăn, trước ngủ...)'),
              onChanged: (v) => entry.note = v,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineDropdown(MedicineEntry entry) {
    return BlocBuilder<MedicineCubit, MedicineState>(
      builder: (context, state) {
        if (state is MedicineListLoaded) {
          return DropdownButtonFormField<String>(
            value: entry.medicineId,
            hint: const Text('Chọn thuốc'),
            isExpanded: true,
            items: state.medicines.map((m) {
              return DropdownMenuItem(
                value: m.id,
                child: Text('${m.name} - ${m.dosage ?? ''}'),
                onTap: () {
                  entry.medicineName = m.name ?? '';
                  entry.dosage = m.dosage ?? '';
                },
              );
            }).toList(),
            onChanged: (v) => setState(() => entry.medicineId = v),
            validator: (v) => v == null ? 'Bắt buộc' : null,
          );
        }
        return const LinearProgressIndicator();
      },
    );
  }

  Widget _buildTimeRow(int entryIndex, int timeIndex, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: int.parse(time.split(':')[0]),
                    minute: int.parse(time.split(':')[1].trim()),
                  ),
                );
                if (t != null) {
                  final newTime =
                      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                  setState(() {
                    _entries[entryIndex].times[timeIndex] = newTime;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(time),
                  ],
                ),
              ),
            ),
          ),
          if (_entries[entryIndex].times.length > 1)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => setState(
                  () => _entries[entryIndex].times.removeAt(timeIndex)),
            ),
        ],
      ),
    );
  }
}

class MedicineEntry {
  String? medicineId;
  String medicineName = '';
  String dosage = '';
  int quantity = 1;
  List<String> times = ['08:00'];
  String note = '';
}
