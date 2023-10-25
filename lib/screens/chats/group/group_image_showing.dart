import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/group_msg_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/material.dart';

class GroupImageShowing extends StatelessWidget {
  const GroupImageShowing({super.key, required this.msg, required this.user});
  final GroupMessageModel msg;
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(37, 33, 33, 33),
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            )),
        title: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.fromId == user.uid ? user.name : "You",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontSize: size.height / 30, color: Colors.white),
              ),
              Text(
                "${dateGetter(msg.sentTime, context)} ${timeGetter(msg.sentTime, context)}",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontSize: size.height / 60, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 21, 21, 21),
      body: Center(
        child: CachedNetworkImage(
            imageUrl: msg.chatImage,
            height: size.height / 1.5,
            width: size.width,
            alignment: Alignment.center,
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
                  margin: EdgeInsets.only(right: size.width / 70),
                  padding: EdgeInsets.all(size.width / 30),
                  width: size.width / 8,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
            errorWidget: (context, url, error) => CircleAvatar(
                  child: Icon(
                    Icons.image,
                    size: size.width / 1.2,
                  ),
                )),
      ),
    );
  }
}
