import 'package:equatable/equatable.dart';
import '../../data/models/medicine_ocr_result.dart';

abstract class MedicineScanState extends Equatable {
  const MedicineScanState();

  @override
  List<Object?> get props => [];
}

class MedicineScanInitial extends MedicineScanState {
  const MedicineScanInitial();
}

class MedicineScanLoading extends MedicineScanState {
  const MedicineScanLoading();
}

class MedicineScanSuccess extends MedicineScanState {
  final MedicineOcrResult result;

  const MedicineScanSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class MedicineScanFailure extends MedicineScanState {
  final String message;

  const MedicineScanFailure(this.message);

  @override
  List<Object?> get props => [message];
}
