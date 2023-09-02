import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/screens/home/others_profile.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:chat_mess/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class OneToOneChat extends StatefulWidget {
  const OneToOneChat({super.key, required this.user});
  final ChatUser user;

  @override
  State<OneToOneChat> createState() => _OneToOneChatState();
}

class _OneToOneChatState extends State<OneToOneChat> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
        backgroundColor: isDark
            ? Theme.of(context)
                .colorScheme
                .background
                .withGreen(30)
                .withBlue(30)
                .withRed(30)
            : Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              Navigator.of(context).push(PageTransition(
                  duration: const Duration(milliseconds: 150),
                  child: OtherProfileScreen(user: widget.user),
                  type: PageTransitionType.rightToLeftWithFade));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(size.height / 7),
                  child: widget.user.image == ""
                      ? Image.asset(
                          profile2,
                          height: size.height / 25,
                          width: size.height / 25,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          widget.user.image,
                          height: size.height / 25,
                          width: size.height / 25,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(
                  width: size.width / 30,
                ),
                Text(
                  widget.user.name,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: size.width / 15),
                ),
              ],
            ),
          ),
        ),
        body: ListView(
          children: [
            MessageBubble.first(
              message: "kajsdf",
              isMe: false,
              isSeen: false,
              time: "9:00",
              userImage: widget.user.image,
              username: Api.auth.currentUser!.displayName,
              isMsgSend: true,
            ),
            const MessageBubble.next(
              message: "hii there",
              isMe: false,
              isSeen: false,
              time: "9:00",
              isMsgSend: true,
            ),
            MessageBubble.first(
              message: "hii there",
              isMe: true,
              isSeen: true,
              time: "9:00",
              userImage: widget.user.image,
              username: Api.auth.currentUser!.displayName,
              isMsgSend: true,
            ),
            const MessageBubble.next(
              message: "hii asdfasdfasdfasdfasdfthere",
              isMe: true,
              isSeen: false,
              time: "9:00",
              isMsgSend: false,
            ),
          ],
        ));
  }
}
