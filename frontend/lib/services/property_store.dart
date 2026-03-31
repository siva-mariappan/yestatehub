import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/property.dart';
import 'api_service.dart';

/// Property store — syncs with MongoDB API, falls back to SharedPreferences + mock data.
/// Singleton so all screens share the same list.
class PropertyStore extends ChangeNotifier {
  PropertyStore._();
  static final PropertyStore _instance = PropertyStore._();
  static PropertyStore get instance => _instance;

  static const String _storageKey = 'yestatehub_properties';
  final _api = ApiService();

  /// All properties — from API / local cache / mock data
  final List<Property> _properties = [];

  /// Track whether initial load has completed.
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  List<Property> get properties => List.unmodifiable(_properties);
  int get count => _properties.length;

  /// Call once at app startup (e.g., in main.dart) to load properties.
  Future<void> init() async {
    if (_isLoaded) return;

    // Try loading from API first
    try {
      final dynamic rawResponse = await _api.get('/api/properties/', requireAuth: false);
      final List<dynamic> apiProps = rawResponse is List ? rawResponse : [];
      if (apiProps.isNotEmpty) {
        _properties.clear();
        for (final j in apiProps) {
          try {
            _properties.add(Property.fromJson(j as Map<String, dynamic>));
          } catch (parseErr) {
            debugPrint('PropertyStore: Failed to parse property: $parseErr');
          }
        }
        _isLoaded = true;
        _persistLocal();
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('PropertyStore: API load failed, using local: $e');
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _properties.clear();
        // Filter out old mock/predefined properties (IDs like p001-p006)
        // and strip Unsplash placeholder images from cached properties
        bool didClean = false;
        final cleanedList = <Map<String, dynamic>>[];
        for (final j in jsonList) {
          final map = Map<String, dynamic>.from(j as Map<String, dynamic>);
          final id = map['id']?.toString() ?? '';
          if (RegExp(r'^p\d{3}$').hasMatch(id)) {
            didClean = true;
            continue;
          }
          // Remove Unsplash placeholder images
          if (map['images'] is List) {
            final imgs = List<String>.from(map['images']);
            final cleaned = imgs.where((img) => !img.contains('unsplash.com')).toList();
            if (cleaned.length != imgs.length) {
              map['images'] = cleaned;
              didClean = true;
            }
          }
          cleanedList.add(map);
        }
        final parsed = cleanedList
            .map((j) => Property.fromJson(j))
            .toList();
        _properties.addAll(parsed);
        // Re-persist without mock data / placeholder images
        if (didClean) {
          _persistLocal();
        }
      } catch (e) {
        debugPrint('PropertyStore: Failed to load saved data: $e');
        _properties.clear();
      }
    } else {
      _properties.clear();
    }

    _isLoaded = true;
    notifyListeners();
  }

  /// Refresh from API
  Future<void> refresh() async {
    try {
      final dynamic rawResponse = await _api.get('/api/properties/', requireAuth: false);
      final List<dynamic> apiProps = rawResponse is List ? rawResponse : [];
      _properties.clear();
      for (final j in apiProps) {
        try {
          _properties.add(Property.fromJson(j as Map<String, dynamic>));
        } catch (parseErr) {
          debugPrint('PropertyStore: Failed to parse property on refresh: $parseErr');
        }
      }
      _persistLocal();
      notifyListeners();
    } catch (e) {
      debugPrint('PropertyStore refresh error: $e');
    }
  }

  /// Add a newly submitted property to the local list (appears at the top).
  /// Does NOT re-post to API — the caller (wizard) already submitted via PropertyService.
  Future<void> addProperty(Property property) async {
    _properties.insert(0, property);
    notifyListeners();
    _persistLocal();
  }

  /// Remove a property by ID.
  Future<void> removeProperty(String id) async {
    _properties.removeWhere((p) => p.id == id);
    notifyListeners();
    try {
      await _api.delete('/api/properties/$id');
    } catch (e) {
      debugPrint('PropertyStore: API delete error: $e');
    }
    _persistLocal();
  }

  /// Save current list to SharedPreferences (local cache).
  Future<void> _persistLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _properties.map((p) => p.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('PropertyStore: Failed to save: $e');
    }
  }

  /// Build a Property from the wizard's form data map.
  static Property propertyFromFormData(Map<String, dynamic> data) {
    // Map string values to enums
    PropertyType mapPropType(String? t) {
      switch ((t ?? '').toLowerCase()) {
        case 'apartment':
        case 'flat':
          return PropertyType.apartment;
        case 'villa':
        case 'individual villa':
          return PropertyType.villa;
        case 'independent house':
        case 'individual house':
          return PropertyType.independentHouse;
        case 'plot':
        case 'plot/land':
        case 'commercial land':
          return PropertyType.plot;
        case 'builder floor':
        case 'independent floor':
          return PropertyType.builderFloor;
        case 'pg':
        case 'pg/hostel':
        case 'shared room':
          return PropertyType.pg;
        default:
          return PropertyType.apartment;
      }
    }

    TransactionType mapTxnType(String? p) {
      switch ((p ?? '').toLowerCase()) {
        case 'sell':
        case 'buy':
          return TransactionType.buy;
        case 'rent':
          return TransactionType.rent;
        case 'pg':
          return TransactionType.pg;
        case 'commercial':
          return TransactionType.commercial;
        default:
          return TransactionType.buy;
      }
    }

    FurnishingStatus mapFurnishing(String? f) {
      switch ((f ?? '').toLowerCase()) {
        case 'furnished':
        case 'fully furnished':
          return FurnishingStatus.furnished;
        case 'semi-furnished':
        case 'semi furnished':
          return FurnishingStatus.semiFurnished;
        default:
          return FurnishingStatus.unfurnished;
      }
    }

    // Price: for Sell it's in 'price', for Rent it's in 'monthlyRent'
    final purpose = (data['purpose'] ?? 'Sell').toString();
    double price = double.tryParse(data['price']?.toString() ?? '') ?? 0;
    if (price == 0 && purpose.toLowerCase() == 'rent') {
      price = double.tryParse(data['monthlyRent']?.toString() ?? '') ?? 0;
    }

    final area = double.tryParse(data['area']?.toString() ?? '') ?? 0;

    // Bedrooms: form stores '1 BHK', '2 BHK', '3 BHK', '4 BHK', or 'Custom'
    int bedrooms = 0;
    final bedroomVal = data['bedrooms']?.toString() ?? '';
    if (bedroomVal == 'Custom') {
      bedrooms = int.tryParse(data['customBedrooms']?.toString() ?? '') ?? 0;
    } else {
      // Extract number from strings like '2 BHK' or plain '2'
      final bedroomMatch = RegExp(r'(\d+)').firstMatch(bedroomVal);
      bedrooms = bedroomMatch != null ? int.tryParse(bedroomMatch.group(1)!) ?? 0 : 0;
    }

    // Bathrooms: form stores '1', '2', '3', '4', or 'Custom'
    int bathrooms = 0;
    final bathroomVal = data['bathrooms']?.toString() ?? '';
    if (bathroomVal == 'Custom') {
      bathrooms = int.tryParse(data['customBathrooms']?.toString() ?? '') ?? 0;
    } else {
      final bathroomMatch = RegExp(r'(\d+)').firstMatch(bathroomVal);
      bathrooms = bathroomMatch != null ? int.tryParse(bathroomMatch.group(1)!) ?? 0 : 0;
    }

    // Floor info
    final floor = int.tryParse(data['floor']?.toString() ?? '') ?? 0;
    final totalFloors = int.tryParse(data['totalFloors']?.toString() ?? '') ?? 0;

    // Generate a unique ID
    final id = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // Build title from form data
    final propertyName = (data['propertyName'] as String?) ?? '';
    final title = propertyName.isNotEmpty
        ? propertyName
        : '${bedrooms > 0 ? "$bedrooms BHK " : ""}${data['propertyType'] ?? 'Property'} in ${data['locality'] ?? data['district'] ?? ''}';

    // Images — could be base64 data URIs, http URLs, or blob/file paths
    // Accept data: URIs (base64 encoded) and http(s) URLs. Skip blob/file paths.
    List<String> images = [];
    if (data['images'] != null) {
      for (final img in List<String>.from(data['images'])) {
        if (img.startsWith('data:image/') ||
            img.startsWith('http://') ||
            img.startsWith('https://')) {
          images.add(img);
        }
        // blob: and file: paths can't persist — skip them
      }
    }

    return Property(
      id: id,
      title: title,
      address: data['address'] ?? '',
      locality: data['locality'] ?? '',
      city: data['district'] ?? data['state'] ?? 'Hyderabad',
      price: price,
      pricePerSqft: area > 0 ? price / area : null,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      areaSqft: area,
      floor: floor,
      totalFloors: totalFloors,
      propertyType: mapPropType(data['propertyType']),
      transactionType: mapTxnType(data['purpose']),
      furnishing: mapFurnishing(data['furnishing']),
      listedBy: ListedBy.owner,
      ownerName: data['contactName'] ?? 'Owner',
      images: images,
      amenities: List<String>.from(data['amenities'] ?? []),
      isVerified: false,
      facingDirection: data['facing'] ?? '',
      ageOfBuilding: 0,
      possessionStatus: 'Ready to Move',
      listedDate: DateTime.now(),
      views: 0,
      enquiries: 0,
    );
  }
}
