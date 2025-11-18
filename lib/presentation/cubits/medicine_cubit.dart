import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/medicine_model.dart';
import '../../data/repositories/medicine_repository.dart';

part 'medicine_state.dart';

class MedicineCubit extends Cubit<MedicineState> {
  final MedicineRepository _repository;

  int _currentPage = 1;
  final int _pageSize = 10;
  List<MedicineModel> _allMedicines = [];
  bool _hasMorePages = true;

  MedicineCubit(this._repository) : super(const MedicineInitial());

  Future<void> getMedicineList({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
        _allMedicines = [];
        _hasMorePages = true;
        emit(const MedicineLoading());
      } else if (!_hasMorePages) {
        return; // No more pages to load
      }

      final medicines = await _repository.getMedicineList(
        page: _currentPage,
        limit: _pageSize,
      );

      if (medicines.isEmpty) {
        _hasMorePages = false;
      } else {
        _allMedicines.addAll(medicines);
        _currentPage++;
      }

      if (_allMedicines.isEmpty) {
        emit(const MedicineError('Không tìm thấy thuốc'));
      } else {
        emit(MedicineListLoaded(
          _allMedicines,
          hasMorePages: _hasMorePages,
        ));
      }
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  Future<void> searchMedicineByName(String query) async {
    try {
      emit(const MedicineLoading());
      final medicine =
          await _repository.searchMedicineByName(query); // 1 thuốc hoặc null
      if (medicine == null) {
        emit(const MedicineError('Không tìm thấy thuốc'));
      } else {
        // chuyển sang list 1 phần tử để dùng chung ListView
        emit(MedicineListLoaded([medicine], hasMorePages: false));
      }
    } catch (e) {
      emit(MedicineError(e.toString()));
    }
  }

  void resetPagination() {
    _currentPage = 1;
    _allMedicines = [];
    _hasMorePages = true;
  }
}
