import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

/// Step 6: Review & Submit
class AddPropertyScreen6 extends StatefulWidget {
  final Map<String, dynamic> data;
  const AddPropertyScreen6({super.key, required this.data});

  @override
  State<AddPropertyScreen6> createState() => _AddPropertyScreen6State();
}

class _AddPropertyScreen6State extends State<AddPropertyScreen6> {
  bool agreedToTerms = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.rate_review_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Review & Submit', style: AppTypography.headingMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Review your listing details before publishing',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Property Overview Card
          _buildPropertyOverviewCard(),
          const SizedBox(height: 20),

          // Location Card
          _buildLocationCard(),
          const SizedBox(height: 20),

          // Pricing Card
          _buildPricingCard(),
          const SizedBox(height: 20),

          // Media Card
          _buildMediaCard(),
          const SizedBox(height: 20),

          // Contact & Plan Card
          _buildContactCard(),
          const SizedBox(height: 24),

          // Terms & Conditions
          _buildTermsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPropertyOverviewCard() {
    final purpose = widget.data['purpose'] ?? 'Sell';
    final propertyType = widget.data['propertyType'] ?? '';
    final propertyName = widget.data['propertyName'] ?? '';
    final area = widget.data['area']?.toString() ?? '';
    final unit = widget.data['measurementUnit'] ?? 'Square Feet';
    final facing = widget.data['facing'] ?? '';
    final bedrooms = widget.data['bedrooms'] ?? '';
    final bathrooms = widget.data['bathrooms'] ?? '';
    final furnishing = widget.data['furnishing'] ?? '';

    return _buildReviewCard(
      icon: Icons.home_rounded,
      iconColor: AppColors.primary,
      title: 'Property Details',
      stepNumber: 1,
      children: [
        _buildDetailRow('Purpose', purpose, icon: Icons.sell_rounded),
        if (propertyType.isNotEmpty)
          _buildDetailRow('Type', propertyType, icon: Icons.category_rounded),
        if (propertyName.isNotEmpty)
          _buildDetailRow('Name', propertyName, icon: Icons.label_rounded),
        if (area.isNotEmpty && area != 'null')
          _buildDetailRow('Area', '$area $unit', icon: Icons.square_foot_rounded),
        if (facing.isNotEmpty)
          _buildDetailRow('Facing', facing, icon: Icons.explore_rounded),
        if (bedrooms.isNotEmpty)
          _buildDetailRow('Bedrooms', bedrooms, icon: Icons.bed_rounded),
        if (bathrooms.isNotEmpty)
          _buildDetailRow('Bathrooms', bathrooms, icon: Icons.bathtub_rounded),
        if (furnishing.isNotEmpty)
          _buildDetailRow('Furnishing', furnishing, icon: Icons.weekend_rounded),
      ],
    );
  }

  Widget _buildLocationCard() {
    final state = widget.data['state'] ?? '';
    final district = widget.data['district'] ?? '';
    final locality = widget.data['locality'] ?? '';
    final pincode = widget.data['pincode'] ?? '';
    final address = widget.data['address'] ?? '';

    return _buildReviewCard(
      icon: Icons.location_on_rounded,
      iconColor: const Color(0xFFEF4444),
      title: 'Location',
      stepNumber: 2,
      children: [
        if (state != null && state.toString().isNotEmpty)
          _buildDetailRow('State', state.toString(), icon: Icons.map_rounded),
        if (district != null && district.toString().isNotEmpty)
          _buildDetailRow('District', district.toString(), icon: Icons.location_city_rounded),
        if (locality.isNotEmpty)
          _buildDetailRow('Locality', locality, icon: Icons.place_rounded),
        if (pincode.isNotEmpty)
          _buildDetailRow('Pincode', pincode, icon: Icons.pin_drop_rounded),
        if (address.isNotEmpty)
          _buildDetailRow('Address', address, icon: Icons.home_work_rounded),
      ],
    );
  }

  Widget _buildPricingCard() {
    final price = widget.data['price'] ?? '';
    final negotiable = widget.data['negotiable'] == true;
    final deposit = widget.data['deposit'] ?? '';
    final maintenance = widget.data['maintenance'] ?? '';

    return _buildReviewCard(
      icon: Icons.currency_rupee_rounded,
      iconColor: const Color(0xFFF59E0B),
      title: 'Pricing & Details',
      stepNumber: 3,
      children: [
        if (price.toString().isNotEmpty)
          _buildDetailRow('Price', '₹$price', icon: Icons.payments_rounded),
        _buildDetailRow('Negotiable', negotiable ? 'Yes' : 'No', icon: Icons.handshake_rounded),
        if (deposit.toString().isNotEmpty)
          _buildDetailRow('Deposit', '₹$deposit', icon: Icons.account_balance_wallet_rounded),
        if (maintenance.toString().isNotEmpty)
          _buildDetailRow('Maintenance', '₹$maintenance', icon: Icons.build_rounded),
      ],
    );
  }

  Widget _buildMediaCard() {
    final images = widget.data['images'] as List? ?? [];
    final videoUrl = widget.data['videoUrl'] ?? '';

    return _buildReviewCard(
      icon: Icons.camera_alt_rounded,
      iconColor: const Color(0xFF8B5CF6),
      title: 'Media',
      stepNumber: 4,
      children: [
        _buildDetailRow(
          'Photos',
          '${images.length} uploaded',
          icon: Icons.photo_library_rounded,
          valueColor: images.length >= 3 ? Colors.green : const Color(0xFFEF4444),
        ),
        _buildDetailRow(
          'Video',
          videoUrl.toString().isNotEmpty ? 'Added' : 'Not added',
          icon: Icons.videocam_rounded,
          valueColor: videoUrl.toString().isNotEmpty ? Colors.green : AppColors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    final planId = widget.data['selectedPlan'] ?? 'free';
    final planNames = {
      'free': 'Free Listing',
      'basic': 'Basic Plan — ₹999',
      'premium': 'Premium Plan — ₹2,499',
      'professional': 'Professional Plan — ₹4,999',
    };
    final planName = planNames[planId] ?? 'Free Listing';

    return _buildReviewCard(
      icon: Icons.person_rounded,
      iconColor: const Color(0xFF06B6D4),
      title: 'Contact & Plan',
      stepNumber: 5,
      children: [
        _buildDetailRow('Listed By', (widget.data['listedBy'] ?? 'Owner').toString().toUpperCase(), icon: Icons.badge_rounded),
        _buildDetailRow(
          'Verification',
          'Verified',
          icon: Icons.verified_rounded,
          valueColor: Colors.green,
        ),
        _buildDetailRow(
          'Plan',
          planName,
          icon: Icons.workspace_premium_rounded,
          valueColor: planId == 'free' ? Colors.green : AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int stepNumber,
    required List<Widget> children,
  }) {
    // Filter out empty widgets
    final validChildren = children.where((w) => w is! SizedBox).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Step $stepNumber',
                    style: TextStyle(fontSize: 11, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          // Card body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (validChildren.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 8),
                        Text(
                          'No details added yet',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  )
                else
                  ...validChildren,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {required IconData icon, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: agreedToTerms,
              onChanged: (v) => setState(() => agreedToTerms = v ?? false),
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By publishing, you confirm that the details are accurate.',
                  style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
