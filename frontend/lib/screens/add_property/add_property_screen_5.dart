import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

/// Step 5: Contact Info
class AddPropertyScreen5 extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>>? onUpdate;

  const AddPropertyScreen5({super.key, required this.data, this.onUpdate});

  @override
  State<AddPropertyScreen5> createState() => _AddPropertyScreen5State();
}

class _AddPropertyScreen5State extends State<AddPropertyScreen5> {
  // Listed By
  String selectedListedBy = 'owner'; // owner, agent, builder

  // Contact Details
  late TextEditingController contactNameController;
  late TextEditingController mobileNumberController;
  late TextEditingController emailController;
  late TextEditingController whatsappNumberController;
  late TextEditingController agencyNameController;
  late TextEditingController reraNumberController;
  late TextEditingController officeAddressController;
  late TextEditingController companyNameController;
  late TextEditingController companyAddressController;

  bool whatsappSameAsMobile = true;
  String selectedExperience = '1–3 years';
  String selectedProjectsCompleted = '1–5';

  // OTP Verification
  List<String> otpDigits = ['', '', '', ''];
  bool isOtpVerified = false;
  int otpTimer = 60;
  bool isOtpSent = false;

  // Subscription Plan
  String selectedPlan = 'free';


  @override
  void initState() {
    super.initState();
    contactNameController = TextEditingController();
    mobileNumberController = TextEditingController();
    emailController = TextEditingController();
    whatsappNumberController = TextEditingController();
    agencyNameController = TextEditingController();
    reraNumberController = TextEditingController();
    officeAddressController = TextEditingController();
    companyNameController = TextEditingController();
    companyAddressController = TextEditingController();
  }

  @override
  void dispose() {
    contactNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    whatsappNumberController.dispose();
    agencyNameController.dispose();
    reraNumberController.dispose();
    officeAddressController.dispose();
    companyNameController.dispose();
    companyAddressController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    setState(() {
      isOtpSent = true;
      otpTimer = 60;
      // Mock: auto-fill OTP
      otpDigits = ['1', '2', '3', '4'];
    });
    _startOtpTimer();
  }

  void _startOtpTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && otpTimer > 0) {
        setState(() => otpTimer--);
        _startOtpTimer();
      }
    });
  }

  void _verifyOtp() {
    // Mock verification
    setState(() {
      isOtpVerified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Contact & Submission', style: AppTypography.headingMedium),
          const SizedBox(height: 6),
          Text(
            'Complete your contact details and verify to go live.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Listed By Section
          _buildListedBySection(),
          const SizedBox(height: 24),

          // Contact Details Section
          _buildContactDetailsSection(),
          const SizedBox(height: 24),

          // OTP Verification Section
          _buildOtpVerificationSection(),
          const SizedBox(height: 24),

          // Subscription Plan Section
          _buildSubscriptionPlansSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildListedBySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Listed By', style: AppTypography.headingSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildListedByCard('Owner', Icons.person_outline, 'owner'),
            const SizedBox(width: 12),
            _buildListedByCard('Agent', Icons.business_center_outlined, 'agent'),
            const SizedBox(width: 12),
            _buildListedByCard('Builder', Icons.apartment_outlined, 'builder'),
          ],
        ),
      ],
    );
  }

  Widget _buildListedByCard(String label, IconData icon, String value) {
    final isSelected = selectedListedBy == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedListedBy = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Details', style: AppTypography.headingSmall),
        const SizedBox(height: 12),
        _buildTextField('Contact Name *', contactNameController, 'Enter your name'),
        const SizedBox(height: 12),
        _buildPhoneField(),
        const SizedBox(height: 12),
        _buildTextField('Email', emailController, 'your.email@example.com'),
        const SizedBox(height: 12),
        _buildWhatsappSection(),
        const SizedBox(height: 12),
        if (selectedListedBy == 'agent') ...[
          _buildTextField('Agency Name *', agencyNameController, 'Enter agency name'),
          const SizedBox(height: 12),
          _buildTextField('RERA Number *', reraNumberController, 'Enter RERA number'),
          const SizedBox(height: 12),
          _buildDropdown('Experience *', selectedExperience, ['1–3 years', '3–5', '5–10', '10+'], (v) {
            setState(() => selectedExperience = v);
          }),
          const SizedBox(height: 12),
          _buildTextField('Office Address *', officeAddressController, 'Enter office address'),
          const SizedBox(height: 12),
        ] else if (selectedListedBy == 'builder') ...[
          _buildTextField('Company Name *', companyNameController, 'Enter company name'),
          const SizedBox(height: 12),
          _buildDropdown('Projects Completed *', selectedProjectsCompleted, ['1–5', '5–10', '10–20', '20+'], (v) {
            setState(() => selectedProjectsCompleted = v);
          }),
          const SizedBox(height: 12),
          _buildTextField('Company Address *', companyAddressController, 'Enter company address'),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mobile Number *', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: mobileNumberController,
          keyboardType: TextInputType.number,
          style: AppTypography.bodyMedium,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: '9876543210',
            prefixText: '+91 ',
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            counterText: '',
          ),
        ),
      ],
    );
  }

  Widget _buildWhatsappSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('WhatsApp Same as Mobile', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
            Switch(
              value: whatsappSameAsMobile,
              onChanged: (v) => setState(() => whatsappSameAsMobile = v),
              activeColor: AppColors.primary,
            ),
          ],
        ),
        if (!whatsappSameAsMobile) ...[
          const SizedBox(height: 12),
          _buildTextField('WhatsApp Number', whatsappNumberController, '9876543210'),
        ],
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item, style: AppTypography.bodyMedium));
          }).toList(),
          onChanged: (v) => onChanged(v ?? value),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpVerificationSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: isOtpVerified
            ? LinearGradient(
                colors: [Colors.green.shade50, Colors.green.shade50.withOpacity(0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFF0FDF4), Color(0xFFF7FEF9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOtpVerified ? Colors.green.shade300 : AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isOtpVerified ? Colors.green : AppColors.primary).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isOtpVerified
                  ? Colors.green.shade50
                  : AppColors.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isOtpVerified
                        ? Colors.green.withOpacity(0.15)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOtpVerified ? Icons.verified_rounded : Icons.phone_android_rounded,
                    color: isOtpVerified ? Colors.green : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mobile Verification',
                        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOtpVerified
                            ? 'Your number has been verified'
                            : 'Verify your number to publish listing',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isOtpVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator
                if (!isOtpVerified) ...[
                  Row(
                    children: [
                      _buildStepDot(1, 'Enter Number', true),
                      Expanded(child: Container(height: 2, color: isOtpSent ? AppColors.primary : AppColors.border)),
                      _buildStepDot(2, 'Enter OTP', isOtpSent),
                      Expanded(child: Container(height: 2, color: isOtpVerified ? Colors.green : AppColors.border)),
                      _buildStepDot(3, 'Verified', isOtpVerified),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Phone number display
                if (!isOtpSent) ...[
                  Text(
                    'We\'ll send a 4-digit code to your mobile number',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Text('🇮🇳', style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 4),
                              Text('+91', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            mobileNumberController.text.isNotEmpty
                                ? mobileNumberController.text
                                : 'Enter mobile number above',
                            style: AppTypography.bodyMedium.copyWith(
                              color: mobileNumberController.text.isNotEmpty
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _sendOtp,
                      icon: const Icon(Icons.sms_outlined, size: 18, color: Colors.white),
                      label: Text(
                        'Send OTP',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else if (!isOtpVerified) ...[
                  // OTP sent state
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFFF97316), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'OTP sent to +91 ${mobileNumberController.text.isNotEmpty ? mobileNumberController.text : '••••••••••'}',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF9A3412),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OTP Input Boxes
                  Text(
                    'Enter verification code',
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final hasValue = otpDigits[index].isNotEmpty;
                      return Container(
                        margin: EdgeInsets.only(right: index < 3 ? 16 : 0),
                        width: 56,
                        height: 60,
                        decoration: BoxDecoration(
                          color: hasValue ? AppColors.primary.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: hasValue ? AppColors.primary : AppColors.border,
                            width: hasValue ? 2 : 1.5,
                          ),
                          boxShadow: hasValue
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            otpDigits[index],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Timer & Resend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (otpTimer > 0) ...[
                        Icon(Icons.timer_outlined, size: 16, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          'Resend in ',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                        ),
                        Text(
                          '00:${otpTimer.toString().padLeft(2, '0')}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ] else
                        GestureDetector(
                          onTap: _sendOtp,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Resend OTP',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _verifyOtp,
                      icon: const Icon(Icons.verified_user_outlined, size: 18, color: Colors.white),
                      label: Text(
                        'Verify & Continue',
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ] else ...[
                  // Verified state
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_rounded, color: Colors.green.shade600, size: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Phone Number Verified!',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+91 ${mobileNumberController.text.isNotEmpty ? mobileNumberController.text : '••••••••••'}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
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
    );
  }

  Widget _buildStepDot(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: 2,
            ),
          ),
          child: Center(
            child: isActive
                ? Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : Text(
                    '$step',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.primary : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionPlansSection() {
    final plans = [
      {
        'id': 'free',
        'title': 'Free Listing',
        'price': null,
        'description': 'Basic listing, submitted for review',
        'badge': null,
        'icon': Icons.star_border_rounded,
        'features': ['Basic visibility', 'Standard review (24-48hrs)'],
      },
      {
        'id': 'basic',
        'title': 'Basic Plan',
        'price': '₹999',
        'description': 'Enhanced visibility',
        'badge': null,
        'icon': Icons.star_half_rounded,
        'features': ['Enhanced visibility', 'Faster review (12hrs)', 'Featured for 7 days'],
      },
      {
        'id': 'premium',
        'title': 'Premium Plan',
        'price': '₹2,499',
        'description': 'Priority listing + verification badge',
        'badge': 'Most Popular',
        'icon': Icons.star_rounded,
        'features': ['Priority placement', 'Verified badge', 'Featured for 30 days', 'Social media promotion'],
      },
      {
        'id': 'professional',
        'title': 'Professional Plan',
        'price': '₹4,999',
        'description': 'Top placement + all features',
        'badge': null,
        'icon': Icons.workspace_premium_rounded,
        'features': ['Top placement', 'All Premium features', 'Dedicated support', 'Professional photography'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 20),
            ),
            const SizedBox(width: 10),
            Text('Choose Your Plan', style: AppTypography.headingSmall),
          ],
        ),
        const SizedBox(height: 14),
        ...plans.map((plan) {
          final isSelected = selectedPlan == plan['id'];
          final isPremium = plan['id'] == 'premium';
          return GestureDetector(
            onTap: () {
              setState(() => selectedPlan = plan['id'] as String);
              widget.onUpdate?.call({'selectedPlan': plan['id'] as String});
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : isPremium
                          ? const Color(0xFFFBBF24)
                          : AppColors.border,
                  width: isSelected ? 2 : isPremium ? 1.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: 2,
                            ),
                            color: isSelected ? AppColors.primary : Colors.white,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 12, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          plan['icon'] as IconData,
                          size: 20,
                          color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            plan['title'] as String,
                            style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (plan['badge'] != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              plan['badge'] as String,
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        if (plan['badge'] != null) const SizedBox(width: 8),
                        if (plan['price'] != null)
                          Text(
                            plan['price'] as String,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else
                          Text(
                            'Free',
                            style: AppTypography.labelMedium.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isSelected) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.04),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: (plan['features'] as List<String>).map((feature) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                feature,
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
