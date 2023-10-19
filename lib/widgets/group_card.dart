import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({super.key, required this.user});
  final GroupModel user;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        InkWell(
          onTap: () {
            // Navigator.of(context).push(PageTransition(
            //     duration: const Duration(milliseconds: 200),
            //     child: OneToOneChat(user: user),
            //     type: PageTransitionType.fade));
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
            leading: InkWell(
              onTap: () {
                // showDialog(
                //   context: context,
                //   builder: (context) {
                //     return ShowProfileDialog(user: user);
                //   },
                // );
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
          ),
        ),
        Divider(
          thickness: size.height / 400,
        )
      ],
    );
  }
}
