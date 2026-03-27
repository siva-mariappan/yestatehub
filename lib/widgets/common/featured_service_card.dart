import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../models/property.dart';

/// Large horizontal service card with background image and offer badge
/// Matches the "Rental Agreement / Home Cleaning" style from design spec
class FeaturedServiceCard extends StatefulWidget {
  final ServiceCategory service;
  final VoidCallback? onTap;

  const FeaturedServiceCard({super.key, required this.service, this.onTap});

  @override
  State<FeaturedServiceCard> createState() => _FeaturedServiceCardState();
}

class _FeaturedServiceCardState extends State<FeaturedServiceCard> {
  bool _isHovered = false;

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
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: _isHovered ? AppColors.cardHoverShadow : AppColors.cardShadow,
            border: Border.all(
              color: AppColors.border.withOpacity(0.6),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Background image (right side)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 150,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    image: widget.service.imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.service.imageUrl),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.85),
                              BlendMode.luminosity,
                            ),
                          )
                        : null,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Content (left side)
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.service.name,
                      style: AppTypography.headingMedium.copyWith(
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.service.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.service.offerText != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.amber.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer_rounded,
                              size: 14,
                              color: AppColors.amber.withOpacity(0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.service.offerText!,
                              style: AppTypography.labelMedium.copyWith(
                                color: const Color(0xFF92400E),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
