import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GroupDrawer extends StatefulWidget {
  const GroupDrawer({super.key, required this.group});
  final GroupModel group;

  @override
  State<GroupDrawer> createState() => _GroupDrawerState();
}

class _GroupDrawerState extends State<GroupDrawer> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: StreamBuilder(
        stream: Api.firestore
            .collection('userdata')
            .where('uid', whereIn: widget.group.users)
            .where('isOnline', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(
                  child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onBackground,
              ));
            case ConnectionState.active:
            case ConnectionState.done:
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No users",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                );
              }

              List<ChatUser> userList = snapshot.data!.docs
                  .map((e) => ChatUser.fromMap(e.data()))
                  .toList();

              userList.removeWhere(
                  (element) => element.uid == Api.auth.currentUser!.uid);

              return Container(
                padding: EdgeInsets.only(
                    top: size.height / 20,
                    bottom: size.height / 80,
                    left: size.width / 90,
                    right: size.width / 90),
                child: Column(
                  children: [
                    Text(
                      "Users Online",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.width / 15,
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(
                      height: size.height / 50,
                    ),
                    const Divider(
                      thickness: 1,
                      color: Colors.white,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: userList.length,
                        itemBuilder: (context, index) {
                          final user = userList[index];
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  user.name,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        fontSize: size.height / 50,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                subtitle: Text(
                                  user.about,
                                  maxLines: 1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                        fontSize: size.height / 70,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                                leading: CircleAvatar(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onSecondary,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  child: user.image == ""
                                      ? const Icon(
                                          CupertinoIcons.person,
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              size.height / 7),
                                          child: CachedNetworkImage(
                                            imageUrl: user.image,
                                            width: size.height / 10,
                                            height: size.height / 10,
                                            alignment: Alignment.center,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              profile2,
                                              height: size.height / 4,
                                              width: size.height / 4,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(
                                height: size.height / 90,
                              ),
                              const Divider(
                                thickness: 1,
                                color: Colors.white,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
