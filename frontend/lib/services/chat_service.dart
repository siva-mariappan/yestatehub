import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Chat Service — connects to backend REST API + WebSocket for real-time messaging.
class ChatService extends ChangeNotifier {
  ChatService._();
  static final ChatService _instance = ChatService._();
  static ChatService get instance => _instance;

  final _api = ApiService();
  final _auth = AuthService();

  WebSocketChannel? _wsChannel;
  bool _wsConnected = false;
  Timer? _reconnectTimer;

  // Cached data
  List<Map<String, dynamic>> _conversations = [];
  final Map<String, List<Map<String, dynamic>>> _messageCache = {};

  // Stream controllers for real-time events
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _typingController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNewMessage => _messageController.stream;
  Stream<Map<String, dynamic>> get onTyping => _typingController.stream;
  List<Map<String, dynamic>> get conversations => List.unmodifiable(_conversations);
  bool get isConnected => _wsConnected;

  String get _currentUid => _auth.currentUser?.uid ?? '';
  String get _currentName => _auth.currentUser?.displayName ?? 'User';
  String get _currentEmail => _auth.currentUser?.email ?? '';

  // ─── WebSocket Connection ───────────────────────────────────
  Future<void> connectWebSocket() async {
    if (_wsConnected || _currentUid.isEmpty) return;

    try {
      final wsUrl = ApiService.baseUrl.replaceFirst('http', 'ws');
      final uri = Uri.parse('$wsUrl/api/chat/ws/$_currentUid');
      _wsChannel = WebSocketChannel.connect(uri);

      _wsChannel!.stream.listen(
        (data) {
          try {
            final msg = jsonDecode(data as String) as Map<String, dynamic>;
            if (msg['type'] == 'new_message') {
              _messageController.add(msg);
              // Update conversation list cache
              _updateConversationFromMessage(msg);
              notifyListeners();
            } else if (msg['type'] == 'typing') {
              _typingController.add(msg);
            }
          } catch (e) {
            debugPrint('ChatService WS parse error: $e');
          }
        },
        onDone: () {
          _wsConnected = false;
          _scheduleReconnect();
        },
        onError: (e) {
          debugPrint('ChatService WS error: $e');
          _wsConnected = false;
          _scheduleReconnect();
        },
      );

      _wsConnected = true;
      debugPrint('ChatService: WebSocket connected for $_currentUid');
    } catch (e) {
      debugPrint('ChatService: WebSocket connect failed: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      connectWebSocket();
    });
  }

  void sendTypingIndicator(String conversationId) {
    if (_wsChannel != null && _wsConnected) {
      _wsChannel!.sink.add(jsonEncode({
        'type': 'typing',
        'conversation_id': conversationId,
      }));
    }
  }

  // ─── Conversations API ──────────────────────────────────────
  Future<List<Map<String, dynamic>>> loadConversations() async {
    try {
      final dynamic raw = await _api.get('/api/chat/conversations');
      final List<dynamic> list = raw is List ? raw : [];
      final all = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      // Deduplicate by (property_id + sorted participant uids)
      final seen = <String>{};
      _conversations = [];
      for (final c in all) {
        final propId = c['property_id'] as String? ?? '';
        final participants = c['participants'] as List<dynamic>? ?? [];
        final uids = participants
            .map((p) => (p as Map<String, dynamic>)['uid'] as String? ?? '')
            .toList()
          ..sort();
        final key = '$propId|${uids.join(",")}';
        if (seen.contains(key)) continue;
        seen.add(key);
        _conversations.add(c);
      }
      notifyListeners();
      return _conversations;
    } catch (e) {
      debugPrint('ChatService: loadConversations error: $e');
      return _conversations;
    }
  }

  Future<Map<String, dynamic>> createOrGetConversation({
    required String propertyId,
    required String propertyTitle,
    required String participantUid,
    required String participantName,
  }) async {
    try {
      final result = await _api.post('/api/chat/conversations', body: {
        'property_id': propertyId,
        'property_title': propertyTitle,
        'participant_uid': participantUid,
        'participant_name': participantName,
      });
      // Refresh conversation list
      await loadConversations();
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      debugPrint('ChatService: createConversation error: $e');
      rethrow;
    }
  }

  // ─── Messages API ───────────────────────────────────────────
  Future<List<Map<String, dynamic>>> loadMessages(String conversationId) async {
    try {
      final dynamic raw = await _api.get('/api/chat/conversations/$conversationId/messages');
      final List<dynamic> list = raw is List ? raw : [];
      final messages = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      _messageCache[conversationId] = messages;
      return messages;
    } catch (e) {
      debugPrint('ChatService: loadMessages error: $e');
      return _messageCache[conversationId] ?? [];
    }
  }

  Future<Map<String, dynamic>?> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      final result = await _api.post('/api/chat/messages', body: {
        'conversation_id': conversationId,
        'text': text,
      });
      final msg = Map<String, dynamic>.from(result as Map);
      // Add to local cache
      _messageCache.putIfAbsent(conversationId, () => []);
      _messageCache[conversationId]!.add(msg);
      // Update conversation in list
      _updateConversationLastMessage(conversationId, text);
      notifyListeners();
      return msg;
    } catch (e) {
      debugPrint('ChatService: sendMessage error: $e');
      return null;
    }
  }

  // ─── Helpers ────────────────────────────────────────────────
  void _updateConversationFromMessage(Map<String, dynamic> wsMsg) {
    final convId = wsMsg['conversation_id'] as String?;
    final message = wsMsg['message'] as Map<String, dynamic>?;
    if (convId == null || message == null) return;

    final text = message['text'] as String? ?? '';
    _updateConversationLastMessage(convId, text);

    // Add to message cache if we have it
    _messageCache.putIfAbsent(convId, () => []);
    _messageCache[convId]!.add(message);
  }

  void _updateConversationLastMessage(String convId, String text) {
    final idx = _conversations.indexWhere((c) => c['id'] == convId);
    if (idx >= 0) {
      _conversations[idx]['last_message'] = text;
      _conversations[idx]['last_message_time'] = DateTime.now().toIso8601String();
      // Move to top
      final conv = _conversations.removeAt(idx);
      _conversations.insert(0, conv);
    }
  }

  /// Get the other participant's name from a conversation doc
  String getOtherParticipantName(Map<String, dynamic> conversation) {
    final participants = conversation['participants'] as List<dynamic>? ?? [];
    for (final p in participants) {
      final pMap = p as Map<String, dynamic>;
      if (pMap['uid'] != _currentUid) {
        return pMap['name'] as String? ?? 'User';
      }
    }
    return 'User';
  }

  /// Check if current user is the sender
  bool isMe(String senderUid) => senderUid == _currentUid;

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _wsChannel?.sink.close();
    _messageController.close();
    _typingController.close();
    super.dispose();
  }
}
