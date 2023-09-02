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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
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
      body: const Center(
        child: Text("Start Chatting"),
      ),
    );
  }
}
