part of 'schedule_cubit.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleListLoaded extends ScheduleState {
  final List<PrescriptionModel> schedules;
  const ScheduleListLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleCreated extends ScheduleState {
  final PrescriptionModel schedule;
  const ScheduleCreated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleUpdated extends ScheduleState {
  final PrescriptionModel schedule;
  const ScheduleUpdated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleDeleted extends ScheduleState {}

class ScheduleError extends ScheduleState {
  final String message;
  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
