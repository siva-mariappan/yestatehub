import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../config/typography.dart';

/// Chat Conversation Data
class ChatConversation {
  final String id, name, property;
  final bool isOnline;

  const ChatConversation({
    required this.id,
    required this.name,
    required this.property,
    required this.isOnline,
  });
}

/// Chat Detail Screen — Real-time messaging UI per property
class ChatDetailScreen extends StatefulWidget {
  final ChatConversation conversation;

  const ChatDetailScreen({super.key, required this.conversation});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  late List<_Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = _getMockMessages();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_Message> _getMockMessages() {
    return [
      _Message('Hi, I saw your listing for ${widget.conversation.property}. Is it still available?', false, '10:00 AM', true),
      _Message('Yes, it is still available! Would you like to schedule a visit?', true, '10:02 AM', true),
      _Message('That would be great. What times work this week?', false, '10:05 AM', true),
      _Message('We have slots available on Thursday 4-6 PM and Saturday 10 AM - 1 PM.', true, '10:08 AM', true),
      _Message('Thursday 5 PM works for me. Also, is the price negotiable?', false, '10:15 AM', true),
      _Message('I will confirm the Thursday slot. Regarding price, there is some room for discussion during the visit.', true, '10:18 AM', true),
      _Message('Perfect, looking forward to it!', false, '10:20 AM', false),
    ];
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(text, true, _nowTime(), false));
      _msgController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final isEmbedded = ModalRoute.of(context) == null || ModalRoute.of(context)!.isFirst == false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isEmbedded ? null : _buildAppBar(),
      body: Column(
        children: [
          if (isEmbedded || ModalRoute.of(context)?.isFirst == true) _chatHeader(),
          // Property info bar
          _propertyInfoBar(),
          // Messages
          Expanded(child: _messageList()),
          // Input bar
          _inputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryLight,
                child: Text(widget.conversation.name[0], style: AppTypography.labelLarge.copyWith(color: AppColors.primary)),
              ),
              if (widget.conversation.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.conversation.name, style: AppTypography.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  widget.conversation.isOnline ? 'Online' : 'Last seen 2h ago',
                  style: AppTypography.labelSmall.copyWith(color: widget.conversation.isOnline ? AppColors.primary : AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.phone_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }

  Widget _chatHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryLight,
                child: Text(widget.conversation.name[0], style: AppTypography.headingSmall.copyWith(color: AppColors.primary)),
              ),
              if (widget.conversation.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.conversation.name, style: AppTypography.labelLarge),
                Text(
                  widget.conversation.isOnline ? 'Online' : 'Last seen 2h ago',
                  style: AppTypography.labelSmall.copyWith(color: widget.conversation.isOnline ? AppColors.primary : AppColors.textTertiary),
                ),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.primary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_outlined, size: 20, color: AppColors.primary), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _propertyInfoBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryExtraLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.home_rounded, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.conversation.property, style: AppTypography.labelMedium),
                Text('Conversation about this property', style: AppTypography.bodySmall),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text('View', style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _messageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final isMe = msg.isMe;
        final showDate = index == 0;

        return Column(
          children: [
            if (showDate)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('Today', style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
                ),
              ),
            Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 6),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg.text,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isMe ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          msg.time,
                          style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : AppColors.textTertiary),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 4),
                          Icon(
                            msg.isRead ? Icons.done_all : Icons.done,
                            size: 14,
                            color: msg.isRead ? Colors.white : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.textSecondary),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _msgController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, size: 22, color: AppColors.textTertiary),
                    onPressed: () {},
                  ),
                ),
                style: AppTypography.bodyMedium,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message {
  final String text, time;
  final bool isMe, isRead;

  const _Message(this.text, this.isMe, this.time, this.isRead);
}
