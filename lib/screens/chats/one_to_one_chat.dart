import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/screens/home/others_profile.dart';
import 'package:chat_mess/widgets/consts.dart';
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDark
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: isDark
              ? Theme.of(context).colorScheme.background
              : Theme.of(context).colorScheme.primary,
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: StreamBuilder(
                builder: (context, snapshot) {
                  return Center(
                    child: Text(
                      "No chats Yet",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: size.width / 15),
                    ),
                  );
                },
                stream: null,
              ),
            ),
            messageInput(isDark, size),
          ],
        ),
      ),
    );
  }

  Widget messageInput(bool isDark, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height / 50,
        horizontal: size.width / 40,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Theme.of(context).colorScheme.tertiary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width / 15),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: size.width / 90,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.emoji_emotions,
                      size: size.width / 14,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      autocorrect: false,
                      minLines: 1,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.height / 50,
                          color: Theme.of(context).colorScheme.onBackground),
                      decoration: InputDecoration(
                        label: Text(
                          "Type Here...",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.image,
                      size: size.width / 14,
                    ),
                  ),
                  SizedBox(
                    width: size.width / 90,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      size: size.width / 14,
                    ),
                  ),
                  SizedBox(
                    width: size.width / 90,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: size.width / 90,
          ),
          MaterialButton(
            color: isDark
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.secondary,
            padding: const EdgeInsets.all(10),
            shape: const CircleBorder(),
            onPressed: () {},
            minWidth: 0,
            child: Icon(
              Icons.send,
              size: size.width / 12,
            ),
          )
        ],
      ),
    );
  }
}
