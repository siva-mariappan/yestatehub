import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../models/property.dart';

// ═══════════════════════════════════════════════════════════════
// FILTER SIDEBAR — Full implementation with Buy/Rent toggle,
// smart property-type-based filter visibility, Filters + Premium tabs,
// and all filter sections per the YEstateHub spec.
// ═══════════════════════════════════════════════════════════════

class FilterPanel extends StatefulWidget {
  final PropertyFilter filter;
  final ValueChanged<PropertyFilter> onFilterChanged;
  final int resultCount;
  final VoidCallback? onApply; // mobile: auto-close drawer

  const FilterPanel({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.resultCount,
    this.onApply,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  // ── State ──────────────────────────────────────────────────────
  int _activeTab = 0; // 0 = Filters, 1 = Premium
  bool _isBuyMode = true;
  bool _showPremiumOverlay = false;

  // Selections
  final Set<String> _selectedPropertyTypes = {};
  RangeValues _priceRange = const RangeValues(0, 100000000);
  final Set<String> _selectedBHK = {};
  String? _landExtent;
  String? _buildupArea;
  String _furnishing = '';
  final Set<String> _selectedParking = {};
  final Set<String> _selectedAmenitiesNearby = {};
  final Set<String> _selectedShowOnly = {};
  String _facing = '';
  String _availability = '';
  String _preferredTenants = '';
  String _occupancy = '';
  bool _foodIncluded = false;

  // ── Reset All Filters ───────────────────────────────────────
  void _resetAllFilters() {
    setState(() {
      _selectedPropertyTypes.clear();
      _priceRange = const RangeValues(0, 100000000);
      _selectedBHK.clear();
      _landExtent = null;
      _buildupArea = null;
      _furnishing = '';
      _selectedParking.clear();
      _selectedAmenitiesNearby.clear();
      _selectedShowOnly.clear();
      _facing = '';
      _availability = '';
      _preferredTenants = '';
      _occupancy = '';
      _foodIncluded = false;
    });
  }

  // ── Smart filter visibility rules ─────────────────────────────
  // IDs: 1=LandExtent, 2=BuildupArea, 3=BHK, 4=Price, 5=Furnishing,
  // 6=Parking, 7=Facing, 8=AmenitiesNearby, 9=ShowOnly,
  // 10=Availability, 11=PreferredTenants, 12=Occupancy, 13=Food

  Set<int> get _visibleFilterIds {
    if (_selectedPropertyTypes.isEmpty) {
      return {1, 2, 3, 4, 6, 9}; // default
    }

    final ids = <int>{};
    for (final type in _selectedPropertyTypes) {
      if (_isBuyMode) {
        switch (type) {
          case 'Plot':
          case 'Commercial Land':
            ids.addAll({1, 4, 8, 9});
            break;
          case 'Flat':
          case 'Individual House':
          case 'Individual Villa':
            ids.addAll({1, 2, 3, 4, 5, 6, 7, 9});
            break;
          case 'Complex':
          case 'Commercial Building':
            ids.addAll({1, 2, 4, 6, 7, 9});
            break;
        }
      } else {
        switch (type) {
          case 'Flat':
          case 'Individual House':
          case 'Individual Villa':
            ids.addAll({3, 4, 5, 6, 7, 10, 11});
            break;
          case 'PG or Hostel':
            ids.addAll({3, 4, 5, 6, 10, 11, 13});
            break;
          case 'Shared Room':
          case 'Independent Floor':
            ids.addAll({3, 4, 5, 6, 10, 11, 12});
            break;
          case 'Commercial Building':
          case 'Office Space':
          case 'Shop or Showroom':
          case 'Warehouse or Godown':
            ids.addAll({2, 4, 6, 7, 10});
            break;
        }
      }
    }
    return ids;
  }

  List<String> get _propertyTypeOptions => _isBuyMode
      ? ['Plot', 'Commercial Land', 'Flat', 'Individual House', 'Individual Villa', 'Complex', 'Commercial Building']
      : ['Flat', 'Individual House', 'Individual Villa', 'PG or Hostel', 'Shared Room', 'Independent Floor', 'Commercial Building', 'Office Space', 'Shop or Showroom', 'Warehouse or Godown'];

  double get _maxPrice => _isBuyMode ? 100000000 : 500000;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(0, _maxPrice);
  }

  void _onBuyRentSwitch(bool buy) {
    setState(() {
      _isBuyMode = buy;
      _selectedPropertyTypes.clear();
      _priceRange = RangeValues(0, _maxPrice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Tab Bar: Filters | Premium ────────────────────────
        _buildTabBar(),
        const Divider(height: 1, color: AppColors.border),

        // ── Tab Content ───────────────────────────────────────
        if (_activeTab == 0)
          _buildFiltersTab()
        else
          _buildPremiumTab(),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB BAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTabBar() {
    return Row(
      children: [
        _tabItem('Filters', 0, showBadge: false),
        _tabItem('Premium Filters', 1, showBadge: true),
      ],
    );
  }

  Widget _tabItem(String label, int index, {bool showBadge = false}) {
    final isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
              ),
              if (showBadge) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FILTERS TAB (Tab 1)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFiltersTab() {
    final visible = _visibleFilterIds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // ── Buy / Rent Toggle ─────────────────────────────────
        _buildBuyRentToggle(),
        const SizedBox(height: 16),

        // ── Reset All Button ────────────────────────────────
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: _resetAllFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 16, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text(
                    'Reset All',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Property Type ─────────────────────────────────────
        _buildSectionHeader('Property Type'),
        const SizedBox(height: 10),
        ..._propertyTypeOptions.map((type) => _buildCheckboxTile(
              label: type,
              value: _selectedPropertyTypes.contains(type),
              onChanged: (v) => setState(() {
                if (v == true) {
                  _selectedPropertyTypes.add(type);
                } else {
                  _selectedPropertyTypes.remove(type);
                }
              }),
            )),
        const Divider(height: 32),

        // ── Land Extent ───────────────────────────────────────
        if (visible.contains(1)) ...[
          _buildSectionHeader('Land Extent'),
          const SizedBox(height: 10),
          _buildRadioGroup(['Any', '400–800 sqft', '800–1600 sqft', '1600+ sqft'], _landExtent, (v) => setState(() => _landExtent = v)),
          const Divider(height: 32),
        ],

        // ── Buildup Area ──────────────────────────────────────
        if (visible.contains(2)) ...[
          _buildSectionHeader('Buildup Area'),
          const SizedBox(height: 10),
          _buildRadioGroup(['Any', '400–800 sqft', '800–1600 sqft', '1600+ sqft'], _buildupArea, (v) => setState(() => _buildupArea = v)),
          const Divider(height: 32),
        ],

        // ── BHK Type ──────────────────────────────────────────
        if (visible.contains(3)) ...[
          _buildSectionHeader('BHK Type'),
          const SizedBox(height: 10),
          _buildMultiSelectWrap(['1 BHK', '2 BHK', '3 BHK', '4 BHK', '4+ BHK'], _selectedBHK),
          const Divider(height: 32),
        ],

        // ── Price Range ───────────────────────────────────────
        if (visible.contains(4)) ...[
          _buildSectionHeader(_isBuyMode ? 'Price Range' : 'Rent Range'),
          const SizedBox(height: 6),
          _buildPriceRangeSlider(),
          const Divider(height: 32),
        ],

        // ── Furnishing Status ─────────────────────────────────
        if (visible.contains(5)) ...[
          _buildSectionHeader('Furnishing Status *'),
          const SizedBox(height: 10),
          _buildFurnishingToggle(),
          const Divider(height: 32),
        ],

        // ── Parking ───────────────────────────────────────────
        if (visible.contains(6)) ...[
          _buildSectionHeader('Parking'),
          const SizedBox(height: 10),
          _buildCheckboxTile(label: '2 Wheeler', value: _selectedParking.contains('2 Wheeler'), onChanged: (v) => setState(() => v! ? _selectedParking.add('2 Wheeler') : _selectedParking.remove('2 Wheeler'))),
          _buildCheckboxTile(label: '4 Wheeler', value: _selectedParking.contains('4 Wheeler'), onChanged: (v) => setState(() => v! ? _selectedParking.add('4 Wheeler') : _selectedParking.remove('4 Wheeler'))),
          const Divider(height: 32),
        ],

        // ── Property Facing ───────────────────────────────────
        if (visible.contains(7)) ...[
          _buildSectionHeader('Property Facing'),
          const SizedBox(height: 10),
          _buildMultiSelectWrap(['North', 'South', 'East', 'West', 'North-East', 'South-West'], {if (_facing.isNotEmpty) _facing}, singleSelect: true, onSingleChanged: (v) => setState(() => _facing = v)),
          const Divider(height: 32),
        ],

        // ── Amenities Nearby ──────────────────────────────────
        if (visible.contains(8)) ...[
          _buildSectionHeader('Amenities Nearby'),
          const SizedBox(height: 10),
          ...['School', 'Park', 'Gated Community', 'Street Solar Lights', '24x7 Surveillance', 'Theater', 'Hospital', 'Bus Stand'].map((a) => _buildCheckboxTile(
                label: a,
                value: _selectedAmenitiesNearby.contains(a),
                onChanged: (v) => setState(() => v! ? _selectedAmenitiesNearby.add(a) : _selectedAmenitiesNearby.remove(a)),
              )),
          const Divider(height: 32),
        ],

        // ── Availability ──────────────────────────────────────
        if (visible.contains(10)) ...[
          _buildSectionHeader('Availability'),
          const SizedBox(height: 10),
          _buildMultiSelectWrap(['Immediate', 'Within 1 Month', 'Within 3 Months'], {if (_availability.isNotEmpty) _availability}, singleSelect: true, onSingleChanged: (v) => setState(() => _availability = v)),
          const Divider(height: 32),
        ],

        // ── Preferred Tenants ─────────────────────────────────
        if (visible.contains(11)) ...[
          _buildSectionHeader('Preferred Tenants'),
          const SizedBox(height: 10),
          _buildMultiSelectWrap(['Any', 'Families', 'Bachelors'], {if (_preferredTenants.isNotEmpty) _preferredTenants}, singleSelect: true, onSingleChanged: (v) => setState(() => _preferredTenants = v)),
          const Divider(height: 32),
        ],

        // ── Occupancy ─────────────────────────────────────────
        if (visible.contains(12)) ...[
          _buildSectionHeader('Occupancy'),
          const SizedBox(height: 10),
          _buildMultiSelectWrap(['Single', 'Double', 'Triple', '4+'], {if (_occupancy.isNotEmpty) _occupancy}, singleSelect: true, onSingleChanged: (v) => setState(() => _occupancy = v)),
          const Divider(height: 32),
        ],

        // ── Food Included ─────────────────────────────────────
        if (visible.contains(13)) ...[
          _buildCheckboxTile(label: 'Food Included', value: _foodIncluded, onChanged: (v) => setState(() => _foodIncluded = v ?? false)),
          const Divider(height: 32),
        ],

        // ── Show Only ─────────────────────────────────────────
        if (visible.contains(9)) ...[
          _buildSectionHeader('Show Only'),
          const SizedBox(height: 10),
          _buildCheckboxTile(label: 'With Photos', value: _selectedShowOnly.contains('With Photos'), onChanged: (v) => setState(() => v! ? _selectedShowOnly.add('With Photos') : _selectedShowOnly.remove('With Photos'))),
          _buildCheckboxTile(label: 'With Videos', value: _selectedShowOnly.contains('With Videos'), onChanged: (v) => setState(() => v! ? _selectedShowOnly.add('With Videos') : _selectedShowOnly.remove('With Videos'))),
        ],

        const SizedBox(height: 20),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PREMIUM TAB (Tab 2)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPremiumTab() {
    return Stack(
      children: [
        // Non-interactive preview of premium filters
        AbsorbPointer(
          child: Opacity(
            opacity: 0.5,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Age of Property'),
                  const SizedBox(height: 10),
                  _buildMultiSelectWrap(['< 5 Years', '5–10 Years', '10–15 Years', '15–20 Years', '20+ Years'], {}, singleSelect: true),
                  const Divider(height: 32),

                  _buildSectionHeader('Bathrooms'),
                  const SizedBox(height: 10),
                  _buildMultiSelectWrap(['1', '2', '3', '4+'], {}, singleSelect: true),
                  const Divider(height: 32),

                  _buildSectionHeader('Floors'),
                  const SizedBox(height: 10),
                  _buildMultiSelectWrap(['Ground', '1–3', '4–7', '8+'], {}, singleSelect: true),
                  const Divider(height: 32),

                  _buildSectionHeader('Property Status'),
                  const SizedBox(height: 10),
                  _buildMultiSelectWrap(['Ready to Move', 'Under Construction', 'New Launch'], {}, singleSelect: true),
                  const Divider(height: 32),

                  _buildSectionHeader('Amenities Nearby'),
                  const SizedBox(height: 10),
                  ...['School', 'Park', 'Hospital', 'Bus Stand', 'Metro'].map((a) => _buildCheckboxTile(label: a, value: false, onChanged: (_) {})),
                  const Divider(height: 32),

                  _buildSectionHeader('Amenities Inside'),
                  const SizedBox(height: 10),
                  ...['Swimming Pool', 'Portico', 'Terrace Garden', 'Pooja Room'].map((a) => _buildCheckboxTile(label: a, value: false, onChanged: (_) {})),
                  const Divider(height: 32),

                  _buildSectionHeader('Show Only'),
                  const SizedBox(height: 10),
                  _buildCheckboxTile(label: 'With Photos', value: false, onChanged: (_) {}),
                  _buildCheckboxTile(label: 'With Videos', value: false, onChanged: (_) {}),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),

        // Lock overlay — tappable
        GestureDetector(
          onTap: () => setState(() => _showPremiumOverlay = true),
          child: Container(color: Colors.transparent),
        ),

        // Overlay card
        if (_showPremiumOverlay)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _showPremiumOverlay = false),
              child: Container(
                color: Colors.white.withOpacity(0.9),
                child: Center(
                  child: _buildPremiumLockCard(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumLockCard() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => setState(() => _showPremiumOverlay = false),
              child: const Icon(Icons.close, size: 20, color: AppColors.textTertiary),
            ),
          ),
          const SizedBox(height: 8),
          // Lock icon
          const Icon(Icons.lock_outline, size: 48, color: Color(0xFF00796B)),
          const SizedBox(height: 16),
          const Text(
            'Unlock Premium Filters',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Fasten your search using Exclusive Filters',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Unlock Filters', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUY / RENT TOGGLE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBuyRentToggle() {
    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleButton('Buy', _isBuyMode, () => _onBuyRentSwitch(true))),
          Expanded(child: _toggleButton('Rent', !_isBuyMode, () => _onBuyRentSwitch(false))),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SECTION HEADER with optional Reset button
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary));
  }

  // ═══════════════════════════════════════════════════════════════
  // CHECKBOX TILE
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCheckboxTile({required String label, required bool value, required ValueChanged<bool?> onChanged}) {
    return SizedBox(
      height: 38,
      child: CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        title: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RADIO BUTTON GROUP
  // ═══════════════════════════════════════════════════════════════
  Widget _buildRadioGroup(List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      children: options.map((option) {
        return SizedBox(
          height: 38,
          child: RadioListTile<String>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: option,
            groupValue: selectedValue,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            title: Text(option, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // MULTI-SELECT WRAP BUTTONS (BHK, Facing, etc.)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMultiSelectWrap(
    List<String> options,
    Set<String> selected, {
    bool singleSelect = false,
    ValueChanged<String>? onSingleChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isActive = selected.contains(option);
        return GestureDetector(
          onTap: () {
            if (singleSelect) {
              if (onSingleChanged != null) {
                onSingleChanged(isActive ? '' : option);
              }
            } else {
              setState(() {
                if (isActive) {
                  selected.remove(option);
                } else {
                  selected.add(option);
                }
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PRICE RANGE SLIDER
  // ═══════════════════════════════════════════════════════════════
  Widget _buildPriceRangeSlider() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\u20B9 ${_formatPrice(_priceRange.start)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
              const Text('—', style: TextStyle(color: AppColors.textTertiary)),
              Text(
                '\u20B9 ${_formatPrice(_priceRange.end)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ],
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primaryLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: RangeSlider(
            values: _priceRange,
            min: 0,
            max: _maxPrice,
            divisions: 100,
            onChanged: (v) => setState(() => _priceRange = v),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // FURNISHING TOGGLE — large animated buttons
  // ═══════════════════════════════════════════════════════════════
  Widget _buildFurnishingToggle() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _furnishButton('Unfurnished', 'None'),
          const SizedBox(width: 10),
          _furnishButton('Semi Furnished', 'Semi'),
          const SizedBox(width: 10),
          _furnishButton('Fully Furnished', 'Full'),
        ],
      ),
    );
  }

  Widget _furnishButton(String label, String value) {
    final isActive = _furnishing == value;
    return GestureDetector(
      onTap: () => setState(() => _furnishing = isActive ? '' : value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  String _formatPrice(double price) {
    if (price >= 10000000) {
      final cr = price / 10000000;
      return cr == cr.roundToDouble() ? '${cr.toInt()} Cr' : '${cr.toStringAsFixed(1)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(0)} L';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    }
    return '${price.toInt()}';
  }

  int get activeFilterCount {
    int count = 0;
    if (_selectedPropertyTypes.isNotEmpty) count++;
    if (_priceRange.start > 0 || _priceRange.end < _maxPrice) count++;
    if (_selectedBHK.isNotEmpty) count++;
    if (_landExtent != null) count++;
    if (_buildupArea != null) count++;
    if (_furnishing.isNotEmpty) count++;
    if (_selectedParking.isNotEmpty) count++;
    if (_selectedAmenitiesNearby.isNotEmpty) count++;
    if (_selectedShowOnly.isNotEmpty) count++;
    if (_facing.isNotEmpty) count++;
    if (_availability.isNotEmpty) count++;
    if (_preferredTenants.isNotEmpty) count++;
    if (_occupancy.isNotEmpty) count++;
    if (_foodIncluded) count++;
    return count;
  }

  String get activeTypeLabel {
    if (_selectedPropertyTypes.isEmpty) return '';
    return 'Type: ${_selectedPropertyTypes.join(', ')}';
  }
}
