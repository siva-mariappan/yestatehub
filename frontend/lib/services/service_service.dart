import 'api_service.dart';

class ServiceService {
  final _api = ApiService();

  Future<Map<String, dynamic>> createService(Map<String, dynamic> data) async {
    return await _api.post('/api/services/', body: data);
  }

  Future<List<dynamic>> listServices({String category = '', String city = '', int skip = 0, int limit = 50}) async {
    final params = <String, String>{'skip': skip.toString(), 'limit': limit.toString()};
    if (category.isNotEmpty) params['category'] = category;
    if (city.isNotEmpty) params['city'] = city;
    return await _api.get('/api/services/', queryParams: params, requireAuth: false);
  }

  Future<List<dynamic>> getMyServices() async {
    return await _api.get('/api/services/my');
  }

  Future<Map<String, dynamic>> getService(String id) async {
    return await _api.get('/api/services/$id', requireAuth: false);
  }

  Future<Map<String, dynamic>> updateService(String id, Map<String, dynamic> data) async {
    return await _api.put('/api/services/$id', body: data);
  }

  Future<void> deleteService(String id) async {
    await _api.delete('/api/services/$id');
  }
}
