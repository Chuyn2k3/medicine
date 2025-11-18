import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medical_drug/core/theme/app_colors.dart';
import 'package:medical_drug/data/models/prescription_model.dart';
import '../../cubits/medicine_cubit.dart';
import '../../cubits/schedule_cubit.dart';
import 'add_schedule_page.dart';

class EditSchedulePage extends StatefulWidget {
  final PrescriptionModel schedule;

  const EditSchedulePage({Key? key, required this.schedule}) : super(key: key);

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _doctorController;
  late final TextEditingController _descController;

  late DateTime _startDate;
  DateTime? _endDate;
  late List<MedicineEntry> _entries;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.schedule.name ?? '');
    _doctorController =
        TextEditingController(text: widget.schedule.doctor ?? '');
    _descController =
        TextEditingController(text: widget.schedule.description ?? '');

    final times =
        widget.schedule.medicines!.map((e) => e.time!).toSet().toList();
    times.sort();

    _startDate = DateTime.parse(times.first);
    _endDate = times.length > 1 ? DateTime.parse(times.last) : null;

    // nhóm thuốc
    final Map<String, PrescriptionItem> uniqueEntries = {};
    for (var item in widget.schedule.medicines!) {
      final key =
          '${item.medicineId}_${item.times?.map((t) => t.toIso8601String()).join(',')}';
      uniqueEntries[key] = item;
    }

    _entries = uniqueEntries.values.map((item) {
      final timesStr = item.times!
          .map((t) => DateFormat('HH:mm').format(t.toLocal()))
          .toList()
        ..sort();

      return MedicineEntry()
        ..medicineId = item.medicineId
        ..quantity = item.quantity ?? 1
        ..note = item.description ?? ''
        ..times = timesStr;
    }).toList();

    if (_entries.isEmpty) {
      _entries.add(MedicineEntry()..times = ['08:00']);
    }

    Future.microtask(() => context.read<MedicineCubit>().getMedicineList());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doctorController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _addMedicine() =>
      setState(() => _entries.add(MedicineEntry()..times = ['12:00']));

  void _removeMedicine(int index) {
    if (_entries.length > 1) {
      setState(() => _entries.removeAt(index));
    }
  }

  void _selectDate({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2030),
    );
    if (date != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_entries.any((e) => e.medicineId == null)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thuốc cho tất cả mục')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final List<PrescriptionItem> newItems = [];
    DateTime currentDay =
        DateTime(_startDate.year, _startDate.month, _startDate.day);
    final endDay = _endDate != null
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day)
        : currentDay;

    while (!currentDay.isAfter(endDay)) {
      final dateStr = DateFormat('yyyy-MM-dd').format(currentDay);

      for (final entry in _entries) {
        final dayTimes = entry.times.map((timeStr) {
          final parts = timeStr.split(':');
          return DateTime(currentDay.year, currentDay.month, currentDay.day,
                  int.parse(parts[0]), int.parse(parts[1]))
              .toUtc();
        }).toList();

        newItems.add(
          PrescriptionItem(
            medicineId: entry.medicineId!,
            quantity: entry.quantity,
            time: dateStr,
            times: dayTimes,
            description: entry.note.isEmpty ? null : entry.note,
          ),
        );
      }

      currentDay = currentDay.add(const Duration(days: 1));
    }

    final updatedSchedule = widget.schedule.copyWith(
      name: _nameController.text.trim().isEmpty
          ? 'Lịch uống thuốc'
          : _nameController.text.trim(),
      doctor: _doctorController.text.trim(),
      description: _descController.text.trim(),
      medicines: newItems,
    );

    // Gọi bloc mà không await
    context.read<ScheduleCubit>().updateSchedule(updatedSchedule);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleCubit, ScheduleState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state is ScheduleUpdated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật lịch thành công!'),
                backgroundColor: AppColors.primary,
              ),
            );
            Navigator.pop(context, true);
          });
        }

        if (state is ScheduleError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() => _isSubmitting = false);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh Sửa Lịch Uống Thuốc'),
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
                _textField(_nameController, 'Tên đơn thuốc'),
                const SizedBox(height: 16),
                _textField(_doctorController, 'Bác sĩ kê đơn (tuỳ chọn)'),
                const SizedBox(height: 16),
                _textField(_descController, 'Mô tả (tuỳ chọn)', maxLines: 3),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                        child: _buildDateTile('Bắt đầu', _startDate, true)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildDateTile('Kết thúc (tuỳ chọn)',
                            _endDate ?? _startDate, false)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Danh sách thuốc',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._entries
                    .asMap()
                    .entries
                    .map((e) => _buildMedicineEntry(e.key, e.value)),
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
                        : const Text('CẬP NHẬT LỊCH',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField(TextEditingController c, String label, {int maxLines = 1}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
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
            Text(DateFormat('dd/MM/yyyy').format(date),
                style: const TextStyle(fontWeight: FontWeight.bold)),
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
                .map((t) => _buildTimeRow(index, t.key, t.value)),
            TextButton.icon(
              onPressed: () => setState(() => entry.times.add('12:00')),
              icon: const Icon(Icons.add),
              label: const Text('Thêm giờ uống'),
            ),
            TextFormField(
              initialValue: entry.quantity.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số lượng mỗi lần'),
              onChanged: (v) => entry.quantity = int.tryParse(v) ?? 1,
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: entry.note,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
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
            validator: (v) => v == null ? 'Bắt buộc chọn thuốc' : null,
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
                    minute: int.parse(time.split(':')[1]),
                  ),
                );
                if (t != null && mounted) {
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
