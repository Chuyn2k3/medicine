part of 'medicine_detail_cubit.dart';

abstract class MedicineDetailState extends Equatable {
  const MedicineDetailState();

  @override
  List<Object?> get props => [];
}

class MedicineDetailInitial extends MedicineDetailState {}

class MedicineDetailLoading extends MedicineDetailState {}

class MedicineDetailLoaded extends MedicineDetailState {
  final MedicineModel medicine;
  const MedicineDetailLoaded(this.medicine);

  @override
  List<Object?> get props => [medicine];
}

class MedicineDetailError extends MedicineDetailState {
  final String message;
  const MedicineDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
