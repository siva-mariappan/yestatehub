import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/assets.dart';
import '../../models/property.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final bool isCompact;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.onSave,
    this.isCompact = false,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
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
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isHovered ? AppColors.cardHoverShadow : AppColors.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Section ──
              _buildImageSection(),
              // ── Badges Row (Verified | RERA | Zero Brokerage | ♥) ──
              _buildBadgeRow(),
              // ── Content Section ──
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction type badge
                      _buildTransactionBadge(),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        widget.property.title,
                        style: AppTypography.headingSmall.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Location
                      _buildLocationRow(),
                      const SizedBox(height: 6),
                      // Details: BHK | Bath | Sqft
                      _buildDetailsRow(),
                      const Spacer(),
                      // Price + View Details
                      _buildPriceRow(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Image ──────────────────────────────────────────────────────────────
  Widget _buildImageSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.divider,
              image: widget.property.images.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(widget.property.images.first),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: widget.property.images.isEmpty
                ? const Center(
                    child: Icon(Icons.home_outlined, size: 48, color: AppColors.textTertiary),
                  )
                : null,
          ),
          // Image count badge
          if (widget.property.images.length > 1)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_camera, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.property.images.length}',
                      style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          // Owner badge (top-left)
          if (widget.property.listedBy == ListedBy.owner)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 0.5),
                ),
                child: Text(
                  'Owner',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Badges Row ─────────────────────────────────────────────────────────
  Widget _buildBadgeRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (widget.property.isVerified) ...[
            _buildSmallBadge(
              icon: SvgPicture.asset(AppAssets.icVerified, width: 12, height: 12, colorFilter: const ColorFilter.mode(AppColors.primaryDark, BlendMode.srcIn)),
              label: 'Verified',
              color: AppColors.primaryDark,
              bgColor: AppColors.primaryExtraLight,
            ),
            const SizedBox(width: 8),
          ],
          if (widget.property.isReraApproved) ...[
            _buildSmallBadge(
              icon: const Icon(Icons.verified_outlined, size: 12, color: AppColors.info),
              label: 'RERA',
              color: AppColors.info,
              bgColor: AppColors.infoLight,
            ),
            const SizedBox(width: 8),
          ],
          // Zero Brokerage badge removed
          const Spacer(),
          // Heart / Save button
          GestureDetector(
            onTap: widget.onSave,
            child: SvgPicture.asset(
              AppAssets.icHeart,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                widget.property.isSaved ? AppColors.error : AppColors.textTertiary,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge({required Widget icon, required String label, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── Transaction Type Badge ─────────────────────────────────────────────
  Widget _buildTransactionBadge() {
    String label;
    Color bgColor;
    Color textColor;

    switch (widget.property.transactionType) {
      case TransactionType.buy:
        label = 'For Sale';
        bgColor = AppColors.primaryExtraLight;
        textColor = AppColors.primaryDark;
        break;
      case TransactionType.rent:
        label = 'For Rent';
        bgColor = AppColors.infoLight;
        textColor = AppColors.info;
        break;
      case TransactionType.pg:
        label = 'PG';
        bgColor = AppColors.amberLight;
        textColor = AppColors.amber;
        break;
      case TransactionType.commercial:
        label = 'Commercial';
        bgColor = const Color(0xFFEDE9FE);
        textColor = const Color(0xFF7C3AED);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Location Row ──────────────────────────────────────────────────────
  Widget _buildLocationRow() {
    return Row(
      children: [
        SvgPicture.asset(
          AppAssets.icLocation,
          width: 14,
          height: 14,
          colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '${widget.property.locality}, ${widget.property.city}',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── Details Row: BHK | Bath | Sqft ────────────────────────────────────
  Widget _buildDetailsRow() {
    return Row(
      children: [
        _buildDetailItem(Icons.bed_outlined, widget.property.bhkLabel),
        const SizedBox(width: 10),
        _buildDetailItem(Icons.bathtub_outlined, '${widget.property.bathrooms} Bath'),
        const SizedBox(width: 10),
        _buildDetailItem(Icons.square_foot_outlined, widget.property.areaLabel),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ── Price Row + View Details ──────────────────────────────────────────
  Widget _buildPriceRow() {
    final isRent = widget.property.transactionType == TransactionType.rent ||
        widget.property.transactionType == TransactionType.pg;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Price
        Text(
          isRent
              ? '\u20B9${widget.property.formattedPrice}/mo'
              : '\u20B9${widget.property.formattedPrice}',
          style: AppTypography.priceLarge.copyWith(fontSize: 15),
        ),
        if (widget.property.pricePerSqft != null) ...[
          const SizedBox(width: 8),
          Text(
            '\u20B9${widget.property.pricePerSqft!.toStringAsFixed(0)}/sq.ft',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary, fontSize: 10),
          ),
        ],
        const Spacer(),
        // View Details button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'View Details',
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
