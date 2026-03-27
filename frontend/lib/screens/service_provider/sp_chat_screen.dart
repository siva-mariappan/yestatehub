import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';
import '../../config/responsive.dart';

class SpChatScreen extends StatefulWidget {
  const SpChatScreen({super.key});

  @override
  State<SpChatScreen> createState() => _SpChatScreenState();
}

class _SpChatScreenState extends State<SpChatScreen> {
  final _messageController = TextEditingController();
  String? _selectedChat;

  final _conversations = [
    {
      'name': 'Rahul Sharma',
      'lastMessage': 'Great, see you tomorrow at 9 AM!',
      'time': '2 min ago',
      'unread': 2,
      'online': true,
      'service': 'Home Cleaning',
      'avatar': 'R',
    },
    {
      'name': 'Priya Patel',
      'lastMessage': 'Can you also do the bedroom walls?',
      'time': '15 min ago',
      'unread': 1,
      'online': true,
      'service': 'Wall Painting',
      'avatar': 'P',
    },
    {
      'name': 'Meera Joshi',
      'lastMessage': 'Thanks for the excellent work!',
      'time': '1 hour ago',
      'unread': 0,
      'online': false,
      'service': 'Deep Cleaning',
      'avatar': 'M',
    },
    {
      'name': 'Arjun Reddy',
      'lastMessage': 'Is the pipe fitting included?',
      'time': '3 hours ago',
      'unread': 0,
      'online': false,
      'service': 'Plumbing Repair',
      'avatar': 'A',
    },
    {
      'name': 'Sneha Gupta',
      'lastMessage': 'Payment sent. Please confirm.',
      'time': '1 day ago',
      'unread': 0,
      'online': false,
      'service': 'Home Cleaning',
      'avatar': 'S',
    },
    {
      'name': 'Vikram Singh',
      'lastMessage': 'Can you come earlier?',
      'time': '2 days ago',
      'unread': 0,
      'online': false,
      'service': 'Electrical Repair',
      'avatar': 'V',
    },
  ];

  final _messages = [
    {'sender': 'client', 'text': 'Hi, I wanted to confirm the booking for tomorrow.', 'time': '9:30 AM'},
    {'sender': 'me', 'text': 'Yes, confirmed! I\'ll be there at 9 AM sharp.', 'time': '9:32 AM'},
    {'sender': 'client', 'text': 'Perfect. Do I need to provide any cleaning supplies?', 'time': '9:33 AM'},
    {'sender': 'me', 'text': 'No, I bring all my own eco-friendly cleaning supplies. Just make sure there\'s access to water.', 'time': '9:35 AM'},
    {'sender': 'client', 'text': 'Sounds good. Also, can you pay extra attention to the kitchen area?', 'time': '9:40 AM'},
    {'sender': 'me', 'text': 'Absolutely! Kitchen deep cleaning is included in the package. I\'ll make sure it\'s spotless.', 'time': '9:41 AM'},
    {'sender': 'client', 'text': 'Great, see you tomorrow at 9 AM!', 'time': '9:45 AM'},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Messages', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      body: isDesktop
          ? Row(
              children: [
                // Sidebar
                SizedBox(
                  width: 360,
                  child: _buildConversationList(),
                ),
                Container(width: 1, color: AppColors.border.withOpacity(0.5)),
                // Chat area
                Expanded(
                  child: _selectedChat != null ? _buildChatArea() : _buildNoChatSelected(),
                ),
              ],
            )
          : _selectedChat == null
              ? _buildConversationList()
              : _buildChatArea(),
    );
  }

  Widget _buildConversationList() {
    final totalUnread = _conversations.fold<int>(0, (sum, c) => sum + (c['unread'] as int));

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Text('All Chats', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${_conversations.length}', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                ),
                const Spacer(),
                if (totalUnread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$totalUnread new', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 10)),
                  ),
              ],
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              itemCount: _conversations.length,
              itemBuilder: (context, index) => _buildConversationItem(_conversations[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    final isSelected = _selectedChat == conversation['name'];
    final hasUnread = (conversation['unread'] as int) > 0;
    final isOnline = conversation['online'] as bool;

    return GestureDetector(
      onTap: () => setState(() => _selectedChat = conversation['name'] as String),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryExtraLight : Colors.white,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
            bottom: BorderSide(color: AppColors.border.withOpacity(0.3)),
          ),
        ),
        child: Row(
          children: [
            // Avatar with online indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: hasUnread ? AppColors.primaryExtraLight : AppColors.background,
                  child: Text(
                    conversation['avatar'] as String,
                    style: AppTypography.labelLarge.copyWith(
                      color: hasUnread ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation['name'] as String,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        conversation['time'] as String,
                        style: AppTypography.labelSmall.copyWith(
                          color: hasUnread ? AppColors.primary : AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          conversation['service'] as String,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary, fontSize: 9),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          conversation['lastMessage'] as String,
                          style: AppTypography.bodySmall.copyWith(
                            color: hasUnread ? AppColors.textPrimary : AppColors.textTertiary,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${conversation['unread']}',
                              style: AppTypography.labelSmall.copyWith(color: Colors.white, fontSize: 9),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChatSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryExtraLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 40, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 16),
          Text('Select a Conversation', style: AppTypography.headingSmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Choose a chat from the left to start messaging', style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    final chat = _conversations.firstWhere((c) => c['name'] == _selectedChat, orElse: () => _conversations[0]);

    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.5))),
          ),
          child: Row(
            children: [
              if (Responsive.isMobile(context))
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 20),
                  onPressed: () => setState(() => _selectedChat = null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (Responsive.isMobile(context)) const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryExtraLight,
                child: Text(chat['avatar'] as String, style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chat['name'] as String, style: AppTypography.labelLarge),
                    Text(
                      (chat['online'] as bool) ? 'Online' : 'Last seen ${chat['time']}',
                      style: AppTypography.bodySmall.copyWith(
                        color: (chat['online'] as bool) ? AppColors.primary : AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryExtraLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(chat['service'] as String, style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontSize: 10)),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.phone_rounded, size: 20, color: AppColors.primary),
                onPressed: () {},
              ),
            ],
          ),
        ),
        // Messages
        Expanded(
          child: Container(
            color: AppColors.background,
            child: ListView.builder(
              padding: const EdgeInsets.all(18),
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessage(_messages[index]),
            ),
          ),
        ),
        // Input
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isMe = message['sender'] == 'me';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message['text'] as String,
                    style: AppTypography.bodySmall.copyWith(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message['time'] as String,
                        style: AppTypography.labelSmall.copyWith(
                          color: isMe ? Colors.white.withOpacity(0.6) : AppColors.textTertiary,
                          fontSize: 9,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.done_all_rounded, size: 12, color: Colors.white.withOpacity(0.6)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.attach_file_rounded, size: 20, color: AppColors.textTertiary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: TextField(
                  controller: _messageController,
                  style: AppTypography.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
