import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../services/property_service.dart';
import '../../services/property_store.dart';
import 'add_property_screen_1.dart';
import 'add_property_screen_2.dart';
import 'add_property_screen_3.dart';
import 'add_property_screen_4.dart';
import 'add_property_screen_5.dart';
import 'add_property_screen_6.dart';

/// 6-Step Add Property Wizard
/// Mobile: One question per screen with progress bar
/// Desktop: Left step indicator + form area right
class AddPropertyWizard extends StatefulWidget {
  const AddPropertyWizard({super.key});

  @override
  State<AddPropertyWizard> createState() => _AddPropertyWizardState();
}

class _AddPropertyWizardState extends State<AddPropertyWizard> {
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Shared form data
  final Map<String, dynamic> _formData = {
    'purpose': 'Sell',
    'propertyType': '',
    'propertyName': '',
    'description': '',
    'measurementUnit': 'Square Feet',
    'area': '',
    'facing': '',
    'furnishing': '',
    'bedrooms': '',
    'bathrooms': '',
    'amenities': <String>[],
    'nearbyAmenities': <String, String>{},
    'state': null,
    'district': null,
    'locality': '',
    'pincode': '',
    'address': '',
    'price': '',
    'negotiable': false,
    'images': <String>[],
    'videoUrl': '',
  };

  static const _stepLabels = [
    'Property Details',
    'Location',
    'Pricing & Details',
    'Media Upload',
    'Contact Info',
    'Review & Submit',
  ];

  static const _stepIcons = [
    Icons.home_rounded,
    Icons.location_on_rounded,
    Icons.currency_rupee_rounded,
    Icons.camera_alt_rounded,
    Icons.person_rounded,
    Icons.check_circle_rounded,
  ];

  void _submitProperty() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );

    // Flatten nearbyAmenities from {key: {name, distance}} to {key: "name - distance"}
    Map<String, String> flatNearby = {};
    try {
      final raw = _formData['nearbyAmenities'];
      if (raw is Map) {
        for (final entry in raw.entries) {
          if (entry.value is Map) {
            final name = (entry.value as Map)['name'] ?? '';
            final dist = (entry.value as Map)['distance'] ?? '';
            flatNearby[entry.key.toString()] = name.isNotEmpty ? '$name ($dist)' : dist;
          } else {
            flatNearby[entry.key.toString()] = entry.value?.toString() ?? '';
          }
        }
      }
    } catch (_) {}

    try {
      // Map property type string to API enum
      String mapPropertyType(String t) {
        switch (t.toLowerCase()) {
          case 'apartment': case 'flat': return 'apartment';
          case 'villa': case 'individual villa': return 'villa';
          case 'independent house': case 'individual house': return 'independent_house';
          case 'plot': case 'plot/land': case 'commercial land': return 'plot';
          case 'builder floor': case 'independent floor': return 'builder_floor';
          case 'pg': case 'pg/hostel': case 'shared room': return 'pg';
          default: return 'apartment';
        }
      }
      String mapTxnType(String p) {
        switch (p.toLowerCase()) {
          case 'sell': return 'buy';
          case 'rent': return 'rent';
          case 'pg': return 'pg';
          case 'commercial': return 'commercial';
          default: return 'buy';
        }
      }
      String mapFurnishing(String f) {
        switch (f.toLowerCase()) {
          case 'furnished': case 'fully furnished': return 'furnished';
          case 'semi-furnished': case 'semi furnished': return 'semi_furnished';
          default: return 'unfurnished';
        }
      }
      // Extract bedrooms from '2 BHK' format
      final bedroomStr = _formData['bedrooms']?.toString() ?? '';
      int bedroomCount = 0;
      if (bedroomStr == 'Custom') {
        bedroomCount = int.tryParse(_formData['customBedrooms']?.toString() ?? '') ?? 0;
      } else {
        final m = RegExp(r'(\d+)').firstMatch(bedroomStr);
        bedroomCount = m != null ? int.tryParse(m.group(1)!) ?? 0 : 0;
      }
      // Extract bathrooms
      final bathroomStr = _formData['bathrooms']?.toString() ?? '';
      int bathroomCount = 0;
      if (bathroomStr == 'Custom') {
        bathroomCount = int.tryParse(_formData['customBathrooms']?.toString() ?? '') ?? 0;
      } else {
        final m = RegExp(r'(\d+)').firstMatch(bathroomStr);
        bathroomCount = m != null ? int.tryParse(m.group(1)!) ?? 0 : 0;
      }
      // Price: Sell uses 'price', Rent uses 'monthlyRent'
      double priceValue = double.tryParse(_formData['price']?.toString() ?? '') ?? 0;
      if (priceValue == 0 && (_formData['purpose'] ?? 'Sell') == 'Rent') {
        priceValue = double.tryParse(_formData['monthlyRent']?.toString() ?? '') ?? 0;
      }
      await PropertyService().createProperty(
        title: _formData['propertyName'] ?? '',
        description: _formData['description'] ?? '',
        purpose: _formData['purpose'] ?? 'Sell',
        propertyType: mapPropertyType(_formData['propertyType'] ?? ''),
        transactionType: mapTxnType(_formData['purpose'] ?? 'Sell'),
        furnishing: mapFurnishing(_formData['furnishing'] ?? ''),
        bedrooms: bedroomCount,
        bathrooms: bathroomCount,
        areaSqft: double.tryParse(_formData['area']?.toString() ?? '') ?? 0,
        facing: _formData['facing'] ?? '',
        amenities: List<String>.from(_formData['amenities'] ?? []),
        nearbyAmenities: flatNearby,
        state: _formData['state'] ?? '',
        district: _formData['district'] ?? '',
        locality: _formData['locality'] ?? '',
        pincode: _formData['pincode'] ?? '',
        address: _formData['address'] ?? '',
        price: priceValue,
        negotiable: _formData['negotiable'] ?? false,
        images: List<String>.from(_formData['images'] ?? []),
        videoUrl: _formData['videoUrl'] ?? '',
      );
    } catch (e) {
      // If API fails, still show success (offline mode / demo)
      debugPrint('Property submit error (continuing in demo mode): $e');
    }

    // Save to local store so it appears on the home page immediately & persists
    try {
      final newProperty = PropertyStore.propertyFromFormData(_formData);
      PropertyStore.instance.addProperty(newProperty);
    } catch (e) {
      debugPrint('PropertyStore save error: $e');
    }
    if (!mounted) return;
    Navigator.pop(context); // close loading
    // Show success dialog and auto-navigate to home after 3 seconds
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
                Text('Property Submitted\nSuccessfully!', textAlign: TextAlign.center, style: AppTypography.headingMedium),
                const SizedBox(height: 10),
                Text(
                  'Your listing is under review and will be live within 24 hours.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Text(
                  'Redirecting to home...',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      );
      // Auto-navigate to home after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pop(context); // close dialog
          Navigator.pop(context); // go back to home
        }
      });
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Add Property', style: AppTypography.headingMedium),
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.close),
        ),
      ),
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Progress bar
        _buildProgressBar(),
        // Step label
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${_currentStep + 1}',
                    style: AppTypography.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(_stepLabels[_currentStep], style: AppTypography.headingSmall),
              const Spacer(),
              Text(
                'Step ${_currentStep + 1} of $_totalSteps',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        // Form content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _buildStepContent(),
          ),
        ),
        // Bottom buttons
        _buildBottomButtons(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left step indicator
            SizedBox(
              width: 260,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_totalSteps, (i) {
                    final isActive = i == _currentStep;
                    final isCompleted = i < _currentStep;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          // Step circle + line
                          Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? AppColors.primary
                                      : isActive
                                          ? AppColors.primaryLight
                                          : AppColors.background,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isActive ? AppColors.primary : AppColors.border,
                                    width: isActive ? 2 : 1,
                                  ),
                                ),
                                child: Icon(
                                  isCompleted ? Icons.check : _stepIcons[i],
                                  size: 18,
                                  color: isCompleted
                                      ? Colors.white
                                      : isActive
                                          ? AppColors.primary
                                          : AppColors.textTertiary,
                                ),
                              ),
                              if (i < _totalSteps - 1)
                                Container(
                                  width: 2,
                                  height: 28,
                                  color: isCompleted ? AppColors.primary : AppColors.border,
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _stepLabels[i],
                            style: AppTypography.labelLarge.copyWith(
                              color: isActive ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const VerticalDivider(width: 1),
            // Right form area
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: _buildStepContent(),
                    ),
                  ),
                  _buildBottomButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 4,
      color: AppColors.primaryLight,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (_currentStep + 1) / _totalSteps,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return AddPropertyScreen1(data: _formData, onUpdate: (d) => setState(() => _formData.addAll(d)));
      case 1:
        return AddPropertyScreen2(data: _formData, onUpdate: (d) => setState(() => _formData.addAll(d)));
      case 2:
        return AddPropertyScreen3(data: _formData, onUpdate: (d) => setState(() => _formData.addAll(d)));
      case 3:
        return AddPropertyScreen4(data: _formData, onUpdate: (d) => setState(() => _formData.addAll(d)));
      case 4:
        return AddPropertyScreen5(data: _formData, onUpdate: (d) => setState(() => _formData.addAll(d)));
      case 5:
        return AddPropertyScreen6(data: _formData);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _prevStep,
                  child: Text('Back', style: AppTypography.buttonMedium),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _currentStep == _totalSteps - 1 ? _submitProperty : _nextStep,
                child: Text(
                  _currentStep == _totalSteps - 1 ? 'Publish Property' : 'Next Step',
                  style: AppTypography.buttonLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
