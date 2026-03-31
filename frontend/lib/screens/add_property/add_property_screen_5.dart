import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // OTP controllers
  late List<TextEditingController> otpControllers;
  late List<FocusNode> otpFocusNodes;

  bool whatsappSameAsMobile = true;
  String selectedExperience = '1–3 years';
  String selectedProjectsCompleted = '1–5';

  // OTP Verification (inline)
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

    otpControllers = List.generate(4, (_) => TextEditingController());
    otpFocusNodes = List.generate(4, (_) => FocusNode());

    // Push contact data back to wizard whenever fields change
    contactNameController.addListener(_syncContactData);
    mobileNumberController.addListener(_syncContactData);
    emailController.addListener(_syncContactData);
  }

  void _syncContactData() {
    widget.onUpdate?.call({
      'contactName': contactNameController.text,
      'contactPhone': mobileNumberController.text,
      'contactEmail': emailController.text,
    });
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
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _sendOtp() {
    if (mobileNumberController.text.length < 10) return;
    setState(() {
      isOtpSent = true;
      otpTimer = 60;
      // Clear OTP fields
      for (final c in otpControllers) {
        c.clear();
      }
    });
    _startOtpTimer();
    // Focus the first OTP box
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) otpFocusNodes[0].requestFocus();
    });
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
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 4) return;
    // Mock verification — always succeeds
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

          // Contact Details Section (with inline OTP)
          _buildContactDetailsSection(),
          const SizedBox(height: 24),

          // Subscription Plan Section
          _buildSubscriptionPlansSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─── Listed By ──────────────────────────────────────────────
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

  // ─── Contact Details (with inline mobile verification) ──────
  Widget _buildContactDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contact Details', style: AppTypography.headingSmall),
        const SizedBox(height: 12),
        _buildTextField('Contact Name *', contactNameController, 'Enter your name'),
        const SizedBox(height: 12),

        // ── Mobile Number with inline verification ──
        _buildMobileWithVerification(),
        const SizedBox(height: 12),

        _buildTextField('Email', emailController, 'your.email@example.com'),
        const SizedBox(height: 12),
        _buildWhatsappSection(),
        const SizedBox(height: 12),

        // Agent-specific fields
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

  // ─── Single Mobile Field + Inline OTP ───────────────────────
  Widget _buildMobileWithVerification() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number *',
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),

        // Phone input row with Send OTP / Verified badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone field
            Expanded(
              child: TextField(
                controller: mobileNumberController,
                keyboardType: TextInputType.number,
                style: AppTypography.bodyMedium,
                maxLength: 10,
                enabled: !isOtpVerified,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '9876543210',
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    width: 64,
                    child: Text(
                      '+91',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isOtpVerified ? Colors.green.shade400 : AppColors.border,
                      width: isOtpVerified ? 1.5 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
                  ),
                  filled: isOtpVerified,
                  fillColor: isOtpVerified ? Colors.green.shade50 : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  counterText: '',
                  suffixIcon: isOtpVerified
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 22),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Send OTP / Verified button
            if (isOtpVerified)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_rounded, color: Colors.green.shade700, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: mobileNumberController.text.length == 10 && !isOtpSent
                      ? _sendOtp
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(
                    isOtpSent ? 'OTP Sent' : 'Send OTP',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // ── Inline OTP section (appears after Send OTP) ──
        if (isOtpSent && !isOtpVerified) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sms_outlined, color: Color(0xFFF97316), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'OTP sent to +91 ${mobileNumberController.text}',
                          style: AppTypography.bodySmall.copyWith(
                            color: const Color(0xFF9A3412),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // OTP label
                Text(
                  'Enter 4-digit verification code',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),

                // OTP input boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(4, (index) {
                    return Container(
                      margin: EdgeInsets.only(right: index < 3 ? 12 : 0),
                      width: 52,
                      height: 52,
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          filled: otpControllers[index].text.isNotEmpty,
                          fillColor: AppColors.primary.withOpacity(0.05),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            otpFocusNodes[index + 1].requestFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            otpFocusNodes[index - 1].requestFocus();
                          }
                          setState(() {});
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 14),

                // Timer / Resend + Verify button row
                Row(
                  children: [
                    // Timer or resend
                    if (otpTimer > 0) ...[
                      Icon(Icons.timer_outlined, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        'Resend in ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '00:${otpTimer.toString().padLeft(2, '0')}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ] else
                      GestureDetector(
                        onTap: _sendOtp,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Resend OTP',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Verify button
                    SizedBox(
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: otpControllers.every((c) => c.text.isNotEmpty)
                            ? _verifyOtp
                            : null,
                        icon: const Icon(Icons.verified_user_outlined, size: 16, color: Colors.white),
                        label: Text(
                          'Verify',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  // ─── Subscription Plans ─────────────────────────────────────
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
