import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_msg_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.msg});
  final MessageModel msg;

  @override
  Widget build(BuildContext context) {
    final isMe = Api.me.uid == msg.fromId;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    if (msg.fromId == Api.me.uid && msg.deleteForMe == true) {
      return const SizedBox.shrink();
    }

    if (msg.toId == Api.me.uid && msg.deleteForYou == true) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: size.height / 90),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isMe) showTime(context, isDark, size, isMe),
              if (isMe) showMsg(context, isMe, isDark),
              if (!isMe) showMsg(context, isMe, isDark),
              if (!isMe) showTime(context, isDark, size, isMe),
            ],
          ),
        ),
      ],
    );
  }

  Widget showTime(BuildContext context, bool isDark, Size size, bool isMe) {
    return Row(
      children: [
        if (msg.read.isNotEmpty && isMe)
          Icon(
            Icons.done_all,
            color: isDark ? Colors.white : Colors.blueAccent,
          ),
        SizedBox(
          width: size.width / 60,
        ),
        Text(
          timeGetter(msg.sentTime, context),
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: size.height / 70,
                color: Theme.of(context).colorScheme.onBackground,
              ),
        )
      ],
    );
  }

  Widget showMsg(BuildContext context, bool isMe, bool isDark) {
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: isDark
                  ? isMe
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.2)
                      : Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.67)
                  : isMe
                      ? const Color.fromARGB(255, 30, 62, 31)
                      : Theme.of(context).colorScheme.secondary,
            ),
            color: isDark
                ? isMe
                    ? Theme.of(context).colorScheme.tertiary.withOpacity(0.4)
                    : Theme.of(context).colorScheme.tertiary
                : isMe
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.6)
                    : Theme.of(context).colorScheme.primary,
            // Only show the message bubble's "speaking edge" if first in
            // the chain.
            // Whether the "speaking edge" is on the left or right depends
            // on whether or not the message bubble is the current user.
            borderRadius: BorderRadius.only(
              topLeft: !isMe ? Radius.zero : const Radius.circular(12),
              topRight: isMe ? Radius.zero : const Radius.circular(12),
              bottomLeft: const Radius.circular(12),
              bottomRight: const Radius.circular(12),
            ),
          ),
          // Set some reasonable constraints on the width of the
          // message bubble so it can adjust to the amount of text
          // it should show.
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 14,
          ),
          // Margin around the bubble.
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 12,
          ),
          child: Text(
            msg.text,
            style: TextStyle(
                // Add a little line spacing to make the text look nicer
                // when multilined.
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: Theme.of(context).colorScheme.onBackground),
            softWrap: true,
          ),
        ),
        // Text(
        //   msg.text,
        //   style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        //         fontSize: size.height / 40,
        //         color: Theme.of(context).colorScheme.onBackground,
        //       ),
        // )
      ],
    );
  }
}
