import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/medicine_model.dart';

class MedicineDetailCard extends StatelessWidget {
  final MedicineModel medicine;

  const MedicineDetailCard({Key? key, required this.medicine})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.medication_liquid,
                          color: AppColors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        medicine.name ?? "-",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                        'Liều dùng',
                        medicine.quantity != null
                            ? medicine.quantity.toString()
                            : "-",
                        context),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Mô tả', Icons.description, context),
              const SizedBox(height: 12),
              Text(
                medicine.description ?? "_",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: AppColors.grey700,
                    ),
              ),
              const SizedBox(height: 20),
              // _buildSectionHeader('Thành phần', Icons.science, context),
              // const SizedBox(height: 12),
              // Container(
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     color: AppColors.primaryLight,
              //     borderRadius: BorderRadius.circular(8),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: medicine.ingredients.map((ingredient) {
              //       return Padding(
              //         padding: const EdgeInsets.only(bottom: 8),
              //         child: Row(
              //           children: [
              //             Container(
              //               width: 6,
              //               height: 6,
              //               decoration: BoxDecoration(
              //                 color: AppColors.primary,
              //                 shape: BoxShape.circle,
              //               ),
              //             ),
              //             const SizedBox(width: 10),
              //             Expanded(
              //               child: Text(
              //                 ingredient,
              //                 style: Theme.of(context)
              //                     .textTheme
              //                     .bodySmall
              //                     ?.copyWith(
              //                       color: AppColors.grey700,
              //                     ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),
              const SizedBox(height: 20),
              _buildSectionHeader('Cách sử dụng', Icons.info, context),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent, width: 1),
                ),
                child: Text(
                  medicine.dosage ?? "-",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.black,
                        height: 1.6,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              // Container(
              //   padding: const EdgeInsets.all(14),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFFEE2E2),
              //     borderRadius: BorderRadius.circular(10),
              //     border: Border.all(color: AppColors.error, width: 2),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: [
              //           Container(
              //             padding: const EdgeInsets.all(6),
              //             decoration: BoxDecoration(
              //               color: AppColors.error,
              //               borderRadius: BorderRadius.circular(6),
              //             ),
              //             child: const Icon(Icons.warning,
              //                 color: AppColors.white, size: 18),
              //           ),
              //           const SizedBox(width: 10),
              //           Text(
              //             'Tác dụng phụ có thể xảy ra',
              //             style:
              //                 Theme.of(context).textTheme.titleSmall?.copyWith(
              //                       color: AppColors.error,
              //                       fontWeight: FontWeight.w700,
              //                     ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 10),
              //       Text(
              //         medicine.sideEffects,
              //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //               color: AppColors.black,
              //               height: 1.6,
              //             ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
        ),
      ],
    );
  }
}
