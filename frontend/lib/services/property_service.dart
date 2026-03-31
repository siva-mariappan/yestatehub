import 'api_service.dart';

class PropertyService {
  final _api = ApiService();

  /// Submit a new property listing
  Future<Map<String, dynamic>> createProperty({
    required String title,
    String description = '',
    String purpose = 'Sell',
    String propertyType = 'apartment',
    String transactionType = 'buy',
    String furnishing = 'unfurnished',
    String listedBy = 'owner',
    int bedrooms = 0,
    int bathrooms = 0,
    double areaSqft = 0,
    int floor = 0,
    int totalFloors = 0,
    String facing = '',
    int ageOfBuilding = 0,
    String possessionStatus = 'Ready to Move',
    List<String> amenities = const [],
    Map<String, String> nearbyAmenities = const {},
    String state = '',
    String district = '',
    String city = '',
    String locality = '',
    String pincode = '',
    String address = '',
    required double price,
    bool negotiable = false,
    List<String> images = const [],
    String videoUrl = '',
    String contactName = '',
    String contactPhone = '',
    String contactEmail = '',
  }) async {
    final body = {
      'title': title,
      'description': description,
      'purpose': purpose,
      'property_type': propertyType,
      'transaction_type': transactionType,
      'furnishing': furnishing,
      'listed_by': listedBy,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area_sqft': areaSqft,
      'floor': floor,
      'total_floors': totalFloors,
      'facing': facing,
      'age_of_building': ageOfBuilding,
      'possession_status': possessionStatus,
      'amenities': amenities,
      'nearby_amenities': nearbyAmenities,
      'state': state,
      'district': district,
      'city': city,
      'locality': locality,
      'pincode': pincode,
      'address': address,
      'price': price,
      'negotiable': negotiable,
      'images': images,
      'video_url': videoUrl,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
    };

    return await _api.post('/api/properties/', body: body);
  }

  /// Get all properties (with optional filters)
  Future<List<dynamic>> getProperties({
    String? city,
    String? transactionType,
    String? propertyType,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int skip = 0,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };
    if (city != null) params['city'] = city;
    if (transactionType != null) params['transaction_type'] = transactionType;
    if (propertyType != null) params['property_type'] = propertyType;
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (bedrooms != null) params['bedrooms'] = bedrooms.toString();

    return await _api.get('/api/properties/', queryParams: params);
  }

  /// Get my listed properties
  Future<List<dynamic>> getMyProperties() async {
    return await _api.get('/api/properties/my');
  }

  /// Get single property detail
  Future<Map<String, dynamic>> getProperty(String id) async {
    return await _api.get('/api/properties/$id');
  }

  /// Update a property
  Future<Map<String, dynamic>> updateProperty(String id, Map<String, dynamic> data) async {
    return await _api.put('/api/properties/$id', body: data);
  }

  /// Delete a property
  Future<void> deleteProperty(String id) async {
    await _api.delete('/api/properties/$id');
  }
}
