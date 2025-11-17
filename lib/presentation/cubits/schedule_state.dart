part of 'schedule_cubit.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleListLoaded extends ScheduleState {
  final List<ScheduleModel> schedules;

  const ScheduleListLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleCreated extends ScheduleState {
  final ScheduleModel schedule;

  const ScheduleCreated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleUpdated extends ScheduleState {
  final ScheduleModel schedule;

  const ScheduleUpdated(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleDeleted extends ScheduleState {
  const ScheduleDeleted();
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
