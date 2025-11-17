import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/schedule_model.dart';

class ScheduleItem extends StatefulWidget {
  final ScheduleModel schedule;
  final VoidCallback onDelete;
  final VoidCallback? onSendToDevice;

  const ScheduleItem({
    Key? key,
    required this.schedule,
    required this.onDelete,
    this.onSendToDevice,
  }) : super(key: key);

  @override
  State<ScheduleItem> createState() => _ScheduleItemState();
}

class _ScheduleItemState extends State<ScheduleItem> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.schedule.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.schedule.medicineName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Liều: ${widget.schedule.dosage}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  if (widget.onSendToDevice != null)
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.device_hub, size: 20),
                          SizedBox(width: 8),
                          Text('Gửi thiết bị'),
                        ],
                      ),
                      onTap: widget.onSendToDevice,
                    ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(width: 8),
                        Text('Xóa'),
                      ],
                    ),
                    onTap: widget.onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: widget.schedule.times.map((time) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent),
                ),
                child: Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              );
            }).toList(),
          ),
          if (widget.schedule.notes != null &&
              widget.schedule.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Ghi chú: ${widget.schedule.notes}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey100,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
