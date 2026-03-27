import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

class AddPropertyScreen1 extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onUpdate;

  const AddPropertyScreen1({super.key, required this.data, required this.onUpdate});

  @override
  State<AddPropertyScreen1> createState() => _AddPropertyScreen1State();
}

class _AddPropertyScreen1State extends State<AddPropertyScreen1> {
  late Map<String, dynamic> _localData;

  late List<String> _propertyTypeOptions;
  late String _customBedroomValue;
  late String _customBathroomValue;
  late String _customNumBedsValue;
  late String _customPeoplePerRoomValue;

  final List<String> _sellPropertyTypes = [
    'Plot/Land',
    'Commercial Land',
    'Flat',
    'Individual House',
    'Individual Villa',
    'Complex',
    'Commercial Building'
  ];

  final List<String> _rentPropertyTypes = [
    'Flat',
    'Individual House',
    'Individual Villa',
    'PG/Hostel',
    'Shared Room',
    'Independent Floor',
    'Commercial Building',
    'Office Space',
    'Shop/Showroom',
    'Warehouse/Godown'
  ];

  final List<String> _measurementUnits = [
    'Acres',
    'Cents',
    'Ares',
    'Hectare',
    'Square Feet',
    'Square Meter'
  ];

  final List<String> _facingDirections = [
    'North',
    'South',
    'East',
    'West',
    'North-East',
    'North-West',
    'South-East',
    'South-West'
  ];

  final List<String> _furnishingStatus = [
    'Unfurnished',
    'Semi Furnished',
    'Fully Furnished'
  ];

  final List<String> _furnishingItems = [
    'Beds',
    'Wardrobe',
    'Sofa',
    'Dining Table',
    'TV',
    'AC',
    'Washing Machine',
    'Refrigerator',
    'Geyser',
    'Modular Kitchen'
  ];

  final List<String> _insideAmenities = [
    'Swimming Pool',
    'Parking',
    'Garden',
    'Gym',
    'Lift',
    'Security',
    'CCTV',
    'Water Supply',
    'Piped Gas'
  ];

  final List<String> _nearbyAmenitiesOptions = [
    'School',
    'Hospital',
    'Shopping Mall',
    'Restaurant',
    'Bus Stop',
    'ATM',
    'Pharmacy',
    'Gym',
    'Market',
    'Cinema Hall',
    'Airport',
    'Railway Station',
    'Police Station',
    'Bank',
    'Library',
    'Beach'
  ];

  @override
  void initState() {
    super.initState();
    _localData = Map<String, dynamic>.from(widget.data);
    _propertyTypeOptions = _getPopertyTypeOptions();
    _customBedroomValue = '';
    _customBathroomValue = '';
    _customNumBedsValue = '';
    _customPeoplePerRoomValue = '';
  }

  List<String> _getPopertyTypeOptions() {
    final purpose = _localData['purpose'] ?? 'Sell';
    if (purpose == 'Sell') {
      return _sellPropertyTypes;
    } else {
      return _rentPropertyTypes;
    }
  }

  String _getPropertyNameLabel() {
    final propertyType = _localData['propertyType'] ?? '';
    if (propertyType.contains('Plot') || propertyType.contains('Land')) {
      return 'Plot Name';
    } else if (propertyType.contains('Flat')) {
      return 'Flat Name';
    } else if (propertyType.contains('Villa')) {
      return 'Villa Name';
    } else if (propertyType.contains('House')) {
      return 'House Name';
    } else if (propertyType.contains('Commercial')) {
      return 'Property Name';
    } else if (propertyType.contains('Office')) {
      return 'Office Name';
    } else if (propertyType.contains('Shop') || propertyType.contains('Showroom')) {
      return 'Shop Name';
    } else if (propertyType.contains('Warehouse') || propertyType.contains('Godown')) {
      return 'Warehouse Name';
    }
    return 'Property Name';
  }

  bool _shouldShowBuiltUpArea() {
    final propertyType = _localData['propertyType'] ?? '';
    final purpose = _localData['purpose'] ?? 'Sell';
    if (purpose != 'Sell') return false;

    return propertyType == 'Flat' ||
        propertyType == 'Individual House' ||
        propertyType == 'Individual Villa' ||
        propertyType == 'Complex' ||
        propertyType == 'Commercial Building';
  }

  bool _shouldShowBedrooms() {
    final propertyType = _localData['propertyType'] ?? '';
    return propertyType == 'Flat' ||
        propertyType == 'Individual House' ||
        propertyType == 'Individual Villa';
  }

  bool _shouldShowBathrooms() {
    final propertyType = _localData['propertyType'] ?? '';
    return propertyType == 'Flat' ||
        propertyType == 'Individual House' ||
        propertyType == 'Individual Villa' ||
        propertyType == 'PG/Hostel' ||
        propertyType == 'Shared Room';
  }

  bool _shouldShowFloorNo() {
    final propertyType = _localData['propertyType'] ?? '';
    return propertyType == 'Flat' || propertyType == 'Independent Floor';
  }

  bool _shouldShowTotalFloors() {
    final propertyType = _localData['propertyType'] ?? '';
    return propertyType == 'Flat' ||
        propertyType == 'Individual House' ||
        propertyType == 'Complex' ||
        propertyType == 'Commercial Building' ||
        propertyType == 'Independent Floor';
  }

  bool _shouldShowFurnishing() {
    final propertyType = _localData['propertyType'] ?? '';
    return propertyType == 'Flat' ||
        propertyType == 'Individual House' ||
        propertyType == 'Individual Villa' ||
        propertyType == 'PG/Hostel' ||
        propertyType == 'Shared Room' ||
        propertyType == 'Independent Floor';
  }

  bool _shouldShowNumBeds() {
    final propertyType = _localData['propertyType'] ?? '';
    return propertyType == 'PG/Hostel' || propertyType == 'Shared Room';
  }

  bool _shouldShowPeoplePerRoom() {
    final propertyType = _localData['propertyType'] ?? '';
    return propertyType == 'PG/Hostel' || propertyType == 'Shared Room';
  }

  bool _shouldShowFurnishingItems() {
    final furnishing = _localData['furnishing'] ?? '';
    return furnishing == 'Semi Furnished' || furnishing == 'Fully Furnished';
  }

  bool _shouldShowBoundaries() {
    final propertyType = _localData['propertyType'] ?? '';
    return propertyType == 'Plot/Land' || propertyType == 'Commercial Land';
  }

  void _updateData(Map<String, dynamic> updates) {
    setState(() {
      _localData.addAll(updates);
      if (updates.containsKey('purpose')) {
        _propertyTypeOptions = _getPopertyTypeOptions();
        _localData.remove('propertyType');
      }
    });
    widget.onUpdate(_localData);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Property For',
            child: _buildToggleButtons(
              options: ['Sell', 'Rent'],
              selected: _localData['purpose'] ?? 'Sell',
              onSelect: (v) => _updateData({'purpose': v}),
            ),
          ),
          const SizedBox(height: 20),

          _buildSection(
            title: 'Property Type',
            child: _buildSelectionChips(
              options: _propertyTypeOptions,
              selected: _localData['propertyType'] ?? '',
              onSelect: (v) => _updateData({'propertyType': v}),
              multiSelect: false,
            ),
          ),
          const SizedBox(height: 20),

          _buildSection(
            title: _getPropertyNameLabel(),
            child: _buildTextField(
              value: _localData['propertyName'] ?? '',
              onChanged: (v) => _updateData({'propertyName': v}),
              hintText: 'Enter property name',
            ),
          ),
          const SizedBox(height: 20),

          _buildSection(
            title: 'Property Description',
            child: _buildTextArea(
              value: _localData['description'] ?? '',
              onChanged: (v) => _updateData({'description': v}),
              maxLength: 1000,
            ),
          ),
          const SizedBox(height: 20),

          _buildSection(
            title: 'Measurement Unit',
            child: _buildDropdown(
              value: _localData['measurementUnit'] ?? 'Square Feet',
              options: _measurementUnits,
              onChanged: (v) => _updateData({'measurementUnit': v}),
            ),
          ),
          const SizedBox(height: 20),

          _buildSection(
            title: 'Measurement Value',
            child: _buildNumberField(
              value: _localData['area']?.toString() ?? '',
              onChanged: (v) => _updateData({'area': v.isEmpty ? null : double.tryParse(v)}),
              hintText: 'Enter value',
            ),
          ),
          const SizedBox(height: 20),

          _buildSection(
            title: 'Facing Direction',
            child: _buildSelectionChips(
              options: _facingDirections,
              selected: _localData['facing'] ?? '',
              onSelect: (v) => _updateData({'facing': v}),
              multiSelect: false,
            ),
          ),
          const SizedBox(height: 20),

          if (_shouldShowBuiltUpArea()) ...[
            _buildSection(
              title: 'Built-Up Area',
              child: _buildNumberField(
                value: _localData['builtUpArea']?.toString() ?? '',
                onChanged: (v) => _updateData({'builtUpArea': v.isEmpty ? null : double.tryParse(v)}),
                hintText: 'Enter built-up area',
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_shouldShowBedrooms()) ...[
            _buildSection(
              title: 'Bedrooms',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectionChips(
                    options: ['1 BHK', '2 BHK', '3 BHK', '4 BHK', 'Custom'],
                    selected: _localData['bedrooms'] ?? '',
                    onSelect: (v) => _updateData({'bedrooms': v}),
                    multiSelect: false,
                  ),
                  if (_localData['bedrooms'] == 'Custom') ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      value: _customBedroomValue,
                      onChanged: (v) {
                        setState(() => _customBedroomValue = v);
                        _updateData({'customBedrooms': v});
                      },
                      hintText: 'Enter custom bedroom count',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_shouldShowBathrooms()) ...[
            _buildSection(
              title: 'Bathrooms',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectionChips(
                    options: ['1', '2', '3', '4', 'Custom'],
                    selected: _localData['bathrooms'] ?? '',
                    onSelect: (v) => _updateData({'bathrooms': v}),
                    multiSelect: false,
                  ),
                  if (_localData['bathrooms'] == 'Custom') ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      value: _customBathroomValue,
                      onChanged: (v) {
                        setState(() => _customBathroomValue = v);
                        _updateData({'customBathrooms': v});
                      },
                      hintText: 'Enter custom bathroom count',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_shouldShowFloorNo()) ...[
            _buildSection(
              title: 'Floor No.',
              child: _buildNumberField(
                value: _localData['floor']?.toString() ?? '',
                onChanged: (v) => _updateData({'floor': v.isEmpty ? null : int.tryParse(v)}),
                hintText: 'Enter floor number',
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_shouldShowTotalFloors()) ...[
            _buildSection(
              title: 'Total Floors',
              child: _buildNumberField(
                value: _localData['totalFloors']?.toString() ?? '',
                onChanged: (v) => _updateData({'totalFloors': v.isEmpty ? null : int.tryParse(v)}),
                hintText: 'Enter total floors',
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_shouldShowFurnishing()) ...[
            _buildSection(
              title: 'Furnishing Status',
              child: _buildToggleButtons(
                options: _furnishingStatus,
                selected: _localData['furnishing'] ?? '',
                onSelect: (v) => _updateData({'furnishing': v}),
                canDeselect: true,
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_shouldShowNumBeds()) ...[
            _buildSection(
              title: 'Number of Beds',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectionChips(
                    options: ['1', '2', '3', '4', '5', '6', 'Custom'],
                    selected: _localData['numBeds'] ?? '',
                    onSelect: (v) => _updateData({'numBeds': v}),
                    multiSelect: false,
                  ),
                  if (_localData['numBeds'] == 'Custom') ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      value: _customNumBedsValue,
                      onChanged: (v) {
                        setState(() => _customNumBedsValue = v);
                        _updateData({'customNumBeds': v});
                      },
                      hintText: 'Enter custom bed count',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_shouldShowPeoplePerRoom()) ...[
            _buildSection(
              title: 'People Per Room',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectionChips(
                    options: ['1', '2', '3', '4', '5', '6', 'Custom'],
                    selected: _localData['peoplePerRoom'] ?? '',
                    onSelect: (v) => _updateData({'peoplePerRoom': v}),
                    multiSelect: false,
                  ),
                  if (_localData['peoplePerRoom'] == 'Custom') ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      value: _customPeoplePerRoomValue,
                      onChanged: (v) {
                        setState(() => _customPeoplePerRoomValue = v);
                        _updateData({'customPeoplePerRoom': v});
                      },
                      hintText: 'Enter custom people per room',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          if (_shouldShowFurnishingItems()) ...[
            _buildSection(
              title: 'Furnishing Items',
              child: _buildMultiSelectChips(
                options: _furnishingItems,
                selected: List<String>.from(_localData['furnishingItems'] ?? []),
                onSelect: (selected) => _updateData({'furnishingItems': selected}),
              ),
            ),
            const SizedBox(height: 20),
          ],

          _buildSection(
            title: 'Inside Amenities',
            child: _buildMultiSelectChips(
              options: _insideAmenities,
              selected: List<String>.from(_localData['amenities'] ?? []),
              onSelect: (selected) => _updateData({'amenities': selected}),
            ),
          ),
          const SizedBox(height: 20),

          _buildSection(
            title: 'Nearby Amenities',
            child: _buildNearbyAmenities(),
          ),
          const SizedBox(height: 20),

          if (_shouldShowBoundaries()) ...[
            _buildSection(
              title: 'Boundary Details',
              child: _buildBoundaryDetails(),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle_outline, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppTypography.headingSmall),
          ],
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _buildToggleButtons({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
    bool canDeselect = false,
  }) {
    return Row(
      children: options.map((option) {
        final isSelected = option == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                if (canDeselect && isSelected) {
                  onSelect('');
                } else if (!isSelected) {
                  onSelect(option);
                }
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    option,
                    style: AppTypography.labelLarge.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectionChips({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
    required bool multiSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = option == selected;
        return GestureDetector(
          onTap: () => onSelect(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              option,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> options,
    required List<String> selected,
    required ValueChanged<List<String>> onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return GestureDetector(
          onTap: () {
            final newSelected = List<String>.from(selected);
            if (isSelected) {
              newSelected.remove(option);
            } else {
              newSelected.add(option);
            }
            onSelect(newSelected);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              option,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField({
    required String value,
    required ValueChanged<String> onChanged,
    required String hintText,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildNumberField({
    required String value,
    required ValueChanged<String> onChanged,
    required String hintText,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildTextArea({
    required String value,
    required ValueChanged<String> onChanged,
    required int maxLength,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      onChanged: onChanged,
      maxLines: 5,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: 'Enter description',
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButton<String>(
        value: value.isEmpty ? options.first : value,
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: options.map<DropdownMenuItem<String>>((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(option),
            ),
          );
        }).toList(),
        isExpanded: true,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildNearbyAmenities() {
    final selectedAmenities = Map<String, String>.from(_localData['nearbyAmenities'] ?? {});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMultiSelectChips(
          options: _nearbyAmenitiesOptions,
          selected: selectedAmenities.keys.toList(),
          onSelect: (selected) {
            final newAmenities = <String, String>{};
            for (final amenity in selected) {
              newAmenities[amenity] = selectedAmenities[amenity] ?? '';
            }
            _updateData({'nearbyAmenities': newAmenities});
          },
        ),
        if (selectedAmenities.isNotEmpty) ...[
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedAmenities.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key} (Distance)',
                      style: AppTypography.labelSmall,
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: TextEditingController(text: entry.value),
                      onChanged: (value) {
                        selectedAmenities[entry.key] = value;
                        _updateData({'nearbyAmenities': selectedAmenities});
                      },
                      decoration: InputDecoration(
                        hintText: 'e.g., 0.5 km',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildBoundaryDetails() {
    final boundaries = Map<String, String>.from(_localData['boundaries'] ?? {});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        'North',
        'South',
        'East',
        'West',
      ].map((direction) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$direction Boundary',
                style: AppTypography.labelSmall,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: TextEditingController(text: boundaries[direction] ?? ''),
                onChanged: (value) {
                  boundaries[direction] = value;
                  _updateData({'boundaries': boundaries});
                },
                decoration: InputDecoration(
                  hintText: 'Enter $direction boundary details',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
