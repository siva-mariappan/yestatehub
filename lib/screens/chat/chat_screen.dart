import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';
import 'chat_detail_screen.dart';

/// Chat Screen — List of conversations grouped by property
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _searchController = TextEditingController();
  String _filter = 'All';
  int? _selectedIndex;

  static const _filters = ['All', 'Unread', 'Buyers', 'Sellers'];

  final _conversations = const [
    _Conversation(
      id: '1',
      name: 'Rahul Sharma',
      property: '3 BHK Gachibowli',
      lastMessage: 'Is the price negotiable? I am very interested.',
      time: '2m ago',
      unread: 2,
      isOnline: true,
      role: 'Buyer',
    ),
    _Conversation(
      id: '2',
      name: 'Priya Verma',
      property: '2 BHK Kondapur',
      lastMessage: 'Can I visit tomorrow around 4 PM?',
      time: '1h ago',
      unread: 0,
      isOnline: true,
      role: 'Buyer',
    ),
    _Conversation(
      id: '3',
      name: 'Amit Reddy',
      property: 'Villa Kokapet',
      lastMessage: 'What is the carpet area exactly?',
      time: '3h ago',
      unread: 1,
      isOnline: false,
      role: 'Buyer',
    ),
    _Conversation(
      id: '4',
      name: 'Sneha Iyer',
      property: '2 BHK Miyapur',
      lastMessage: 'Is parking included in the price?',
      time: '1d ago',
      unread: 0,
      isOnline: false,
      role: 'Seller',
    ),
    _Conversation(
      id: '5',
      name: 'Vikram Das',
      property: '3 BHK Banjara Hills',
      lastMessage: 'Thank you for the details. Will get back soon.',
      time: '2d ago',
      unread: 0,
      isOnline: false,
      role: 'Buyer',
    ),
    _Conversation(
      id: '6',
      name: 'Meera Patel',
      property: '4 BHK Jubilee Hills',
      lastMessage: 'Can you share more photos of the kitchen?',
      time: '3d ago',
      unread: 0,
      isOnline: true,
      role: 'Buyer',
    ),
  ];

  List<_Conversation> get _filtered {
    var list = _conversations;
    if (_filter == 'Unread') list = list.where((c) => c.unread > 0).toList();
    if (_filter == 'Buyers') list = list.where((c) => c.role == 'Buyer').toList();
    if (_filter == 'Sellers') list = list.where((c) => c.role == 'Seller').toList();
    final q = _searchController.text.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((c) => c.name.toLowerCase().contains(q) || c.property.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final showSplitView = !Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Messages', style: AppTypography.headingMedium),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: showSplitView ? _desktopLayout() : _mobileLayout(),
    );
  }

  Widget _desktopLayout() {
    final filtered = _filtered;
    return Row(
      children: [
        // Left: Conversation list
        SizedBox(
          width: Responsive.value<double>(context, mobile: 300, tablet: 320, desktop: 380),
          child: Column(
            children: [
              _searchAndFilters(),
              Expanded(child: _conversationList(filtered)),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right: Chat detail
        Expanded(
          child: _selectedIndex != null && _selectedIndex! < filtered.length
              ? ChatDetailScreen(conversation: _toDetail(filtered[_selectedIndex!]))
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textTertiary.withOpacity(0.4)),
                      const SizedBox(height: 16),
                      Text('Select a conversation', style: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _mobileLayout() {
    return Column(
      children: [
        _searchAndFilters(),
        Expanded(child: _conversationList(_filtered)),
      ],
    );
  }

  Widget _searchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search conversations...',
              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 10),
          // Filter chips
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == _filter;
                return ChoiceChip(
                  label: Text(f, style: AppTypography.labelSmall.copyWith(color: active ? Colors.white : AppColors.textSecondary)),
                  selected: active,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  side: BorderSide(color: active ? AppColors.primary : AppColors.border),
                  onSelected: (_) => setState(() => _filter = f),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversationList(List<_Conversation> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: AppColors.textTertiary.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text('No conversations found', style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: list.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        final c = list[index];
        final isSelected = _selectedIndex == index;

        return Container(
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryExtraLight : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(c.name[0], style: AppTypography.headingSmall.copyWith(color: AppColors.primary)),
                ),
                if (c.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    c.name,
                    style: AppTypography.labelLarge.copyWith(fontWeight: c.unread > 0 ? FontWeight.w700 : FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(c.time, style: AppTypography.labelSmall.copyWith(color: c.unread > 0 ? AppColors.primary : AppColors.textTertiary)),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.property, style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.lastMessage,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: c.unread > 0 ? FontWeight.w600 : FontWeight.w400,
                          color: c.unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (c.unread > 0)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: Center(
                          child: Text('${c.unread}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            onTap: () {
              final showSplit = !Responsive.isMobile(context);
              if (showSplit) {
                setState(() => _selectedIndex = index);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: _toDetail(c))),
                );
              }
            },
          ),
        );
      },
    );
  }

  ChatConversation _toDetail(_Conversation c) {
    return ChatConversation(
      id: c.id,
      name: c.name,
      property: c.property,
      isOnline: c.isOnline,
    );
  }
}

class _Conversation {
  final String id, name, property, lastMessage, time, role;
  final int unread;
  final bool isOnline;

  const _Conversation({
    required this.id,
    required this.name,
    required this.property,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.isOnline,
    required this.role,
  });
}
