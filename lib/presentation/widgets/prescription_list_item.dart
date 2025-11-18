import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/prescription_model.dart';

class PrescriptionListItem extends StatefulWidget {
  final PrescriptionModel prescription;
  final VoidCallback onTap;

  const PrescriptionListItem({
    Key? key,
    required this.prescription,
    required this.onTap,
  }) : super(key: key);

  @override
  State<PrescriptionListItem> createState() => _PrescriptionListItemState();
}

class _PrescriptionListItemState extends State<PrescriptionListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered ? AppColors.primary : AppColors.grey200,
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(_isHovered ? 0.15 : 0.05),
                blurRadius: _isHovered ? 10 : 4,
                offset: Offset(0, _isHovered ? 3 : 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.prescription.name ?? "-",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person,
                            size: 14, color: AppColors.grey400),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'BS. ${widget.prescription.doctor}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.grey500,
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.prescription.medicines?.length} loại thuốc',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: _isHovered ? AppColors.primary : AppColors.grey300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
