import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/prescription_model.dart';
import '../../data/repositories/prescription_repository.dart';

part 'prescription_detail_state.dart';

class PrescriptionDetailCubit extends Cubit<PrescriptionDetailState> {
  final PrescriptionRepository _repository;

  PrescriptionDetailCubit(this._repository)
      : super(PrescriptionDetailInitial());

  Future<void> getPrescriptionById(String id) async {
    try {
      emit(PrescriptionDetailLoading());
      final prescription = await _repository.getPrescriptionById(id);
      if (prescription != null) {
        emit(PrescriptionDetailLoaded(prescription));
      } else {
        emit(const PrescriptionDetailError('Đơn thuốc không tìm thấy'));
      }
    } catch (e) {
      emit(PrescriptionDetailError(e.toString()));
    }
  }
}
