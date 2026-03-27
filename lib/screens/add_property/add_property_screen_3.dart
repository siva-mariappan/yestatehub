import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

class AddPropertyScreen3 extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onUpdate;

  const AddPropertyScreen3({
    super.key,
    required this.data,
    required this.onUpdate,
  });

  @override
  State<AddPropertyScreen3> createState() => _AddPropertyScreen3State();
}

class _AddPropertyScreen3State extends State<AddPropertyScreen3> {
  late TextEditingController _priceController;
  late TextEditingController _monthlyRentController;
  late TextEditingController _depositController;
  late TextEditingController _maintenanceController;
  late TextEditingController _pricePerSqftController;
  late TextEditingController _udsController;
  late TextEditingController _maxOccupancyController;
  late TextEditingController _ceilingHeightController;
  late TextEditingController _leaseAmountController;
  late TextEditingController _rentEscalationController;

  late bool _negotiable;
  late bool _hasLease;
  late bool _foodIncluded;
  late bool _maintenanceIncluded;
  late bool _roadFacing;
  late bool _truckAccess;
  late bool _fireSafety;
  late bool _registrationRequired;

  late String? _selectedBuildingAge;
  late String? _selectedPossession;
  late String? _selectedLeaseStatus;
  late String? _selectedLeaseDuration;
  late String? _selectedLockInPeriod;
  late String? _selectedNoticePeriod;
  late String? _selectedLeaseType;
  late String? _selectedOccupancyStatus;
  late String? _selectedFloorLevel;
  late DateTime? _leaseStartDate;

  late List<String> _selectedTenantPreferences;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: widget.data['price']?.toString() ?? '');
    _monthlyRentController = TextEditingController(text: widget.data['monthlyRent']?.toString() ?? '');
    _depositController = TextEditingController(text: widget.data['deposit']?.toString() ?? '');
    _maintenanceController = TextEditingController(text: widget.data['maintenance']?.toString() ?? '');
    _pricePerSqftController = TextEditingController(text: widget.data['pricePerSqft']?.toString() ?? '');
    _udsController = TextEditingController(text: widget.data['uds']?.toString() ?? '');
    _maxOccupancyController = TextEditingController(text: widget.data['maxOccupancy']?.toString() ?? '');
    _ceilingHeightController = TextEditingController(text: widget.data['ceilingHeight']?.toString() ?? '');

    _negotiable = widget.data['negotiable'] ?? false;
    _hasLease = widget.data['hasLease'] ?? false;
    _foodIncluded = widget.data['foodIncluded'] ?? false;
    _maintenanceIncluded = widget.data['maintenanceIncluded'] ?? false;
    _roadFacing = widget.data['roadFacing'] ?? false;
    _truckAccess = widget.data['truckAccess'] ?? false;
    _fireSafety = widget.data['fireSafety'] ?? false;
    _registrationRequired = widget.data['registrationRequired'] ?? false;

    _selectedBuildingAge = widget.data['buildingAge'];
    _selectedPossession = widget.data['possession'];
    _selectedLeaseStatus = widget.data['leaseStatus'];
    _selectedTenantPreferences = List<String>.from(widget.data['tenantPreferences'] ?? []);

    final leaseDetails = widget.data['leaseDetails'] as Map<String, dynamic>? ?? {};
    _leaseAmountController = TextEditingController(text: leaseDetails['overallAmount']?.toString() ?? '');
    _rentEscalationController = TextEditingController(text: leaseDetails['rentEscalation']?.toString() ?? '');
    _selectedLeaseDuration = leaseDetails['duration'];
    _selectedLockInPeriod = leaseDetails['lockInPeriod'];
    _selectedNoticePeriod = leaseDetails['noticePeriod'];
    _selectedLeaseType = leaseDetails['leaseType'];
    _selectedOccupancyStatus = leaseDetails['occupancyStatus'];
    _leaseStartDate = leaseDetails['startDate'] != null ? DateTime.parse(leaseDetails['startDate']) : null;
    _registrationRequired = leaseDetails['registrationRequired'] ?? false;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _monthlyRentController.dispose();
    _depositController.dispose();
    _maintenanceController.dispose();
    _pricePerSqftController.dispose();
    _udsController.dispose();
    _maxOccupancyController.dispose();
    _ceilingHeightController.dispose();
    _leaseAmountController.dispose();
    _rentEscalationController.dispose();
    super.dispose();
  }

  void _updateData(Map<String, dynamic> updates) {
    widget.onUpdate(updates);
  }

  bool _isSell() => widget.data['purpose'] == 'Sell';
  bool _isRent() => widget.data['purpose'] == 'Rent';

  String? _getPropertyType() => widget.data['propertyType'];

  bool _showBuildingAge() {
    final type = _getPropertyType();
    return ['Flat', 'House', 'Villa', 'Complex', 'Commercial Building'].contains(type);
  }

  bool _showMaintenanceForSell() {
    return _getPropertyType() == 'Flat';
  }

  bool _showPricePerSqft() {
    final type = _getPropertyType();
    return ['Plot/Land', 'Commercial Land'].contains(type);
  }

  bool _showUds() {
    return _getPropertyType() == 'Flat';
  }

  bool _showPossessionForSell() {
    final type = _getPropertyType();
    return ['Plot', 'Commercial Land', 'Flat', 'House', 'Villa'].contains(type);
  }

  bool _showLeaseStatus() {
    return _getPropertyType() == 'Commercial Building';
  }

  bool _showMaintenanceForRent() {
    final type = _getPropertyType();
    return ['Flat', 'Villa', 'Independent Floor', 'Commercial Building/Office'].contains(type);
  }

  bool _showPossessionForRent() {
    return _getPropertyType() != 'Warehouse';
  }

  bool _showLeaseToggle() {
    final type = _getPropertyType();
    return [
      'Flat',
      'House',
      'Villa',
      'Independent Floor',
      'Commercial Building/Office',
      'Shop/Showroom',
      'Warehouse'
    ].contains(type);
  }

  bool _showTenantPreferences() {
    final type = _getPropertyType();
    return [
      'Flat',
      'House',
      'Villa',
      'Independent Floor',
      'PG/Hostel',
      'Shared Room'
    ].contains(type);
  }

  List<String> _getTenantPreferenceOptions() {
    final type = _getPropertyType();
    if (['PG/Hostel', 'Shared Room'].contains(type)) {
      return ['Students', 'Professionals', 'Male', 'Female', 'Anyone'];
    }
    return ['Bachelors', 'Family', 'Couples'];
  }

  bool _showFoodIncluded() {
    return _getPropertyType() == 'PG/Hostel';
  }

  bool _showMaintenanceIncluded() {
    return _getPropertyType() == 'PG/Hostel';
  }

  bool _showMaxOccupancy() {
    return _getPropertyType() == 'Shared Room';
  }

  bool _showFloorLevel() {
    return _getPropertyType() == 'Shop/Showroom';
  }

  bool _showRoadFacing() {
    return _getPropertyType() == 'Shop/Showroom';
  }

  bool _showCeilingHeight() {
    return _getPropertyType() == 'Warehouse';
  }

  bool _showTruckAccess() {
    return _getPropertyType() == 'Warehouse';
  }

  bool _showFireSafety() {
    return _getPropertyType() == 'Warehouse';
  }

  Widget _buildToggleButtons(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  onChanged(true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: value ? AppColors.primary : AppColors.surface,
                    border: Border.all(
                      color: value ? AppColors.primary : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Yes',
                      style: AppTypography.labelLarge.copyWith(
                        color: value ? AppColors.surface : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  onChanged(false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !value ? AppColors.primary : AppColors.surface,
                    border: Border.all(
                      color: !value ? AppColors.primary : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'No',
                      style: AppTypography.labelLarge.copyWith(
                        color: !value ? AppColors.surface : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionChips(
    String label,
    List<String> options,
    String? selectedValue,
    Function(String) onSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () {
                onSelected(option);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  option,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.surface : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultiSelectChips(
    String label,
    List<String> options,
    List<String> selectedValues,
    Function(String) onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelLarge),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            return GestureDetector(
              onTap: () {
                onToggle(option);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  option,
                  style: AppTypography.labelMedium.copyWith(
                    color: isSelected ? AppColors.surface : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── SELL SECTION ───────────────────────────────────────
          if (_isSell()) ...[
            Text('Pricing & Details', style: AppTypography.headingMedium),
            const SizedBox(height: 20),
            // Expected Price
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Expected Price',
                hintText: 'e.g. 7500000',
                prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primary),
                prefixText: '₹ ',
                prefixStyle: AppTypography.bodyLarge.copyWith(color: AppColors.primary),
              ),
              onChanged: (v) => _updateData({'price': v}),
            ),
            const SizedBox(height: 20),
            // Fair value info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Set a competitive price based on market rates in your area',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.info),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Price Negotiable
            _buildToggleButtons(
              'Price Negotiable',
              _negotiable,
              (val) {
                setState(() => _negotiable = val);
                _updateData({'negotiable': val});
              },
            ),
            const SizedBox(height: 20),
            // Price Per Sqft (Plot/Land, Commercial Land)
            if (_showPricePerSqft()) ...[
              TextField(
                controller: _pricePerSqftController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Price Per Sqft',
                  hintText: 'e.g. 5000',
                  prefixText: '₹ ',
                  prefixStyle: AppTypography.bodyLarge.copyWith(color: AppColors.primary),
                ),
                onChanged: (v) => _updateData({'pricePerSqft': v}),
              ),
              const SizedBox(height: 20),
            ],
            // UDS - Sqft (Flat)
            if (_showUds()) ...[
              TextField(
                controller: _udsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'UDS (Sqft)',
                  hintText: 'e.g. 1200',
                  suffixText: 'sqft',
                ),
                onChanged: (v) => _updateData({'uds': v}),
              ),
              const SizedBox(height: 20),
            ],
            // Building Age (Flat, House, Villa, Complex, Commercial Building)
            if (_showBuildingAge()) ...[
              _buildSelectionChips(
                'Age of Property',
                ['< 5 years', '5–10 years', '10–15 years', '15–20 years', '20+ years'],
                _selectedBuildingAge,
                (val) {
                  setState(() => _selectedBuildingAge = val);
                  _updateData({'buildingAge': val});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Maintenance (Flat only)
            if (_showMaintenanceForSell()) ...[
              TextField(
                controller: _maintenanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Maintenance',
                  hintText: 'e.g. 3000',
                  prefixText: '₹ ',
                  prefixStyle: AppTypography.bodyLarge.copyWith(color: AppColors.primary),
                  suffixText: '/month',
                ),
                onChanged: (v) => _updateData({'maintenance': v}),
              ),
              const SizedBox(height: 20),
            ],
            // Possession (Plot, Commercial Land, Flat, House, Villa)
            if (_showPossessionForSell()) ...[
              _buildSelectionChips(
                'Possession',
                [
                  'Immediate',
                  'Within 1 Month',
                  'Within 3 Months',
                  'Within 6 Months',
                  'After 1 Year'
                ],
                _selectedPossession,
                (val) {
                  setState(() => _selectedPossession = val);
                  _updateData({'possession': val});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Lease Status (Commercial Building only)
            if (_showLeaseStatus()) ...[
              _buildSelectionChips(
                'Lease Status',
                ['Vacant', 'Occupied', 'Leased'],
                _selectedLeaseStatus,
                (val) {
                  setState(() => _selectedLeaseStatus = val);
                  _updateData({'leaseStatus': val});
                },
              ),
              const SizedBox(height: 20),
            ],
          ],

          // ─── RENT SECTION ───────────────────────────────────────
          if (_isRent()) ...[
            Text('Pricing & Details', style: AppTypography.headingMedium),
            const SizedBox(height: 20),
            // Monthly Rent
            TextField(
              controller: _monthlyRentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Monthly Rent',
                hintText: 'e.g. 25000',
                prefixText: '₹ ',
                prefixStyle: AppTypography.bodyLarge.copyWith(color: AppColors.primary),
              ),
              onChanged: (v) => _updateData({'monthlyRent': v}),
            ),
            const SizedBox(height: 20),
            // Price Negotiable
            _buildToggleButtons(
              'Price Negotiable',
              _negotiable,
              (val) {
                setState(() => _negotiable = val);
                _updateData({'negotiable': val});
              },
            ),
            const SizedBox(height: 20),
            // Security Deposit
            TextField(
              controller: _depositController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Security Deposit',
                hintText: 'e.g. 50000',
                prefixText: '₹ ',
                prefixStyle: AppTypography.bodyLarge.copyWith(color: AppColors.primary),
              ),
              onChanged: (v) => _updateData({'deposit': v}),
            ),
            const SizedBox(height: 20),
            // Maintenance (Flat, Villa, Independent Floor, Commercial Building/Office)
            if (_showMaintenanceForRent()) ...[
              TextField(
                controller: _maintenanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Maintenance',
                  hintText: 'e.g. 3000',
                  prefixText: '₹ ',
                  prefixStyle: AppTypography.bodyLarge.copyWith(color: AppColors.primary),
                  suffixText: '/month',
                ),
                onChanged: (v) => _updateData({'maintenance': v}),
              ),
              const SizedBox(height: 20),
            ],
            // Possession (all except Warehouse)
            if (_showPossessionForRent()) ...[
              _buildSelectionChips(
                'Possession',
                [
                  'Immediate',
                  'Within 1 Month',
                  'Within 3 Months',
                  'Within 6 Months',
                  'After 1 Year'
                ],
                _selectedPossession,
                (val) {
                  setState(() => _selectedPossession = val);
                  _updateData({'possession': val});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Lease Toggle
            if (_showLeaseToggle()) ...[
              _buildToggleButtons(
                'Has Lease Agreement',
                _hasLease,
                (val) {
                  setState(() => _hasLease = val);
                  _updateData({'hasLease': val});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Tenant Preferences
            if (_showTenantPreferences()) ...[
              _buildMultiSelectChips(
                'Tenant Preferences',
                _getTenantPreferenceOptions(),
                _selectedTenantPreferences,
                (option) {
                  setState(() {
                    if (_selectedTenantPreferences.contains(option)) {
                      _selectedTenantPreferences.remove(option);
                    } else {
                      _selectedTenantPreferences.add(option);
                    }
                  });
                  _updateData({'tenantPreferences': _selectedTenantPreferences});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Food Included (PG/Hostel only)
            if (_showFoodIncluded()) ...[
              _buildToggleButtons(
                'Food Included',
                _foodIncluded,
                (val) {
                  setState(() => _foodIncluded = val);
                  _updateData({'foodIncluded': val});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Maintenance Included (PG/Hostel only)
            if (_showMaintenanceIncluded()) ...[
              _buildToggleButtons(
                'Maintenance Included',
                _maintenanceIncluded,
                (val) {
                  setState(() => _maintenanceIncluded = val);
                  _updateData({'maintenanceIncluded': val});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Max Occupancy (Shared Room only)
            if (_showMaxOccupancy()) ...[
              TextField(
                controller: _maxOccupancyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Occupancy',
                  hintText: 'e.g. 2',
                ),
                onChanged: (v) => _updateData({'maxOccupancy': v}),
              ),
              const SizedBox(height: 20),
            ],
            // Floor Level (Shop/Showroom only)
            if (_showFloorLevel()) ...[
              _buildSelectionChips(
                'Floor Level',
                [
                  'Basement',
                  'Ground Floor',
                  '1st Floor',
                  '2nd Floor',
                  '3rd Floor',
                  '4th Floor & Above'
                ],
                _selectedPossession,
                (val) {
                  setState(() => _selectedPossession = val);
                  _updateData({'floorLevel': val});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Road Facing (Shop/Showroom only)
            if (_showRoadFacing()) ...[
              _buildToggleButtons(
                'Road Facing',
                _roadFacing,
                (val) {
                  setState(() => _roadFacing = val);
                  _updateData({'roadFacing': val});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Ceiling Height (Warehouse only)
            if (_showCeilingHeight()) ...[
              TextField(
                controller: _ceilingHeightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Ceiling Height',
                  hintText: 'e.g. 15',
                  suffixText: 'ft',
                ),
                onChanged: (v) => _updateData({'ceilingHeight': v}),
              ),
              const SizedBox(height: 20),
            ],
            // Truck Access (Warehouse only)
            if (_showTruckAccess()) ...[
              _buildToggleButtons(
                'Truck Access',
                _truckAccess,
                (val) {
                  setState(() => _truckAccess = val);
                  _updateData({'truckAccess': val});
                },
              ),
              const SizedBox(height: 20),
            ],
            // Fire Safety (Warehouse only)
            if (_showFireSafety()) ...[
              _buildToggleButtons(
                'Fire Safety',
                _fireSafety,
                (val) {
                  setState(() => _fireSafety = val);
                  _updateData({'fireSafety': val});
                },
              ),
              const SizedBox(height: 20),
            ],

            // ─── LEASE DETAILS SECTION ─────────────────────────────
            if (_hasLease) ...[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                      ),
                      child: Text(
                        'Lease Details',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.primaryDark),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Lease Duration
                          _buildSelectionChips(
                            'Lease Duration',
                            ['1 Year', '2 Years', '3 Years', '5 Years', 'Custom'],
                            _selectedLeaseDuration,
                            (val) {
                              setState(() => _selectedLeaseDuration = val);
                              final leaseDetails = Map<String, dynamic>.from(
                                widget.data['leaseDetails'] ?? {},
                              );
                              leaseDetails['duration'] = val;
                              _updateData({'leaseDetails': leaseDetails});
                            },
                          ),
                          const SizedBox(height: 20),
                          // Lock-In Period
                          _buildSelectionChips(
                            'Lock-In Period',
                            ['6 Months', '12 Months', '24 Months'],
                            _selectedLockInPeriod,
                            (val) {
                              setState(() => _selectedLockInPeriod = val);
                              final leaseDetails = Map<String, dynamic>.from(
                                widget.data['leaseDetails'] ?? {},
                              );
                              leaseDetails['lockInPeriod'] = val;
                              _updateData({'leaseDetails': leaseDetails});
                            },
                          ),
                          const SizedBox(height: 20),
                          // Notice Period
                          _buildSelectionChips(
                            'Notice Period',
                            ['1 Month', '2 Months', '3 Months', '6 Months'],
                            _selectedNoticePeriod,
                            (val) {
                              setState(() => _selectedNoticePeriod = val);
                              final leaseDetails = Map<String, dynamic>.from(
                                widget.data['leaseDetails'] ?? {},
                              );
                              leaseDetails['noticePeriod'] = val;
                              _updateData({'leaseDetails': leaseDetails});
                            },
                          ),
                          const SizedBox(height: 20),
                          // Lease Type
                          _buildSelectionChips(
                            'Lease Type',
                            ['Gross Lease', 'Net Lease', 'Semi-Gross Lease'],
                            _selectedLeaseType,
                            (val) {
                              setState(() => _selectedLeaseType = val);
                              final leaseDetails = Map<String, dynamic>.from(
                                widget.data['leaseDetails'] ?? {},
                              );
                              leaseDetails['leaseType'] = val;
                              _updateData({'leaseDetails': leaseDetails});
                            },
                          ),
                          const SizedBox(height: 20),
                          // Occupancy Status
                          _buildSelectionChips(
                            'Occupancy Status',
                            ['Vacant', 'Pre-Leased'],
                            _selectedOccupancyStatus,
                            (val) {
                              setState(() => _selectedOccupancyStatus = val);
                              final leaseDetails = Map<String, dynamic>.from(
                                widget.data['leaseDetails'] ?? {},
                              );
                              leaseDetails['occupancyStatus'] = val;
                              _updateData({'leaseDetails': leaseDetails});
                            },
                          ),
                          const SizedBox(height: 20),
                          // Lease Start Date
                          GestureDetector(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: _leaseStartDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() => _leaseStartDate = pickedDate);
                                final leaseDetails = Map<String, dynamic>.from(
                                  widget.data['leaseDetails'] ?? {},
                                );
                                leaseDetails['startDate'] = pickedDate.toIso8601String();
                                _updateData({'leaseDetails': leaseDetails});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lease Start Date',
                                        style: AppTypography.labelMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _leaseStartDate != null
                                            ? '${_leaseStartDate!.day}/${_leaseStartDate!.month}/${_leaseStartDate!.year}'
                                            : 'Select date',
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: _leaseStartDate != null
                                              ? AppColors.textPrimary
                                              : AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Overall Lease Amount
                          TextField(
                            controller: _leaseAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Overall Lease Amount',
                              hintText: 'e.g. 300000',
                              prefixText: '₹ ',
                              prefixStyle:
                                  AppTypography.bodyLarge.copyWith(color: AppColors.primary),
                            ),
                            onChanged: (v) {
                              final leaseDetails = Map<String, dynamic>.from(
                                widget.data['leaseDetails'] ?? {},
                              );
                              leaseDetails['overallAmount'] = v;
                              _updateData({'leaseDetails': leaseDetails});
                            },
                          ),
                          const SizedBox(height: 20),
                          // Rent Escalation
                          TextField(
                            controller: _rentEscalationController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Rent Escalation',
                              hintText: 'e.g. 5',
                              suffixText: '%',
                            ),
                            onChanged: (v) {
                              final leaseDetails = Map<String, dynamic>.from(
                                widget.data['leaseDetails'] ?? {},
                              );
                              leaseDetails['rentEscalation'] = v;
                              _updateData({'leaseDetails': leaseDetails});
                            },
                          ),
                          const SizedBox(height: 20),
                          // Registration Required
                          _buildToggleButtons(
                            'Registration Required',
                            _registrationRequired,
                            (val) {
                              setState(() => _registrationRequired = val);
                              final leaseDetails = Map<String, dynamic>.from(
                                widget.data['leaseDetails'] ?? {},
                              );
                              leaseDetails['registrationRequired'] = val;
                              _updateData({'leaseDetails': leaseDetails});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ],
      ),
    );
  }
}
