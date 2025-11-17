import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/schedule_model.dart';
import '../cubits/medicine_cubit.dart';
import '../cubits/schedule_cubit.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({Key? key}) : super(key: key);

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedMedicineId;
  String _selectedMedicineName = '';
  String _medicineDosage = '';
  List<String> _times = ['08:00'];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _notes = '';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<MedicineCubit>().getMedicineList(isRefresh: true),
    );
  }

  void _addTime() {
    setState(() => _times.add('12:00'));
  }

  void _removeTime(int index) {
    if (_times.length > 1) {
      setState(() => _times.removeAt(index));
    }
  }

  void _selectTime(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_times[index].split(':')[0]),
        minute: int.parse(_times[index].split(':')[1]),
      ),
    );
    if (time != null) {
      setState(() {
        _times[index] =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2099),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  void _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2099),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _selectedMedicineId != null) {
      setState(() => _isSubmitting = true);

      final schedule = ScheduleModel(
        id: const Uuid().v4(),
        medicineId: _selectedMedicineId!,
        medicineName: _selectedMedicineName,
        dosage: _medicineDosage,
        times: _times,
        startDate: _startDate,
        endDate: _endDate,
        notes: _notes.isEmpty ? null : _notes,
        isCompleted: false,
      );

      context.read<ScheduleCubit>().createSchedule(schedule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thêm lịch uống thuốc'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      }
    } else if (_selectedMedicineId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn thuốc'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Lịch Uống Thuốc'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn Thuốc',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                BlocBuilder<MedicineCubit, MedicineState>(
                  builder: (context, state) {
                    if (state is MedicineLoading) {
                      return const CircularProgressIndicator();
                    }
                    if (state is MedicineListLoaded) {
                      final medicines = state.medicines;
                      return DropdownButtonFormField<String>(
                        value: _selectedMedicineId,
                        decoration: InputDecoration(
                          hintText: 'Chọn thuốc',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        items: medicines.map((medicine) {
                          return DropdownMenuItem(
                            value: medicine.id,
                            child: Text(medicine.name ?? "-"),
                            onTap: () {
                              _selectedMedicineName = medicine.name ?? "-";
                              _medicineDosage = medicine.dosage ?? "-";
                            },
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedMedicineId = value);
                        },
                        validator: (value) {
                          if (value == null) return 'Vui lòng chọn thuốc';
                          return null;
                        },
                      );
                    }
                    if (state is MedicineError) {
                      return Text('Lỗi: ${state.message}');
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  'Thời gian uống',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ..._times.asMap().entries.map((entry) {
                  int index = entry.key;
                  String time = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectTime(index),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.grey300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, size: 18),
                                  const SizedBox(width: 8),
                                  Text(time),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon:
                              const Icon(Icons.delete, color: AppColors.error),
                          onPressed: _times.length > 1
                              ? () => _removeTime(index)
                              : null,
                        ),
                      ],
                    ),
                  );
                }).toList(),
                ElevatedButton.icon(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm Thời Gian'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ngày Bắt Đầu',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ngày Kết Thúc (Tùy chọn)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _selectEndDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'Chọn ngày kết thúc',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ghi Chú',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ghi chú thêm...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (value) => _notes = value,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    minimumSize: const Size(double.infinity, 50),
                    disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.white),
                          ),
                        )
                      : const Text('Thêm Lịch'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
