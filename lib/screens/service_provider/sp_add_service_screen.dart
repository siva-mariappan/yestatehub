import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';

class SpAddServiceScreen extends StatefulWidget {
  final Map<String, dynamic>? existingService;
  const SpAddServiceScreen({super.key, this.existingService});

  @override
  State<SpAddServiceScreen> createState() => _SpAddServiceScreenState();
}

class _SpAddServiceScreenState extends State<SpAddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'Cleaning';
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isActive = true;
  final List<String> _selectedAreas = ['Hyderabad'];
  int _currentStep = 0;

  bool get _isEditing => widget.existingService != null;

  final _categories = [
    {'name': 'Cleaning', 'icon': Icons.cleaning_services_rounded, 'color': AppColors.primary},
    {'name': 'Painting', 'icon': Icons.format_paint_rounded, 'color': const Color(0xFFF59E0B)},
    {'name': 'Plumbing', 'icon': Icons.plumbing_rounded, 'color': const Color(0xFF8B5CF6)},
    {'name': 'Electrical', 'icon': Icons.electrical_services_rounded, 'color': const Color(0xFFEC4899)},
    {'name': 'Carpentry', 'icon': Icons.carpenter_rounded, 'color': AppColors.info},
    {'name': 'Pest Control', 'icon': Icons.bug_report_rounded, 'color': AppColors.error},
  ];

  final _availableAreas = ['Hyderabad', 'Secunderabad', 'Gachibowli', 'Madhapur', 'Kondapur', 'KPHB', 'Kukatpally', 'Miyapur'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.existingService!;
      _nameController.text = s['name'] ?? '';
      _descController.text = s['desc'] ?? '';
      _selectedCategory = s['category'] ?? 'Cleaning';
      _isActive = s['active'] ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEditing ? 'Edit Service' : 'Add New Service', style: AppTypography.headingMedium),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress steps
                  _buildProgressSteps(),
                  const SizedBox(height: 28),

                  if (_currentStep == 0) ...[
                    // Step 1: Basic Info
                    _buildStepCard(
                      'Service Details',
                      'Choose a category and describe your service',
                      Icons.info_outline_rounded,
                      AppColors.primary,
                      [
                        Text('Category', style: AppTypography.labelMedium),
                        const SizedBox(height: 10),
                        _buildCategorySelector(),
                        const SizedBox(height: 22),
                        _buildTextField('Service Name', _nameController, 'e.g. Premium Home Cleaning', Icons.home_repair_service_rounded),
                        const SizedBox(height: 16),
                        _buildTextField('Description', _descController, 'Describe what\'s included in your service...', Icons.description_rounded, maxLines: 4),
                      ],
                    ),
                  ] else if (_currentStep == 1) ...[
                    // Step 2: Pricing
                    _buildStepCard(
                      'Pricing & Duration',
                      'Set your pricing range and service duration',
                      Icons.payments_rounded,
                      AppColors.info,
                      [
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Min Price (\u20B9)', _minPriceController, '500', Icons.currency_rupee_rounded, isNumber: true)),
                            const SizedBox(width: 14),
                            Expanded(child: _buildTextField('Max Price (\u20B9)', _maxPriceController, '3000', Icons.currency_rupee_rounded, isNumber: true)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField('Avg Duration (hours)', _durationController, '2', Icons.timer_rounded, isNumber: true),
                        const SizedBox(height: 20),
                        // Pricing tips
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.infoLight.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.info.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.info),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tip: Competitive pricing helps you get more bookings. The average rate in your area is \u20B91,200 - \u20B92,500.',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.info, height: 1.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Step 3: Service Areas
                    _buildStepCard(
                      'Service Areas & Status',
                      'Choose where you provide this service',
                      Icons.location_on_rounded,
                      const Color(0xFF8B5CF6),
                      [
                        Text('Service Areas', style: AppTypography.labelMedium),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableAreas.map((area) {
                            final isSelected = _selectedAreas.contains(area);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedAreas.remove(area);
                                  } else {
                                    _selectedAreas.add(area);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      area,
                                      style: AppTypography.labelSmall.copyWith(
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        // Active toggle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _isActive ? AppColors.primaryExtraLight : AppColors.divider,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _isActive ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                  size: 20,
                                  color: _isActive ? AppColors.primary : AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Service Status', style: AppTypography.labelMedium),
                                    const SizedBox(height: 2),
                                    Text(
                                      _isActive ? 'Active — visible to customers' : 'Paused — hidden from customers',
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isActive,
                                onChanged: (v) => setState(() => _isActive = v),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),
                  // Navigation buttons
                  _buildNavigationButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    final steps = ['Details', 'Pricing', 'Areas'];
    return Row(
      children: steps.asMap().entries.map((e) {
        final isActive = e.key <= _currentStep;
        final isCurrent = e.key == _currentStep;
        return Expanded(
          child: Row(
            children: [
              if (e.key > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
              Container(
                width: isCurrent ? 34 : 28,
                height: isCurrent ? 34 : 28,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                  boxShadow: isCurrent
                      ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                      : null,
                ),
                child: Center(
                  child: e.key < _currentStep
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : Text(
                          '${e.key + 1}',
                          style: AppTypography.labelSmall.copyWith(
                            color: isActive ? Colors.white : AppColors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                ),
              ),
              if (e.key < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: e.key < _currentStep ? AppColors.primary : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepCard(String title, String subtitle, IconData icon, Color color, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.headingSmall),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(height: 1, color: AppColors.border.withOpacity(0.5)),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['name'];
        final color = cat['color'] as Color;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat['name'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat['icon'] as IconData, size: 18, color: isSelected ? color : AppColors.textTertiary),
                const SizedBox(width: 8),
                Text(
                  cat['name'] as String,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? color : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, IconData icon, {int maxLines = 1, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: AppTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 18, color: AppColors.textTertiary),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : 0),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => setState(() => _currentStep--),
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text('Previous', style: AppTypography.buttonMedium.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    Navigator.pop(context);
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep < 2 ? 'Continue' : (_isEditing ? 'Save Changes' : 'Add Service'),
                      style: AppTypography.buttonMedium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentStep < 2 ? Icons.arrow_forward_rounded : Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
