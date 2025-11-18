part of 'prescription_detail_cubit.dart';

abstract class PrescriptionDetailState extends Equatable {
  const PrescriptionDetailState();

  @override
  List<Object?> get props => [];
}

class PrescriptionDetailInitial extends PrescriptionDetailState {}

class PrescriptionDetailLoading extends PrescriptionDetailState {}

class PrescriptionDetailLoaded extends PrescriptionDetailState {
  final PrescriptionModel prescription;

  const PrescriptionDetailLoaded(this.prescription);

  @override
  List<Object?> get props => [prescription];
}

class PrescriptionDetailError extends PrescriptionDetailState {
  final String message;

  const PrescriptionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
