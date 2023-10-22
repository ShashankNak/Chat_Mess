import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/screens/chats/group/group_chat_screen.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ShowProfileDialogGroup extends StatelessWidget {
  const ShowProfileDialogGroup({super.key, required this.group});
  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: size.height / 40,
          ),
          group.image == ""
              ? Image.asset(
                  profile2,
                  height: size.height / 3,
                  width: size.height / 3,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: group.image,
                  height: size.height / 3,
                  width: size.height / 3,
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Image.asset(
                    profile2,
                    height: size.height / 4,
                    width: size.height / 4,
                    fit: BoxFit.cover,
                  ),
                ),
          SizedBox(
            height: size.height / 40,
          ),
          Divider(thickness: size.height / 400),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(PageTransition(
                      duration: const Duration(milliseconds: 200),
                      child: GroupChatScreen(group: group),
                      type: PageTransitionType.fade));
                },
                icon: Icon(
                  Icons.chat,
                  size: size.width / 10,
                ),
              ),
              IconButton(
                onPressed: () {
                  // Navigator.of(context).pushReplacement(
                  //   PageTransition(
                  //       child: OtherProfileScreen(group: group),
                  //       type: PageTransitionType.fade),
                  // );
                },
                icon: Icon(
                  Icons.info,
                  size: size.width / 10,
                ),
              ),
            ],
          ),
          SizedBox(
            height: size.height / 40,
          ),
        ],
      ),
    );
  }
}
