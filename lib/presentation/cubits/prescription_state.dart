part of 'prescription_cubit.dart';

abstract class PrescriptionState extends Equatable {
  const PrescriptionState();

  @override
  List<Object?> get props => [];
}

class PrescriptionInitial extends PrescriptionState {
  const PrescriptionInitial();
}

class PrescriptionLoading extends PrescriptionState {
  const PrescriptionLoading();
}

class PrescriptionListLoaded extends PrescriptionState {
  final List<PrescriptionModel> prescriptions;
  final bool hasMorePages;

  const PrescriptionListLoaded(
    this.prescriptions, {
    this.hasMorePages = true,
  });

  @override
  List<Object?> get props => [prescriptions, hasMorePages];
}

class PrescriptionError extends PrescriptionState {
  final String message;

  const PrescriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
