import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../models/property.dart';

/// Small square service card with rounded image
/// Matches the "Packers & Movers / Home Painting" style from design spec
class SmallServiceCard extends StatefulWidget {
  final ServiceCategory service;
  final VoidCallback? onTap;

  const SmallServiceCard({super.key, required this.service, this.onTap});

  @override
  State<SmallServiceCard> createState() => _SmallServiceCardState();
}

class _SmallServiceCardState extends State<SmallServiceCard> {
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
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _isHovered ? AppColors.cardHoverShadow : AppColors.cardShadow,
            border: Border.all(
              color: _isHovered
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 14),
              // Circular image or icon container
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: AppColors.primaryExtraLight,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                    width: 1.5,
                  ),
                  image: widget.service.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.service.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: widget.service.imageUrl.isEmpty
                    ? Icon(
                        _getIcon(widget.service.icon),
                        size: 32,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              // Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.service.name,
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
