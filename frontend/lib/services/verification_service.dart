import 'api_service.dart';

class VerificationService {
  final _api = ApiService();

  Future<Map<String, dynamic>> submitVerification(Map<String, dynamic> data) async {
    return await _api.post('/api/verifications/', body: data);
  }

  Future<List<dynamic>> listVerifications({String status = '', int skip = 0, int limit = 50}) async {
    final params = <String, String>{'skip': skip.toString(), 'limit': limit.toString()};
    if (status.isNotEmpty) params['status'] = status;
    return await _api.get('/api/verifications/', queryParams: params);
  }

  Future<List<dynamic>> adminListAll({String status = '', int skip = 0, int limit = 50}) async {
    final params = <String, String>{'skip': skip.toString(), 'limit': limit.toString()};
    if (status.isNotEmpty) params['status'] = status;
    return await _api.get('/api/verifications/admin/all', queryParams: params);
  }

  Future<Map<String, dynamic>> getVerification(String id) async {
    return await _api.get('/api/verifications/$id');
  }

  Future<Map<String, dynamic>> updateVerification(String id, Map<String, dynamic> data) async {
    return await _api.put('/api/verifications/$id', body: data);
  }
}
