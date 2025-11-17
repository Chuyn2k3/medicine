import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/schedule_model.dart';
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

  Future<void> createSchedule(ScheduleModel schedule) async {
    try {
      emit(ScheduleLoading());
      final newSchedule = await _repository.createSchedule(schedule);
      if (newSchedule != null) {
        emit(ScheduleCreated(newSchedule));
      } else {
        emit(const ScheduleError('Không thể tạo lịch trình'));
      }
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  Future<void> updateSchedule(String id, ScheduleModel schedule) async {
    try {
      emit(ScheduleLoading());
      final updatedSchedule = await _repository.updateSchedule(id, schedule);
      if (updatedSchedule != null) {
        emit(ScheduleUpdated(updatedSchedule));
      } else {
        emit(const ScheduleError('Không thể cập nhật lịch trình'));
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
