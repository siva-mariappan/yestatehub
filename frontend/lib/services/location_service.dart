import 'api_service.dart';

class LocationService {
  final _api = ApiService();

  Future<void> updateLocation(Map<String, dynamic> data) async {
    await _api.post('/api/location/update', body: data);
  }

  Future<Map<String, dynamic>> getMyLocation() async {
    return await _api.get('/api/location/me');
  }

  Future<Map<String, dynamic>> getProviderLocation(String providerUid) async {
    return await _api.get('/api/location/provider/$providerUid');
  }

  Future<List<dynamic>> getNearbyProviders(double latitude, double longitude, {double radiusKm = 10}) async {
    return await _api.get('/api/location/nearby', queryParams: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius_km': radiusKm.toString(),
    });
  }
}
