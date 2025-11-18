import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/prescription_model.dart';
import '../../data/repositories/schedule_repository.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleCubit(this._repository) : super(ScheduleInitial());

  Future<void> getScheduleList() async {
    try {
      emit(ScheduleLoading());
      final schedules = await _repository.getScheduleList();
      emit(ScheduleListLoaded(schedules));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> createSchedule(PrescriptionModel schedule) async {
    try {
      emit(ScheduleLoading());
      final newSchedule = await _repository.createSchedule(schedule);
      if (newSchedule != null) {
        emit(ScheduleCreated(newSchedule));
      } else {
        emit(const ScheduleError('Không thể tạo lịch'));
      }
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> updateSchedule(PrescriptionModel updatedSchedule) async {
    if (updatedSchedule.id == null) {
      emit(const ScheduleError('ID lịch không hợp lệ'));
      return;
    }

    try {
      emit(ScheduleLoading());
      final success = await _repository.updateSchedule(
        updatedSchedule.id!,
        updatedSchedule.toJson(), // Gửi toàn bộ object đã sửa
      );

      if (success?.id != null) {
        await getScheduleList(); // Tải lại danh sách
        emit(ScheduleUpdated(updatedSchedule));
      } else {
        emit(const ScheduleError('Cập nhật thất bại'));
      }
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      emit(ScheduleLoading());
      await _repository.deleteSchedule(id);
      emit(ScheduleDeleted());
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }
}
