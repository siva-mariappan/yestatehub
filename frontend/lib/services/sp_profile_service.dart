import 'api_service.dart';

class SPProfileService {
  final _api = ApiService();

  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> data) async {
    return await _api.post('/api/sp-profiles/', body: data);
  }

  Future<List<dynamic>> listProfiles({String city = '', String category = '', int skip = 0, int limit = 50}) async {
    final params = <String, String>{'skip': skip.toString(), 'limit': limit.toString()};
    if (city.isNotEmpty) params['city'] = city;
    if (category.isNotEmpty) params['category'] = category;
    return await _api.get('/api/sp-profiles/', queryParams: params, requireAuth: false);
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    return await _api.get('/api/sp-profiles/me');
  }

  Future<Map<String, dynamic>> getProfile(String id) async {
    return await _api.get('/api/sp-profiles/$id', requireAuth: false);
  }

  Future<Map<String, dynamic>> updateProfile(String id, Map<String, dynamic> data) async {
    return await _api.put('/api/sp-profiles/$id', body: data);
  }

  Future<void> deleteProfile(String id) async {
    await _api.delete('/api/sp-profiles/$id');
  }
}
