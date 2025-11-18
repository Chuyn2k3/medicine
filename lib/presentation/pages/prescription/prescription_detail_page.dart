import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../cubits/prescription_detail_cubit.dart';
import '../../widgets/prescription_detail_card.dart';

class PrescriptionDetailPage extends StatelessWidget {
  final String prescriptionId;

  const PrescriptionDetailPage({super.key, required this.prescriptionId});

  @override
  Widget build(BuildContext context) {
    context.read<PrescriptionDetailCubit>().getPrescriptionById(prescriptionId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn thuốc'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocBuilder<PrescriptionDetailCubit, PrescriptionDetailState>(
        builder: (context, state) {
          if (state is PrescriptionDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PrescriptionDetailLoaded) {
            return PrescriptionDetailCard(prescription: state.prescription);
          } else if (state is PrescriptionDetailError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
