import 'api_service.dart';

class PaymentService {
  final _api = ApiService();

  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> data) async {
    return await _api.post('/api/payments/', body: data);
  }

  Future<List<dynamic>> listPayments({String status = '', int skip = 0, int limit = 50}) async {
    final params = <String, String>{'skip': skip.toString(), 'limit': limit.toString()};
    if (status.isNotEmpty) params['status'] = status;
    return await _api.get('/api/payments/', queryParams: params);
  }

  Future<Map<String, dynamic>> getPayment(String id) async {
    return await _api.get('/api/payments/$id');
  }

  Future<Map<String, dynamic>> updatePayment(String id, Map<String, dynamic> data) async {
    return await _api.put('/api/payments/$id', body: data);
  }
}
