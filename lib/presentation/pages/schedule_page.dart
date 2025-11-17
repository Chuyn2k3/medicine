import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_drug/services/mqtt_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/schedule_model.dart';
import '../cubits/schedule_cubit.dart';
import '../widgets/schedule_item.dart';
import 'add_schedule_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late MqttManager _mqttManager;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _mqttManager = MqttManager();
    Future.microtask(
      () => context.read<ScheduleCubit>().getScheduleList(),
    );
  }

  void _navigateToAddSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddSchedulePage()),
    ).then((_) {
      context.read<ScheduleCubit>().getScheduleList();
    });
  }

  void _sendMedicineControlViaMqtt(ScheduleModel schedule) async {
    final connected = await _mqttManager.connect();
    if (connected) {
      final medicineControl = {
        schedule.medicineName: schedule.times.length,
      };
      await _mqttManager.publishMedicineControl(medicineControl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đã gửi ${schedule.medicineName} đến thiết bị',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể kết nối với thiết bị'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<ScheduleModel> _getSchedulesForDate(List<ScheduleModel> allSchedules) {
    return allSchedules
        .where((schedule) =>
            schedule.startDate.year == _selectedDate.year &&
            schedule.startDate.month == _selectedDate.month &&
            schedule.startDate.day == _selectedDate.day)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Uống Thuốc'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddSchedule,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.accent.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2099),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ScheduleCubit, ScheduleState>(
              builder: (context, state) {
                if (state is ScheduleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ScheduleListLoaded) {
                  final schedules = _getSchedulesForDate(state.schedules);
                  if (schedules.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key(schedules[index].id),
                        onDismissed: (_) {
                          context
                              .read<ScheduleCubit>()
                              .deleteSchedule(schedules[index].id);
                        },
                        child: Column(
                          children: [
                            ScheduleItem(
                              schedule: schedules[index],
                              onDelete: () {
                                context
                                    .read<ScheduleCubit>()
                                    .deleteSchedule(schedules[index].id);
                              },
                              onSendToDevice: () {
                                _sendMedicineControlViaMqtt(
                                  schedules[index],
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      );
                    },
                  );
                }

                if (state is ScheduleError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${state.message}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ScheduleCubit>().getScheduleList(),
                          child: const Text('Thử Lại'),
                        ),
                      ],
                    ),
                  );
                }

                return _buildEmptyState(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 64,
            color: AppColors.grey300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch uống thuốc',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey400,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddSchedule,
            icon: const Icon(Icons.add),
            label: const Text('Thêm Lịch'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mqttManager.disconnect();
    super.dispose();
  }
}
