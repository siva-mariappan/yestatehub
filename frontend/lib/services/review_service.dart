import 'api_service.dart';

class ReviewService {
  final _api = ApiService();

  Future<Map<String, dynamic>> createReview(Map<String, dynamic> data) async {
    return await _api.post('/api/reviews/', body: data);
  }

  Future<List<dynamic>> listReviews({String targetType = '', String targetId = '', int skip = 0, int limit = 50}) async {
    final params = <String, String>{'skip': skip.toString(), 'limit': limit.toString()};
    if (targetType.isNotEmpty) params['target_type'] = targetType;
    if (targetId.isNotEmpty) params['target_id'] = targetId;
    return await _api.get('/api/reviews/', queryParams: params, requireAuth: false);
  }

  Future<List<dynamic>> getMyReviews() async {
    return await _api.get('/api/reviews/my');
  }

  Future<Map<String, dynamic>> getReview(String id) async {
    return await _api.get('/api/reviews/$id', requireAuth: false);
  }

  Future<Map<String, dynamic>> updateReview(String id, Map<String, dynamic> data) async {
    return await _api.put('/api/reviews/$id', body: data);
  }

  Future<void> deleteReview(String id) async {
    await _api.delete('/api/reviews/$id');
  }
}
