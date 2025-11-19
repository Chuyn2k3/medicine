import 'dart:developer' as developer;
import 'dart:io';

import 'package:bloc/bloc.dart';

import '../../data/repositories/medicine_scan_repository.dart';
import 'medicine_scan_state.dart';

class MedicineScanCubit extends Cubit<MedicineScanState> {
  final MedicineScanRepository _repository;

  MedicineScanCubit(this._repository) : super(const MedicineScanInitial());

  Future<void> scanFromImage(File imageFile) async {
    emit(const MedicineScanLoading());
    try {
      final result = await _repository.extractFromImage(imageFile);
      emit(MedicineScanSuccess(result));
    } catch (e, s) {
      developer.log(
        'scanFromImage error',
        name: 'MedicineScanCubit',
        error: e,
        stackTrace: s,
      );
      emit(const MedicineScanFailure(
        'Không nhận diện được hình ảnh. Vui lòng thử lại.',
      ));
    }
  }

  void reset() => emit(const MedicineScanInitial());
}
