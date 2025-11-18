import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/prescription_model.dart';

class PrescriptionDetailCard extends StatelessWidget {
  final PrescriptionModel prescription;

  const PrescriptionDetailCard({Key? key, required this.prescription})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final medicines = prescription.medicines ?? [];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tên đơn thuốc
            Text(
              'Tên thuốc: ${prescription.name ?? "-"}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 6),
            // Bác sĩ
            Text(
              'Bác sĩ: ${prescription.doctor ?? "-"}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.grey700),
            ),
            const SizedBox(height: 14),
            // Danh sách thuốc
            Text(
              'Danh sách thuốc (${medicines.length} loại):',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
            ),
            const SizedBox(height: 10),
            ...medicines.asMap().entries.map((entry) {
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên thuốc (hoặc mô tả)
                    Text(
                      'Mô tả: ${item.description ?? "-"}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                    ),
                    const SizedBox(height: 6),
                    // Thông tin chi tiết
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Số lượng: ${item.quantity ?? "-"}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.grey700),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Thời gian: ${item.time ?? "-"}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.grey700),
                          ),
                        ),
                      ],
                    ),
                    if ((item.description ?? "").isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Ghi chú: ${item.description}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
