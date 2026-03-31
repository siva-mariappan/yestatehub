import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../config/assets.dart';
import '../../models/property.dart';
import '../../widgets/footer/app_footer.dart';
import '../../services/chat_service.dart';
import '../chat/chat_detail_screen.dart';
import 'widgets/photo_gallery.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isSaved = false;
  final ScrollController _scrollController = ScrollController();

  Property get property => widget.property;

  @override
  void initState() {
    super.initState();
    _isSaved = property.isSaved;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
      bottomNavigationBar: isMobile ? _buildMobileBottomBar(context) : null,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => setState(() => _isSaved = !_isSaved),
              backgroundColor: Colors.white,
              elevation: 6,
              child: Icon(
                _isSaved ? Icons.favorite : Icons.favorite_border,
                color: _isSaved ? const Color(0xFFEF4444) : AppColors.textTertiary,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE LAYOUT
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // App header with back button over image carousel
        SliverAppBar(
          expandedHeight: 500,
          pinned: true,
          backgroundColor: AppColors.surface,
          leading: _buildBackButton(context),
          flexibleSpace: FlexibleSpaceBar(
            background: PhotoGallery(images: property.images, height: 500),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Name + Sale badge
              _buildPropertyHeader(),
              const SizedBox(height: 4),
              // Location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildLocationRow(),
              ),
              const SizedBox(height: 16),
              // Action chips (horizontal scroll): Video, 360, AR, VR, Map, Share
              _buildMobileActionChips(),
              const SizedBox(height: 20),
              // Price card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPriceCard(),
              ),
              const SizedBox(height: 24),
              // Specifications grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSpecificationsSection(),
              ),
              const SizedBox(height: 24),
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildDescriptionSection(),
              ),
              const SizedBox(height: 24),
              // Nearby amenities
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildNearbyAmenitiesSection(),
              ),
              const SizedBox(height: 24),
              // Agent contact card (inline)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildMobileContactCard(),
              ),
              const SizedBox(height: 24),
              // Footer
              const AppFooter(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        // App header bar with back button
        _buildDesktopHeaderBar(context),
        const Divider(height: 1, color: AppColors.divider),
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Full-width image carousel (500px)
                PhotoGallery(images: property.images, height: 500),
                const SizedBox(height: 32),
                // Two-column layout
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column: property info
                          Expanded(
                            flex: 3,
                            child: _buildDesktopLeftColumn(),
                          ),
                          const SizedBox(width: 32),
                          // Right column: sticky contact card
                          SizedBox(
                            width: 400,
                            child: _buildDesktopContactCard(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                // Footer spanning full width
                const AppFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopHeaderBar(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            tooltip: 'Back',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              property.title,
              style: AppTypography.headingMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property Name + action buttons row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                property.title,
                style: AppTypography.headingLarge.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Action icons: Video, 360, AR, VR, Map, Share, Heart, Sale
            Wrap(
              spacing: 8,
              children: [
                _desktopActionBox(Icons.videocam_outlined, 'Video'),
                _desktopActionBox(Icons.threesixty, '360°'),
                _desktopActionBox(Icons.view_in_ar_outlined, 'AR'),
                _desktopActionBox(Icons.vrpano_outlined, 'VR'),
                _desktopActionBox(Icons.map_outlined, 'Map'),
                _desktopActionBox(Icons.share_outlined, 'Share'),
                _desktopActionBox(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  'Save',
                  iconColor: _isSaved ? const Color(0xFFEF4444) : null,
                  onTap: () => setState(() => _isSaved = !_isSaved),
                ),
                _buildIntentChip(),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Location
        _buildLocationRow(),
        const SizedBox(height: 24),
        // Price card
        _buildPriceCard(),
        const SizedBox(height: 28),
        // Specifications (2-col)
        _buildSpecificationsSection(),
        const SizedBox(height: 28),
        // Description
        _buildDescriptionSection(),
        const SizedBox(height: 28),
        // Nearby amenities
        _buildNearbyAmenitiesSection(),
        const SizedBox(height: 48),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PROPERTY HEADER — Name + Sale badge (mobile)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPropertyHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              property.title,
              style: AppTypography.headingLarge.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildIntentChip(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // LOCATION ROW
  // ═══════════════════════════════════════════════════════════════
  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 18, color: Color(0xFFEF4444)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            property.address,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INTENT CHIP (For Sale / For Rent)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildIntentChip() {
    final isSale = property.transactionType == TransactionType.buy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isSale
              ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
              : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isSale ? const Color(0xFF3B82F6) : const Color(0xFFF59E0B)).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSale ? Icons.sell_outlined : Icons.vpn_key_outlined,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            isSale ? 'For Sale' : 'For Rent',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTION BUTTONS — MOBILE (horizontal scroll chips)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileActionChips() {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _mobileChip(Icons.videocam_outlined, 'Video'),
          _mobileChip(Icons.threesixty, '360°'),
          _mobileChip(Icons.view_in_ar_outlined, 'AR'),
          _mobileChip(Icons.vrpano_outlined, 'VR'),
          _mobileChip(Icons.map_outlined, 'Map'),
          _mobileChip(Icons.share_outlined, 'Share'),
        ],
      ),
    );
  }

  Widget _mobileChip(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // ACTION BUTTONS — DESKTOP (icon boxes with tooltips)
  // ═══════════════════════════════════════════════════════════════
  Widget _desktopActionBox(IconData icon, String tooltip, {Color? iconColor, VoidCallback? onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Icon(icon, size: 20, color: iconColor ?? AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PRICE CARD (green gradient)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPriceCard() {
    final isRent = property.transactionType == TransactionType.rent ||
        property.transactionType == TransactionType.pg;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Listed Price',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  isRent ? '\u20B9${property.formattedPrice}/mo' : '\u20B9${property.formattedPrice}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800),
                ),
                if (property.pricePerSqft != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '\u20B9${property.pricePerSqft!.toStringAsFixed(0)}/sq.ft',
                    style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.account_balance_wallet_outlined, size: 28, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SPECIFICATIONS GRID (2-col layout)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSpecificationsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(Icons.home_outlined, 'Property Details'),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _buildSpecTiles(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpecTiles() {
    final tiles = <Widget>[];
    tiles.add(_specTile('Bedrooms', '${property.bedrooms} BHK', Icons.bed_outlined, const Color(0xFF3B82F6)));
    tiles.add(_specTile('Bathrooms', '${property.bathrooms} Bath', Icons.bathtub_outlined, const Color(0xFF8B5CF6)));
    tiles.add(_specTile('Built-up Area', '${property.areaSqft.toStringAsFixed(0)} sq.ft', Icons.square_foot, const Color(0xFF10B981)));

    final furnishLabel = property.furnishing == FurnishingStatus.furnished
        ? 'Furnished'
        : property.furnishing == FurnishingStatus.semiFurnished
            ? 'Semi-Furnished'
            : 'Unfurnished';
    tiles.add(_specTile('Furnishing', furnishLabel, Icons.chair_outlined, const Color(0xFFF59E0B)));

    if (property.facingDirection.isNotEmpty) {
      tiles.add(_specTile('Facing', property.facingDirection, Icons.explore_outlined, const Color(0xFFEC4899)));
    }
    if (property.floor > 0) {
      tiles.add(_specTile('Floor', property.floorLabel, Icons.layers_outlined, const Color(0xFF6366F1)));
    }
    tiles.add(_specTile('Property Age', '${property.ageOfBuilding} ${property.ageOfBuilding == 1 ? 'Year' : 'Years'}', Icons.schedule_outlined, const Color(0xFF14B8A6)));

    return tiles;
  }

  Widget _specTile(String label, String value, IconData icon, Color color) {
    final isMobile = Responsive.isMobile(context);
    final tileWidth = isMobile ? (MediaQuery.of(context).size.width - 72) / 2 : 170.0;

    return Container(
      width: tileWidth,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, size: 18, color: color)),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DESCRIPTION SECTION
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDescriptionSection() {
    final description = _generateDescription();
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeading(Icons.description_outlined, 'About This Property'),
                  const SizedBox(height: 14),
                  Text(
                    description,
                    style: const TextStyle(color: Color(0xFF4B5563), fontSize: 16, height: 1.75),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _generateDescription() {
    final type = property.propertyType == PropertyType.villa
        ? 'villa'
        : property.propertyType == PropertyType.independentHouse
            ? 'independent house'
            : 'apartment';
    final furnish = property.furnishing == FurnishingStatus.furnished
        ? 'fully furnished'
        : property.furnishing == FurnishingStatus.semiFurnished
            ? 'semi-furnished'
            : 'unfurnished';

    return 'This beautiful $furnish ${property.bedrooms} BHK $type is located in the '
        'prime area of ${property.locality}, ${property.city}. Spread across '
        '${property.areaSqft.toStringAsFixed(0)} sq.ft of well-planned living space, '
        'the property features ${property.bathrooms} bathrooms and is situated on '
        'floor ${property.floor} of ${property.totalFloors}. '
        'The property faces ${property.facingDirection} ensuring great ventilation and natural light. '
        '${property.possessionStatus}. Listed by ${property.ownerName}.';
  }

  // ═══════════════════════════════════════════════════════════════
  // NEARBY AMENITIES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildNearbyAmenitiesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeading(Icons.place_outlined, 'Nearby Amenities'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: property.amenities.map((a) => _amenityPill(a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _amenityPill(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_amenityIcon(amenity), size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(amenity, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  IconData _amenityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('school') || lower.contains('college')) return Icons.school;
    if (lower.contains('hospital') || lower.contains('clinic')) return Icons.local_hospital;
    if (lower.contains('market') || lower.contains('mall')) return Icons.shopping_bag_outlined;
    if (lower.contains('park') || lower.contains('garden')) return Icons.park;
    if (lower.contains('gym')) return Icons.fitness_center;
    if (lower.contains('pool') || lower.contains('swim')) return Icons.pool;
    if (lower.contains('parking')) return Icons.local_parking;
    if (lower.contains('security') || lower.contains('cctv')) return Icons.security;
    if (lower.contains('lift') || lower.contains('elevator')) return Icons.elevator;
    if (lower.contains('power') || lower.contains('backup')) return Icons.bolt;
    if (lower.contains('club')) return Icons.sports_tennis;
    if (lower.contains('play') || lower.contains('child')) return Icons.child_care;
    if (lower.contains('jog') || lower.contains('track')) return Icons.directions_run;
    if (lower.contains('metro') || lower.contains('bus') || lower.contains('transport')) return Icons.directions_bus;
    return Icons.check_circle_outline;
  }

  // ═══════════════════════════════════════════════════════════════
  // CONTACT — MOBILE (inline card)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileContactCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Green gradient header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent, size: 22, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Contact Agent',
                  style: AppTypography.headingSmall.copyWith(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          // Agent info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _agentAvatar(54),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(property.ownerName, style: AppTypography.labelLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        'Role: ${_getListedByLabel()}',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                if (property.isVerified)
                  const Icon(Icons.verified, color: AppColors.primary, size: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CHAT WITH AGENT — Navigate to chat detail screen
  // ═══════════════════════════════════════════════════════════════
  void _openChatWithAgent() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    try {
      final chatService = ChatService.instance;
      // Use owner's Firebase UID if available, fall back to property ID
      final agentUid = property.ownerUid.isNotEmpty ? property.ownerUid : 'agent_${property.id}';
      final agentName = property.ownerName.isNotEmpty ? property.ownerName : 'Property Agent';

      // Create or get existing conversation via API
      final conv = await chatService.createOrGetConversation(
        propertyId: property.id,
        propertyTitle: property.title,
        participantUid: agentUid,
        participantName: agentName,
      );

      if (!mounted) return;
      Navigator.pop(context); // close loading

      final conversation = ChatConversation(
        id: conv['id'] as String? ?? '',
        name: property.ownerName.isNotEmpty ? property.ownerName : 'Property Agent',
        property: property.title,
        isOnline: true,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: conversation)),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not start chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CONTACT — DESKTOP (sticky right column)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDesktopContactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // Green header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent, size: 22, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Contact Agent',
                  style: AppTypography.headingSmall.copyWith(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Agent info
          Row(
            children: [
              _agentAvatar(54),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(property.ownerName, style: AppTypography.labelLarge.copyWith(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      'Role: ${_getListedByLabel()}',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (property.isVerified)
                const Icon(Icons.verified, color: AppColors.primary, size: 24),
            ],
          ),
          const SizedBox(height: 24),
          // Call Now
          _fullWidthButton(
            icon: SvgPicture.asset(AppAssets.icPhone, width: 18, height: 18, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            label: 'Call',
            onPressed: () {},
            backgroundColor: AppColors.primary,
            textColor: Colors.white,
            height: 50,
          ),
          const SizedBox(height: 12),
          // Chat
          _fullWidthButton(
            icon: SvgPicture.asset(AppAssets.icMessage, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.info, BlendMode.srcIn)),
            label: 'Chat',
            onPressed: () => _openChatWithAgent(),
            borderColor: AppColors.info,
            textColor: AppColors.info,
            height: 46,
          ),
          const SizedBox(height: 20),
          // Trust badges
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (property.isVerified)
                  _trustRow(Icons.verified, 'Verified Property', AppColors.primary),
                if (property.isReraApproved) ...[
                  const SizedBox(height: 8),
                  _trustRow(Icons.assured_workload, 'RERA: ${property.reraId ?? "Approved"}', AppColors.navy),
                ],
                if (property.noBrokerage) ...[
                  const SizedBox(height: 8),
                  _trustRow(Icons.money_off, 'Zero Brokerage', AppColors.amber),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fullWidthButton({
    required Widget icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? borderColor,
    required Color textColor,
    required double height,
  }) {
    if (backgroundColor != null) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon,
          label: Text(label, style: AppTypography.buttonMedium.copyWith(color: textColor, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label, style: AppTypography.buttonMedium.copyWith(color: textColor, fontSize: 15)),
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          side: BorderSide(color: borderColor ?? textColor, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _trustRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: AppTypography.labelMedium.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MOBILE BOTTOM BAR — Call, WhatsApp, Email, Chat
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMobileBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          // Call
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: SvgPicture.asset(AppAssets.icPhone, width: 16, height: 16, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                label: Text('Call', style: AppTypography.buttonMedium.copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Chat
          _bottomBarIcon(
            SvgPicture.asset(AppAssets.icMessage, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.info, BlendMode.srcIn)),
            AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _bottomBarIcon(Widget icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: IconButton(onPressed: () => _openChatWithAgent(), icon: icon),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  Widget _sectionHeading(IconData icon, String title) {
    return Row(
      children: [
        Container(width: 4, height: 28, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.headingMedium.copyWith(fontSize: 22, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _agentAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(
          property.ownerName[0],
          style: TextStyle(color: Colors.white, fontSize: size * 0.4, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String _getListedByLabel() {
    switch (property.listedBy) {
      case ListedBy.owner:
        return 'Owner';
      case ListedBy.builder:
        return 'Builder';
      case ListedBy.dealer:
        return 'Agent';
    }
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
        ),
        child: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, size: 20),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
