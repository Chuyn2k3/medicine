import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/medicine_model.dart';
import '../../data/repositories/medicine_repository.dart';

part 'medicine_detail_state.dart';

class MedicineDetailCubit extends Cubit<MedicineDetailState> {
  final MedicineRepository _repository;

  MedicineDetailCubit(this._repository) : super(MedicineDetailInitial());

  Future<void> getMedicineById(String id) async {
    try {
      emit(MedicineDetailLoading());
      final medicine = await _repository.getMedicineById(id);
      if (medicine != null) {
        emit(MedicineDetailLoaded(medicine));
      } else {
        emit(const MedicineDetailError('Thuốc không tìm thấy'));
      }
    } catch (e) {
      emit(MedicineDetailError(e.toString()));
    }
  }
}
