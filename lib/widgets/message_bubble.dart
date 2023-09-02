import 'package:flutter/material.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatelessWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
    required this.isSeen,
    required this.time,
    required this.isMsgSend,
  }) : isFirstInSequence = true;

  // Create a amessage bubble that continues the sequence.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.isSeen,
    required this.time,
    required this.isMsgSend,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  // Whether or not this message bubble is the first in a sequence of messages
  // from the same user.
  // Modifies the message bubble slightly for these different cases - only
  // shows user image for the first message from the same user, and changes
  // the shape of the bubble for messages thereafter.
  final bool isFirstInSequence;
  final bool isMsgSend;

  // Image of the user to be displayed next to the bubble.
  // Not required if the message is not the first in a sequence.
  final String? userImage;

  // Username of the user.
  // Not required if the message is not the first in a sequence.
  final String? username;
  final String message;
  final bool isSeen;
  final String time;

  // Controls how the MessageBubble will be aligned.
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Stack(
      children: [
        if (userImage != null)
          Positioned(
            top: 15,
            // Align user image to the right, if the message is from me.
            right: isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                userImage!,
              ),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
          ),
        Container(
          // Add some margin to the edges of the messages, to allow space for the
          // user's image.
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            // The side of the chat screen the message should show at.
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // First messages in the sequence provide a visual buffer at
                  // the top.
                  if (isFirstInSequence) const SizedBox(height: 18),
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 13,
                        right: 13,
                      ),
                      child: Text(
                        username!,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),

                  // The "speech" box surrounding the message.
                  Container(
                    decoration: BoxDecoration(
                      color: isMe
                          ? isDark
                              ? Colors.grey[300]
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.4)
                          : isDark
                              ? const Color.fromARGB(255, 24, 24, 24)
                              : theme.colorScheme.secondary.withAlpha(200),
                      // Only show the message bubble's "speaking edge" if first in
                      // the chain.
                      // Whether the "speaking edge" is on the left or right depends
                      // on whether or not the message bubble is the current user.
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            // Add a little line spacing to make the text look nicer
                            // when multilined.
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: isMe
                                ? Colors.black87
                                : theme.colorScheme.onBackground,
                          ),
                          softWrap: true,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              time,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                      color: isDark
                                          ? const Color.fromARGB(
                                              149, 255, 255, 255)
                                          : const Color.fromARGB(
                                              255, 28, 41, 52)),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            if (isMe)
                              isMsgSend
                                  ? Icon(
                                      isSeen
                                          ? Icons.done_all_rounded
                                          : Icons.done_rounded,
                                      size: 20,
                                      color: isDark
                                          ? isSeen
                                              ? const Color.fromARGB(
                                                  255, 3, 141, 255)
                                              : const Color.fromARGB(
                                                  149, 255, 255, 255)
                                          : isSeen
                                              ? const Color.fromARGB(
                                                  255, 3, 141, 255)
                                              : const Color.fromARGB(
                                                  255, 32, 53, 71),
                                    )
                                  : Icon(
                                      Icons.access_time,
                                      size: 20,
                                      color: isDark
                                          ? const Color.fromARGB(
                                              149, 255, 255, 255)
                                          : const Color.fromARGB(
                                              255, 32, 53, 71),
                                    )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
