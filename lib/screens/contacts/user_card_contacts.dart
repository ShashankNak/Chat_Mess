import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserCardContacts extends StatelessWidget {
  const UserCardContacts({
    super.key,
    required this.user,
    required this.addUser,
  });
  final ChatUser user;
  final Function(ChatUser user) addUser;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        ListTile(
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
          trailing: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              addUser(user);
            },
          ),
          leading: CircleAvatar(
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: user.image == ""
                ? const Icon(
                    CupertinoIcons.person,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(size.height / 7),
                    child: CachedNetworkImage(
                      imageUrl: user.image,
                      width: size.height / 10,
                      height: size.height / 10,
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
