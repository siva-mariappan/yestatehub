import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

class SignUpScreen extends StatefulWidget {
  final void Function(bool isServiceProvider) onSignUpSuccess;
  const SignUpScreen({super.key, required this.onSignUpSuccess});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  int _selectedType = 0; // 0 = User, 1 = Service Provider
  String _selectedRole = 'Buyer';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to Terms & Privacy Policy'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        // Show success then navigate
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryExtraLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 20),
                  Text('Account Created!', style: AppTypography.headingMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to YEstateHub! Your account has been created successfully.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pop(context); // close dialog
            widget.onSignUpSuccess(_selectedType == 1);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(isTablet),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left — branding panel
        Expanded(
          flex: 5,
          child: _buildBrandingPanel(),
        ),
        // Right — signup form
        Expanded(
          flex: 4,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _buildSignUpForm(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isTablet) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMobileHeader(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 80 : 24,
              vertical: 24,
            ),
            child: _buildSignUpForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandingPanel() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Join YEstateHub',
                    style: AppTypography.displayMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create your account and start\nexploring properties today.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Benefits
                  _buildBenefitRow(Icons.search_rounded, 'Search thousands of properties'),
                  const SizedBox(height: 16),
                  _buildBenefitRow(Icons.favorite_rounded, 'Save & compare your favorites'),
                  const SizedBox(height: 16),
                  _buildBenefitRow(Icons.sell_rounded, 'List your property for free'),
                  const SizedBox(height: 16),
                  _buildBenefitRow(Icons.chat_rounded, 'Connect directly with owners'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Text(text, style: AppTypography.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9))),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Back button row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            'Create Account',
            style: AppTypography.headingLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Join YEstateHub to explore properties',
            style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.85)),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Desktop heading
          if (MediaQuery.of(context).size.width >= 900) ...[
            Text('Create Account', style: AppTypography.displaySmall),
            const SizedBox(height: 6),
            Text(
              'Fill in your details to get started',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
          ],

          // User / Service Provider toggle
          _buildUserTypeToggle(),
          const SizedBox(height: 22),

          // Role selector (changes based on type)
          Text(_selectedType == 0 ? 'I am a' : 'Service Type', style: AppTypography.labelMedium),
          const SizedBox(height: 10),
          Row(
            children: (_selectedType == 0
                    ? ['Buyer', 'Owner', 'Agent']
                    : ['Cleaning', 'Painting', 'Repair'])
                .map((role) {
              final isSelected = _selectedRole == role;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: role != (_selectedType == 0 ? 'Agent' : 'Repair') ? 10 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRole = role),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 46,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getRoleIcon(role),
                              size: 18,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              role,
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // Full Name
          Text('Full Name', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline_rounded,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your name';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Email
          Text('Email Address', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              hint: 'Enter your email address',
              prefixIcon: Icons.email_outlined,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Phone
          Text('Phone Number', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(
              hint: 'Enter your phone number',
              prefixIcon: Icons.phone_outlined,
              prefixWidget: Container(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇮🇳', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text('+91', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 24, color: AppColors.border),
                  ],
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your phone number';
              if (v.length < 10) return 'Enter a valid 10-digit number';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Password
          Text('Password', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _inputDecoration(
              hint: 'Create a strong password',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please create a password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Confirm Password
          Text('Confirm Password', style: AppTypography.labelMedium),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration: _inputDecoration(
              hint: 'Re-enter your password',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _passwordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 22),

          // Terms checkbox
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _agreedToTerms,
                    onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.5),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTypography.bodySmall.copyWith(
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
          ),
          const SizedBox(height: 24),

          // Sign Up button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text('Create Account', style: AppTypography.buttonLarge.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or sign up with', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 24),

          // Social signup
          SizedBox(
            width: double.infinity,
            child: _buildSocialButton(Icons.g_mobiledata_rounded, 'Google', const Color(0xFFEA4335)),
          ),
          const SizedBox(height: 28),

          // Already have account
          Center(
            child: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign In',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Buyer':
        return Icons.person_rounded;
      case 'Owner':
        return Icons.home_rounded;
      case 'Agent':
        return Icons.support_agent_rounded;
      case 'Cleaning':
        return Icons.cleaning_services_rounded;
      case 'Painting':
        return Icons.format_paint_rounded;
      case 'Repair':
        return Icons.build_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  Widget _buildUserTypeToggle() {
    final types = [
      {'label': 'User', 'icon': Icons.person_rounded},
      {'label': 'Service Provider', 'icon': Icons.business_center_rounded},
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(types.length, (i) {
          final isSelected = _selectedType == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _selectedType = i;
                // Reset role when switching type
                _selectedRole = i == 0 ? 'Buyer' : 'Cleaning';
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      types[i]['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      types[i]['label'] as String,
                      style: AppTypography.labelMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color iconColor) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 10),
            Text(label, style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    Widget? prefixWidget,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
      prefixIcon: prefixWidget ?? (prefixIcon != null ? Icon(prefixIcon, color: AppColors.textTertiary, size: 20) : null),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
