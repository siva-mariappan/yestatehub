import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';
import '../../../config/responsive.dart';
import '../../chat/chat_detail_screen.dart';

/// Messages Tab — Modern chat threads with online indicators, property context
class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  int _selectedFilter = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  static const _filters = ['All', 'Unread', 'Buyers', 'Agents', 'Service Providers'];

  final List<_Chat> _chats = const [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Chat> get _filteredChats {
    var filtered = _selectedFilter == 0
        ? _chats
        : _selectedFilter == 1
            ? _chats.where((c) => c.unread > 0).toList()
            : _selectedFilter == 2
                ? _chats.where((c) => c.role == 'buyer').toList()
                : _selectedFilter == 3
                    ? _chats.where((c) => c.role == 'agent').toList()
                    : _chats.where((c) => c.role == 'service_provider').toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.property.toLowerCase().contains(q) ||
        c.lastMessage.toLowerCase().contains(q)
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final hPad = isMobile ? 16.0 : 28.0;

    return Column(
      children: [
        // ── Search + Filters ──
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
          child: Column(
            children: [
              // Search bar — now a real TextField
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: AppTypography.bodyMedium.copyWith(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search messages...',
                          hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary, fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textTertiary),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isActive = _selectedFilter == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isActive ? AppColors.primary : AppColors.border),
                          ),
                          child: Text(
                            _filters[index],
                            style: AppTypography.labelMedium.copyWith(
                              color: isActive ? Colors.white : AppColors.textSecondary,
                              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        // ── Chat List ──
        Expanded(
          child: Builder(
            builder: (context) {
              final filtered = _filteredChats;
              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryExtraLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.chat_bubble_outline_rounded, size: 30, color: AppColors.primary),
                      ),
                      const SizedBox(height: 14),
                      Text(_searchQuery.isNotEmpty ? 'No results found' : 'No messages yet', style: AppTypography.headingSmall),
                      const SizedBox(height: 6),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try a different search term.'
                            : 'Messages in this category\nwill appear here.',
                        style: AppTypography.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _buildChatItem(context, filtered[index], isMobile),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatItem(BuildContext context, _Chat chat, bool isMobile) {
    final hasUnread = chat.unread > 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              conversation: ChatConversation(
                id: chat.name.hashCode.toString(),
                name: chat.name,
                property: chat.property,
                isOnline: chat.isOnline,
              ),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        decoration: BoxDecoration(
          color: hasUnread ? AppColors.primaryExtraLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: hasUnread ? Border.all(color: AppColors.primary.withOpacity(0.15)) : null,
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [chat.avatarColor, chat.avatarColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      chat.name[0],
                      style: AppTypography.headingSmall.copyWith(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.name,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        chat.time,
                        style: AppTypography.labelSmall.copyWith(
                          color: hasUnread ? AppColors.primary : AppColors.textTertiary,
                          fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Role + Property tag row
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (chat.role == 'service_provider')
                        Container(
                          margin: const EdgeInsets.only(top: 2, bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF059669).withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home_repair_service_rounded, size: 10, color: const Color(0xFF059669)),
                              const SizedBox(width: 4),
                              Text(
                                'Service Provider',
                                style: AppTypography.labelSmall.copyWith(color: const Color(0xFF059669), fontSize: 9, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.only(top: 2, bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          chat.property,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    chat.lastMessage,
                    style: AppTypography.bodySmall.copyWith(
                      color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (hasUnread) ...[
              const SizedBox(width: 10),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${chat.unread}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chat {
  final String name, property, lastMessage, time;
  final int unread;
  final bool isOnline;
  final Color avatarColor;
  final String role; // 'buyer', 'agent', 'service_provider'
  const _Chat(this.name, this.property, this.lastMessage, this.time, this.unread, this.isOnline, this.avatarColor, this.role);
}
