import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medical_drug/data/models/prescription_model.dart';

import '../../core/theme/app_colors.dart';
import '../cubits/schedule_cubit.dart';
import '../pages/schedule/edit_schedule_page.dart';

enum _ScheduleAction { edit, delete }

class ScheduleItem extends StatelessWidget {
  final PrescriptionModel schedule;
  final VoidCallback onDelete;

  const ScheduleItem({
    Key? key,
    required this.schedule,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy cubit tại đây, dùng lại trong mọi chỗ, không phụ thuộc context sau khi pop
    final scheduleCubit = context.read<ScheduleCubit>();

    final firstMedicine =
        schedule.medicines != null && schedule.medicines!.isNotEmpty
            ? schedule.medicines!.first
            : null;

    return InkWell(
      onTap: () {
        Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => EditSchedulePage(schedule: schedule),
          ),
        ).then((updated) {
          if (updated == true) {
            // Context của item có thể đã unmounted, nhưng cubit thì vẫn còn
            scheduleCubit.getScheduleList();
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh màu bên trái
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề + menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTitle(context)),
                      _buildMenu(context, scheduleCubit),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Info nhanh
                  Row(
                    children: [
                      if (firstMedicine != null &&
                          (firstMedicine.time?.isNotEmpty ?? false))
                        _infoChip(
                          icon: Icons.calendar_today_rounded,
                          label: firstMedicine.time!,
                        ),
                      if (schedule.medicines != null &&
                          schedule.medicines!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _infoChip(
                          icon: Icons.repeat_rounded,
                          label: '${schedule.medicines!.length} lần/ngày',
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Danh sách ngày + slot giờ
                  if (schedule.medicines != null &&
                      schedule.medicines!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: schedule.medicines!.map((m) {
                        // format ngày
                        String dateLabel = '-';
                        if (m.time != null && m.time!.isNotEmpty) {
                          try {
                            final parsed =
                                DateTime.parse(m.time!); // "2025-11-18"
                            dateLabel = DateFormat('dd/MM/yyyy')
                                .format(parsed); // "18/11/2025"
                          } catch (_) {
                            dateLabel = m.time!; // fallback nếu parse lỗi
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (m.time != null)
                                Text(
                                  'Ngày: ${dateLabel}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.grey700,
                                      ),
                                ),
                              if (m.quantity != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Số viên mỗi lần: ${m.quantity}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                'Mô tả: ${m.description}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                              if (m.times != null && m.times!.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: m.times!.map((utcTime) {
                                    // utcTime là UTC, convert về local
                                    final local = utcTime.toLocal();
                                    final formatted =
                                        TimeOfDay.fromDateTime(local)
                                            .format(context);
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentLight,
                                        borderRadius: BorderRadius.circular(20),
                                        border:
                                            Border.all(color: AppColors.accent),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.alarm_rounded,
                                            size: 14,
                                            color: AppColors.accent,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            formatted,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.accent,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tên đơn: ${schedule.name}",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        //if (schedule.description != null && schedule.description!.isNotEmpty)
        Text(
          "Mô tả: ${schedule.description}",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context, ScheduleCubit scheduleCubit) {
    return PopupMenuButton<_ScheduleAction>(
      onSelected: (action) {
        switch (action) {
          case _ScheduleAction.edit:
            Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => EditSchedulePage(schedule: schedule),
              ),
            ).then((updated) {
              if (updated == true) {
                scheduleCubit.getScheduleList();
              }
            });
            break;
          case _ScheduleAction.delete:
            onDelete();
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem<_ScheduleAction>(
          value: _ScheduleAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Chỉnh sửa'),
            ],
          ),
        ),
        PopupMenuItem<_ScheduleAction>(
          value: _ScheduleAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              SizedBox(width: 8),
              Text('Xóa', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.grey700),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.grey700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
