import 'api_service.dart';

class FavoriteService {
  final _api = ApiService();

  Future<Map<String, dynamic>> addFavorite(Map<String, dynamic> data) async {
    return await _api.post('/api/favorites/', body: data);
  }

  Future<List<dynamic>> listFavorites({String targetType = ''}) async {
    final params = <String, String>{};
    if (targetType.isNotEmpty) params['target_type'] = targetType;
    return await _api.get('/api/favorites/', queryParams: params);
  }

  Future<Map<String, dynamic>> checkFavorite(String targetType, String targetId) async {
    return await _api.get('/api/favorites/check', queryParams: {
      'target_type': targetType,
      'target_id': targetId,
    });
  }

  Future<void> removeFavorite(String id) async {
    await _api.delete('/api/favorites/$id');
  }

  Future<void> removeFavoriteByTarget(String targetType, String targetId) async {
    await _api.delete('/api/favorites/by-target/$targetType/$targetId');
  }
}
