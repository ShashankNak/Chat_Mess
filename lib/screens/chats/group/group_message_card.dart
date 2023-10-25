import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/group_msg_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/material.dart';

class GroupMessageCard extends StatefulWidget {
  const GroupMessageCard({super.key, required this.chat, required this.user});
  final GroupMessageModel chat;
  final ChatUser user;

  @override
  State<GroupMessageCard> createState() => _GroupMessageCardState();
}

class _GroupMessageCardState extends State<GroupMessageCard> {
  @override
  Widget build(BuildContext context) {
    final isMe = Api.auth.currentUser!.uid == widget.chat.fromId;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onLongPress: () {
        dialogBox(context, size);
      },
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: size.height / 90),
            child: Row(
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isMe) showTime(context, isDark, size, isMe),
                if (isMe) showMsg(context, isMe, isDark, size),
                if (!isMe) showMsg(context, isMe, isDark, size),
                if (!isMe) showTime(context, isDark, size, isMe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void dialogBox(BuildContext context, Size size) {
    final sameUser = widget.chat.fromId == Api.auth.currentUser!.uid;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            Theme.of(context).colorScheme.background.withOpacity(0.6),
        title: Center(
          child: Text(
            "Delete Chat",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: size.width / 25,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
          ),
        ),
        content: Container(
          padding: EdgeInsets.only(bottom: size.height / 50),
          height: size.height / 5,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (sameUser)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.background),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Api.deleteGroupMessageForAll(widget.chat);
                    },
                    child: Text(
                      "Delete For Everyone",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: size.width / 30,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                  ),
                if (sameUser)
                  SizedBox(
                    width: size.width / 90,
                  ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.background),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Api.deleteGroupMessageForMe(widget.chat);
                  },
                  child: Text(
                    "Delete For Me",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.width / 30,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.background),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.width / 30,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showTime(BuildContext context, bool isDark, Size size, bool isMe) {
    return Text(
      timeGetter(widget.chat.sentTime, context),
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: size.height / 70,
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );
  }

  Widget showMsg(BuildContext context, bool isMe, bool isDark, Size size) {
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
          constraints: BoxConstraints(maxWidth: size.width / 1.6),
          padding: EdgeInsets.symmetric(
            vertical: size.height / 100,
            horizontal: size.width / 40,
          ),
          // Margin around the bubble.
          margin: const EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 12,
          ),
          child: widget.chat.type == TypeG.text
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isMe)
                      Text(
                        widget.user.name,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: size.width / 40,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                        softWrap: true,
                      ),
                    Text(
                      widget.chat.text,
                      style: TextStyle(
                          // Add a little line spacing to make the text look nicer
                          // when multilined.
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: Theme.of(context).colorScheme.onBackground),
                      softWrap: true,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Text(
                        widget.user.name,
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: size.width / 40,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                        softWrap: true,
                      ),
                    if (!isMe)
                      SizedBox(
                        height: size.height / 60,
                      ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(size.height / 90),
                      child: CachedNetworkImage(
                          imageUrl: widget.chat.chatImage,
                          height: size.height / 4,
                          width: size.width / 1.1,
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                                margin: EdgeInsets.only(right: size.width / 70),
                                padding: EdgeInsets.all(size.width / 30),
                                width: size.width / 8,
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                          errorWidget: (context, url, error) => CircleAvatar(
                                child: Icon(
                                  Icons.image,
                                  size: size.width / 1.2,
                                ),
                              )),
                    ),
                    if (widget.chat.text != "")
                      SizedBox(
                        height: size.height / 80,
                      ),
                    if (widget.chat.text != "")
                      Text(
                        widget.chat.text,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.w600,
                            fontSize: size.width / 25),
                        softWrap: true,
                      )
                  ],
                ),
        ),
      ],
    );
  }
}
