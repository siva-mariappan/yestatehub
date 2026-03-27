import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

class AddPropertyScreen2 extends StatefulWidget {
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onUpdate;
  const AddPropertyScreen2({super.key, required this.data, required this.onUpdate});

  @override
  State<AddPropertyScreen2> createState() => _AddPropertyScreen2State();
}

class _AddPropertyScreen2State extends State<AddPropertyScreen2> {
  late String? selectedState;
  late String? selectedDistrict;
  late TextEditingController localityController;
  late TextEditingController pincodeController;
  late TextEditingController addressController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

  @override
  void initState() {
    super.initState();
    final stateVal = widget.data['state'];
    selectedState = (stateVal == null || stateVal == '') ? null : stateVal;
    final districtVal = widget.data['district'];
    selectedDistrict = (districtVal == null || districtVal == '') ? null : districtVal;
    localityController = TextEditingController(text: widget.data['locality'] ?? '');
    pincodeController = TextEditingController(text: widget.data['pincode'] ?? '');
    addressController = TextEditingController(text: widget.data['address'] ?? '');
    latitudeController = TextEditingController(text: widget.data['latitude'] ?? '');
    longitudeController = TextEditingController(text: widget.data['longitude'] ?? '');
  }

  @override
  void dispose() {
    localityController.dispose();
    pincodeController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }

  final List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman & Nicobar',
    'Chandigarh',
    'Dadra & Nagar Haveli',
    'Daman & Diu',
    'Delhi',
    'Jammu & Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  final Map<String, List<String>> districtsByState = {
    'Telangana': ['Hyderabad', 'Warangal', 'Nizamabad', 'Karimnagar', 'Khammam', 'Mahbubnagar', 'Nalgonda', 'Adilabad'],
    'Karnataka': ['Bengaluru', 'Mysuru', 'Mangaluru', 'Hubli-Dharwad', 'Belgaum', 'Gulbarga', 'Davanagere', 'Shimoga'],
    'Maharashtra': ['Mumbai', 'Pune', 'Nagpur', 'Thane', 'Nashik', 'Aurangabad', 'Solapur', 'Kolhapur'],
    'Tamil Nadu': ['Chennai', 'Coimbatore', 'Madurai', 'Tiruchirappalli', 'Salem', 'Tirunelveli', 'Erode', 'Vellore'],
    'Delhi': ['New Delhi', 'South Delhi', 'North Delhi', 'East Delhi', 'West Delhi'],
    'Andhra Pradesh': ['Visakhapatnam', 'Vijayawada', 'Guntur', 'Tirupati', 'Kakinada', 'Nellore'],
    'Arunachal Pradesh': ['Itanagar', 'Naharlagun', 'Pasighat', 'Tezu'],
    'Assam': ['Guwahati', 'Dibrugarh', 'Silchar', 'Jorhat', 'Nagaon'],
    'Bihar': ['Patna', 'Gaya', 'Bhagalpur', 'Madhubani', 'Munger'],
    'Chhattisgarh': ['Raipur', 'Bilaspur', 'Durg', 'Rajnandgaon', 'Bhilai'],
    'Goa': ['Panaji', 'Margao', 'Vasco da Gama', 'Ponda'],
    'Gujarat': ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Gujarati'],
    'Haryana': ['Faridabad', 'Gurgaon', 'Hisar', 'Rohtak', 'Panipat'],
    'Himachal Pradesh': ['Shimla', 'Solan', 'Mandi', 'Kangra'],
    'Jharkhand': ['Ranchi', 'Dhanbad', 'Giridih', 'Jamshedpur', 'Bokaro'],
    'Kerala': ['Kochi', 'Thiruvananthapuram', 'Kozhikode', 'Kottayam', 'Thrissur'],
    'Madhya Pradesh': ['Indore', 'Bhopal', 'Jabalpur', 'Gwalior', 'Ujjain'],
    'Manipur': ['Imphal', 'Bishnupur', 'Churachandpur'],
    'Meghalaya': ['Shillong', 'Tura', 'Nongstoin'],
    'Mizoram': ['Aizawl', 'Lunglei', 'Saiha'],
    'Nagaland': ['Kohima', 'Dimapur', 'Wokha'],
    'Odisha': ['Bhubaneswar', 'Cuttack', 'Rourkela', 'Sambalpur', 'Puri'],
    'Punjab': ['Chandigarh', 'Ludhiana', 'Amritsar', 'Jalandhar', 'Patiala'],
    'Rajasthan': ['Jaipur', 'Jodhpur', 'Udaipur', 'Kota', 'Ajmer'],
    'Sikkim': ['Gangtok', 'Pelling', 'Namchi'],
    'Tripura': ['Agartala', 'Udaipur', 'Dharmanagar'],
    'Uttar Pradesh': ['Lucknow', 'Kanpur', 'Varanasi', 'Allahabad', 'Agra'],
    'Uttarakhand': ['Dehradun', 'Nainital', 'Haridwar', 'Rishikesh'],
    'West Bengal': ['Kolkata', 'Darjeeling', 'Siliguri', 'Asansol', 'Durgapur'],
    'Andaman & Nicobar': ['Port Blair', 'Car Nicobar'],
    'Chandigarh': ['Chandigarh'],
    'Dadra & Nagar Haveli': ['Silvassa', 'Dadra'],
    'Daman & Diu': ['Daman', 'Diu'],
    'Jammu & Kashmir': ['Srinagar', 'Jammu', 'Leh', 'Kargil'],
    'Ladakh': ['Leh', 'Kargil'],
    'Lakshadweep': ['Kavaratti', 'Agatti'],
    'Puducherry': ['Puducherry', 'Yanam', 'Mahe', 'Karaikal'],
  };

  void _updateState(String newState) {
    setState(() {
      selectedState = newState;
      selectedDistrict = null;
    });
    widget.onUpdate({'state': newState, 'district': null});
  }

  void _updateDistrict(String newDistrict) {
    setState(() {
      selectedDistrict = newDistrict;
    });
    widget.onUpdate({'district': newDistrict});
  }

  List<String> _getDistricts() {
    if (selectedState == null) return [];
    return districtsByState[selectedState] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Location Details', style: AppTypography.headingMedium),
            ],
          ),
          const SizedBox(height: 20),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF4CAF50), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Accurate location helps buyers find your property easily',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // State/UT Dropdown
          DropdownButtonFormField<String>(
            value: selectedState,
            items: states
                .map((state) => DropdownMenuItem(value: state, child: Text(state)))
                .toList(),
            onChanged: (value) {
              if (value != null) _updateState(value);
            },
            decoration: InputDecoration(
              labelText: 'State/UT',
              hintText: 'Select state or UT',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // District/City Dropdown
          DropdownButtonFormField<String>(
            value: selectedDistrict,
            items: _getDistricts()
                .map((district) => DropdownMenuItem(value: district, child: Text(district)))
                .toList(),
            onChanged: selectedState == null
                ? null
                : (value) {
                    if (value != null) _updateDistrict(value);
                  },
            decoration: InputDecoration(
              labelText: 'District/City',
              hintText: selectedState == null ? 'Select state first' : 'Select district or city',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Locality / Area
          TextField(
            controller: localityController,
            decoration: InputDecoration(
              labelText: 'Locality / Area',
              hintText: 'Enter locality, area, or landmark',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (value) {
              widget.onUpdate({'locality': value});
            },
          ),
          const SizedBox(height: 20),

          // Pincode
          TextField(
            controller: pincodeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: 'Pincode',
              hintText: 'e.g. 500001',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              counterText: '',
            ),
            onChanged: (value) {
              widget.onUpdate({'pincode': value});
            },
          ),
          const SizedBox(height: 20),

          // Full Address
          TextField(
            controller: addressController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Full Address',
              hintText: 'Flat No, Building Name, Street...',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
            onChanged: (value) {
              widget.onUpdate({'address': value});
            },
          ),
          const SizedBox(height: 20),

          // Map Section
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4CAF50),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 48, color: Color(0xFF4CAF50)),
                  SizedBox(height: 12),
                  Text(
                    'Tap to pin your property location',
                    style: TextStyle(fontSize: 14, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Latitude field (disabled)
          TextField(
            controller: latitudeController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Latitude',
              hintText: '0.0000',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Longitude field (disabled)
          TextField(
            controller: longitudeController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Longitude',
              hintText: '0.0000',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
