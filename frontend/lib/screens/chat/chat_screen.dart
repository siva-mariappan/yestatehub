import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import '../../services/chat_service.dart';
import 'chat_detail_screen.dart';

/// Chat Screen — Premium conversation list
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _chatService = ChatService.instance;
  final _searchFocusNode = FocusNode();
  String _filter = 'All';
  int? _selectedIndex;
  bool _isLoading = true;
  bool _isSearching = false;
  List<Map<String, dynamic>> _conversations = [];

  static const _filters = ['All', 'Unread'];

  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _chatService.addListener(_onChatUpdate);
    _chatService.connectWebSocket();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _chatService.removeListener(_onChatUpdate);
    _refreshController.dispose();
    super.dispose();
  }

  void _onChatUpdate() {
    if (mounted) {
      setState(() {
        _conversations = _chatService.conversations;
      });
    }
  }

  Future<void> _loadConversations() async {
    _refreshController.repeat();
    final convs = await _chatService.loadConversations();
    if (mounted) {
      setState(() {
        _conversations = convs;
        _isLoading = false;
      });
      _refreshController.stop();
      _refreshController.reset();
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _conversations;
    if (_filter == 'Unread') {
      list = list.where((c) => (c['unread_count'] as int? ?? 0) > 0).toList();
    }
    final q = _searchController.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) {
        final name = _chatService.getOtherParticipantName(c).toLowerCase();
        final property = (c['property_title'] as String? ?? '').toLowerCase();
        return name.contains(q) || property.contains(q);
      }).toList();
    }
    return list;
  }

  int get _totalUnread {
    int count = 0;
    for (final c in _conversations) {
      count += (c['unread_count'] as int? ?? 0);
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final showSplitView = !Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: showSplitView ? _desktopLayout() : _mobileLayout(),
    );
  }

  // ─── Desktop Layout ───────────────────────────────────────
  Widget _desktopLayout() {
    final filtered = _filtered;
    return Row(
      children: [
        SizedBox(
          width: Responsive.value<double>(context, mobile: 300, tablet: 340, desktop: 400),
          child: Column(
            children: [
              _headerSection(),
              _searchBar(),
              _filterChips(),
              Expanded(child: _isLoading ? _buildLoading() : _conversationList(filtered)),
            ],
          ),
        ),
        Container(width: 1, color: AppColors.border.withOpacity(0.5)),
        Expanded(
          child: _selectedIndex != null && _selectedIndex! < filtered.length
              ? ChatDetailScreen(conversation: _toDetail(filtered[_selectedIndex!]))
              : _selectConversationPlaceholder(),
        ),
      ],
    );
  }

  // ─── Mobile Layout ────────────────────────────────────────
  Widget _mobileLayout() {
    return Column(
      children: [
        _headerSection(),
        _searchBar(),
        _filterChips(),
        Expanded(child: _isLoading ? _buildLoading() : _conversationList(_filtered)),
      ],
    );
  }

  // ─── Header ───────────────────────────────────────────────
  Widget _headerSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Messages', style: AppTypography.headingLarge),
                    if (_totalUnread > 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$_totalUnread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_conversations.length} conversation${_conversations.length == 1 ? '' : 's'}',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          // Refresh button
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _loadConversations,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: RotationTransition(
                  turns: _refreshController,
                  child: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Search ───────────────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isSearching ? AppColors.primary.withOpacity(0.4) : AppColors.border.withOpacity(0.5),
          ),
          boxShadow: _isSearching
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 8)]
              : null,
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (_) => setState(() {}),
          onTap: () => setState(() => _isSearching = true),
          onEditingComplete: () {
            _searchFocusNode.unfocus();
            setState(() => _isSearching = false);
          },
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
            prefixIcon: Icon(
              Icons.search_rounded,
              size: 20,
              color: _isSearching ? AppColors.primary : AppColors.textTertiary,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textTertiary),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                      setState(() => _isSearching = false);
                    },
                  )
                : null,
            filled: false,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          style: AppTypography.bodyMedium,
        ),
      ),
    );
  }

  // ─── Filter Chips ─────────────────────────────────────────
  Widget _filterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: _filters.map((f) {
          final active = f == _filter;
          final unreadCount = _totalUnread;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => setState(() => _filter = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                    ),
                    boxShadow: active
                        ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        f,
                        style: AppTypography.labelSmall.copyWith(
                          color: active ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      if (f == 'Unread' && unreadCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: active ? Colors.white.withOpacity(0.25) : AppColors.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: active ? Colors.white : Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Loading ──────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading conversations...',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  // ─── Select Placeholder (Desktop) ────────────────────────
  Widget _selectConversationPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: AppColors.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Select a conversation',
            style: AppTypography.headingSmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose from your existing conversations\nor start a new one from a property listing',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Conversation List ────────────────────────────────────
  Widget _conversationList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return _emptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final c = list[index];
        return _conversationTile(c, index);
      },
    );
  }

  Widget _emptyState() {
    final isFiltered = _filter != 'All' || _searchController.text.isNotEmpty;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryExtraLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFiltered ? Icons.search_off_rounded : Icons.chat_bubble_outline_rounded,
                size: 32,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No matches found' : 'No conversations yet',
              style: AppTypography.headingSmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try a different search or filter'
                  : 'Start a chat from a property listing\nto begin messaging',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Conversation Tile ────────────────────────────────────
  Widget _conversationTile(Map<String, dynamic> c, int index) {
    final isSelected = _selectedIndex == index;
    final name = _chatService.getOtherParticipantName(c);
    final property = c['property_title'] as String? ?? '';
    final lastMsg = c['last_message'] as String? ?? '';
    final unread = c['unread_count'] as int? ?? 0;
    final timeStr = _formatTime(c['last_message_time'] as String? ?? '');
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            final showSplit = !Responsive.isMobile(context);
            if (showSplit) {
              setState(() => _selectedIndex = index);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(conversation: _toDetail(c)),
                ),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryExtraLight
                  : (unread > 0 ? AppColors.surface : Colors.transparent),
              borderRadius: BorderRadius.circular(14),
              border: isSelected
                  ? Border.all(color: AppColors.primary.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                // Avatar with online indicator
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Time
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: unread > 0 ? FontWeight.w700 : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: AppTypography.labelSmall.copyWith(
                              color: unread > 0 ? AppColors.primary : AppColors.textTertiary,
                              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Property tag
                      if (property.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryExtraLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            property,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      // Last message + unread badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lastMsg.isNotEmpty ? lastMsg : 'No messages yet',
                              style: AppTypography.bodySmall.copyWith(
                                fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                                color: unread > 0
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unread > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '$unread',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────
  ChatConversation _toDetail(Map<String, dynamic> c) {
    return ChatConversation(
      id: c['id'] as String? ?? '',
      name: _chatService.getOtherParticipantName(c),
      property: c['property_title'] as String? ?? '',
      isOnline: true,
    );
  }

  String _formatTime(String isoTime) {
    if (isoTime.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDate = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(msgDate).inDays;

      if (diff == 0) {
        final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
        final m = dt.minute.toString().padLeft(2, '0');
        final ampm = dt.hour >= 12 ? 'PM' : 'AM';
        return '$h:$m $ampm';
      }
      if (diff == 1) return 'Yesterday';
      if (diff < 7) {
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dt.weekday - 1];
      }
      return '${dt.day}/${dt.month}/${dt.year.toString().substring(2)}';
    } catch (_) {
      return '';
    }
  }
}
