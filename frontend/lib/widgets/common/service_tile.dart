import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../models/property.dart';

class ServiceTile extends StatefulWidget {
  final ServiceCategory service;
  final VoidCallback? onTap;

  const ServiceTile({super.key, required this.service, this.onTap});

  @override
  State<ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<ServiceTile> {
  bool _isHovered = false;

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'payment': return Icons.payment_rounded;
      case 'description': return Icons.description_rounded;
      case 'local_shipping': return Icons.local_shipping_rounded;
      case 'cleaning_services': return Icons.cleaning_services_rounded;
      case 'chair': return Icons.chair_rounded;
      case 'gavel': return Icons.gavel_rounded;
      case 'format_paint': return Icons.format_paint_rounded;
      case 'ac_unit': return Icons.ac_unit_rounded;
      case 'plumbing': return Icons.plumbing_rounded;
      case 'electrical_services': return Icons.electrical_services_rounded;
      case 'account_balance': return Icons.account_balance_rounded;
      case 'explore': return Icons.explore_rounded;
      default: return Icons.home_repair_service_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isHovered ? AppColors.cardHoverShadow : AppColors.cardShadow,
            border: Border.all(
              color: _isHovered ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(widget.service.icon),
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.service.name,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.service.description,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
