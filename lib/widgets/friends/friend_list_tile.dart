import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auxiliary.dart';
import '../../clients/messaging_client.dart';
import '../../models/message.dart';
import '../../models/users/friend.dart';
import '../formatted_text.dart';
import '../generic_avatar.dart';
import '../messages/messages_list.dart';
import 'friend_online_status_indicator.dart';

class FriendListTile extends StatelessWidget {
  const FriendListTile({required this.friend, required this.unreads, this.onTap, super.key});

  final Friend friend;
  final int unreads;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUri = Aux.resdbToHttp(friend.userProfile.iconUrl);
    final theme = Theme.of(context);
    final mClient = Provider.of<MessagingClient>(context, listen: false);
    final currentSession = friend.userStatus.currentSessionIndex == -1
        ? null
        : friend.userStatus.decodedSessions.elementAtOrNull(friend.userStatus.currentSessionIndex);
    return ListTile(
      leading: GenericAvatar(
        imageUri: imageUri,
      ),
      trailing: unreads != 0
          ? Text(
              "+$unreads",
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
            )
          : null,
      title: Row(
        children: [
          Text(friend.username),
          if (friend.isHeadless)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                Icons.dns,
                size: 12,
                color: theme.colorScheme.onSecondaryContainer.withAlpha(150),
              ),
            ),
        ],
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FriendOnlineStatusIndicator(userStatus: friend.userStatus),
          const SizedBox(
            width: 4,
          ),
          Text(toBeginningOfSentenceCase(friend.userStatus.onlineStatus.name) ?? "Unknown"),
          if (currentSession != null && currentSession.isVisible) ...[
            const Text(" in "),
            if (currentSession.name.isNotEmpty)
              Expanded(
                child: FormattedText(
                  currentSession.formattedName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            else
              Expanded(
                child: Text(
                  "${currentSession.accessLevel.toReadableString()} session",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
          ]
        ],
      ),
      onTap: () async {
        onTap?.call();
        mClient.loadUserMessageCache(friend.id);
        final unreads = mClient.getUnreadsForFriend(friend);
        if (unreads.isNotEmpty) {
          final readBatch = MarkReadBatch(
            senderId: friend.id,
            ids: unreads.map((e) => e.id).toList(),
            readTime: DateTime.now(),
          );
          mClient.markMessagesRead(readBatch);
        }
        mClient.selectedFriend = friend;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider<MessagingClient>.value(
              value: mClient,
              child: const MessagesList(),
            ),
          ),
        );
        mClient.selectedFriend = null;
      },
    );
  }
}
