import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/prescription_model.dart';
import '../../data/repositories/prescription_repository.dart';

part 'prescription_state.dart';

class PrescriptionCubit extends Cubit<PrescriptionState> {
  final PrescriptionRepository _repository;

  int _currentPage = 1;
  final int _pageSize = 10;
  List<PrescriptionModel> _allPrescriptions = [];
  bool _hasMorePages = true;

  PrescriptionCubit(this._repository) : super(const PrescriptionInitial());

  Future<void> getPrescriptionList({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        _currentPage = 1;
        _allPrescriptions = [];
        _hasMorePages = true;
        emit(const PrescriptionLoading());
      } else if (!_hasMorePages) {
        return;
      }

      final prescriptions = await _repository.getPrescriptionList();

      if (prescriptions.isEmpty) {
        _hasMorePages = false;
      } else {
        _allPrescriptions.addAll(prescriptions);
        _currentPage++;
      }

      if (_allPrescriptions.isEmpty) {
        emit(const PrescriptionError('Không tìm thấy đơn thuốc'));
      } else {
        emit(PrescriptionListLoaded(
          _allPrescriptions,
          hasMorePages: _hasMorePages,
        ));
      }
    } catch (e) {
      emit(PrescriptionError(e.toString()));
    }
  }

  void resetPagination() {
    _currentPage = 1;
    _allPrescriptions = [];
    _hasMorePages = true;
  }
}
