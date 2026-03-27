import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/typography.dart';

/// Messages Tab — chat threads list with unread badge
class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      _Chat('Rahul Sharma', '3 BHK Gachibowli', 'Is the price negotiable?', '2m ago', 2),
      _Chat('Priya Verma', '2 BHK Kondapur', 'Can I visit tomorrow?', '1h ago', 0),
      _Chat('Amit Reddy', 'Villa Kokapet', 'What is the carpet area?', '3h ago', 1),
      _Chat('Sneha Iyer', '2 BHK Miyapur', 'Is parking included?', '1d ago', 0),
      _Chat('Vikram Das', '3 BHK Banjara Hills', 'Thank you for the details.', '2d ago', 0),
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: chats.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 68),
      itemBuilder: (context, index) {
        final c = chats[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryLight,
            child: Text(c.name[0], style: AppTypography.headingSmall.copyWith(color: AppColors.primary)),
          ),
          title: Row(
            children: [
              Expanded(child: Text(c.name, style: AppTypography.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(c.time, style: AppTypography.labelSmall.copyWith(color: AppColors.textTertiary)),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(c.property, style: AppTypography.labelSmall.copyWith(color: AppColors.primary)),
              const SizedBox(height: 2),
              Text(c.lastMessage, style: AppTypography.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
          trailing: c.unread > 0
              ? Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(
                    child: Text('${c.unread}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                )
              : null,
          onTap: () {},
        );
      },
    );
  }
}

class _Chat {
  final String name, property, lastMessage, time;
  final int unread;
  const _Chat(this.name, this.property, this.lastMessage, this.time, this.unread);
}
