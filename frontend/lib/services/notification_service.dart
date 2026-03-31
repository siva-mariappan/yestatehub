import 'api_service.dart';

class NotificationService {
  final _api = ApiService();

  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> data) async {
    return await _api.post('/api/notifications/', body: data);
  }

  Future<List<dynamic>> listNotifications({int skip = 0, int limit = 50}) async {
    final params = <String, String>{'skip': skip.toString(), 'limit': limit.toString()};
    return await _api.get('/api/notifications/', queryParams: params);
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    return await _api.get('/api/notifications/unread-count');
  }

  Future<void> markRead(String id) async {
    await _api.put('/api/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _api.put('/api/notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await _api.delete('/api/notifications/$id');
  }
}
