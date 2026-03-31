import 'api_service.dart';

class BookingService {
  final _api = ApiService();

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> data) async {
    return await _api.post('/api/bookings/', body: data);
  }

  Future<List<dynamic>> listBookings({String status = '', int skip = 0, int limit = 50}) async {
    final params = <String, String>{'skip': skip.toString(), 'limit': limit.toString()};
    if (status.isNotEmpty) params['status'] = status;
    return await _api.get('/api/bookings/', queryParams: params);
  }

  Future<Map<String, dynamic>> getBooking(String id) async {
    return await _api.get('/api/bookings/$id');
  }

  Future<Map<String, dynamic>> updateBooking(String id, Map<String, dynamic> data) async {
    return await _api.put('/api/bookings/$id', body: data);
  }

  Future<void> cancelBooking(String id) async {
    await _api.delete('/api/bookings/$id');
  }
}
