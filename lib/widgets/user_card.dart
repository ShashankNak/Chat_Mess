import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/screens/chats/one_to_one_chat.dart';
import 'package:chat_mess/widgets/show_profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class UserCard extends StatelessWidget {
  const UserCard({super.key, required this.user});
  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(PageTransition(
                duration: const Duration(milliseconds: 200),
                child: OneToOneChat(user: user),
                type: PageTransitionType.fade));
          },
          splashColor: Theme.of(context).colorScheme.secondary,
          child: ListTile(
            title: Text(
              user.name,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: size.height / 50,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            subtitle: Text(
              user.about,
              maxLines: 1,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: size.height / 70,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            trailing: Text(
              user.lastActive,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: size.height / 60,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            leading: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ShowProfileDialog(user: user);
                  },
                );
              },
              child: CircleAvatar(
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                child: user.image == ""
                    ? const Icon(
                        CupertinoIcons.person,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(size.height / 7),
                        child: Image.network(
                          width: size.height / 10,
                          alignment: Alignment.center,
                          user.image,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
          ),
        ),
        Divider(
          thickness: size.height / 400,
        )
      ],
    );
  }
}
