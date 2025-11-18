part of 'medicine_cubit.dart';

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {
  const MedicineInitial();
}

class MedicineLoading extends MedicineState {
  const MedicineLoading();
}

class MedicineListLoaded extends MedicineState {
  final List<MedicineModel> medicines;
  final bool hasMorePages;

  const MedicineListLoaded(
    this.medicines, {
    this.hasMorePages = true,
  });

  @override
  List<Object?> get props => [medicines, hasMorePages];
}

class MedicineError extends MedicineState {
  final String message;

  const MedicineError(this.message);

  @override
  List<Object?> get props => [message];
}
