import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/medicine_detail_cubit.dart';
import '../../widgets/medicine_detail_card.dart';

class MedicineDetailPage extends StatelessWidget {
  final String id;
  const MedicineDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    // Khởi tạo cubit trực tiếp
    final cubit = context.read<MedicineDetailCubit>()..getMedicineById(id);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết thuốc')),
      body: BlocBuilder<MedicineDetailCubit, MedicineDetailState>(
        bloc: cubit,
        builder: (context, state) {
          if (state is MedicineDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MedicineDetailLoaded) {
            return MedicineDetailCard(medicine: state.medicine);
          }
          if (state is MedicineDetailError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
