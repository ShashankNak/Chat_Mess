import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/screens/chats/group/add_members.screen.dart';
import 'package:chat_mess/screens/home/profile_screen.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:chat_mess/widgets/show_profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class GroupProfileScreen extends StatefulWidget {
  const GroupProfileScreen({super.key, required this.groupId});
  final String groupId;

  @override
  State<GroupProfileScreen> createState() => _GroupProfileScreenState();
}

class _GroupProfileScreenState extends State<GroupProfileScreen> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: StreamBuilder(
            stream: Api.firestore
                .collection("groupdata")
                .doc(widget.groupId)
                .snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const SizedBox();
                case ConnectionState.active:
                case ConnectionState.done:
                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.data() == null ||
                      snapshot.data!.data()!.isEmpty) {
                    return Center(
                      child: Text(
                        "Nothing Yet",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    );
                  }
                  GroupModel group =
                      GroupModel.fromJson(snapshot.data!.data()!);
                  return Container(
                    height: size.height,
                    width: size.width,
                    padding: const EdgeInsets.all(12),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: size.height / 20,
                          ),
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(size.height / 7),
                            child: group.image == ""
                                ? Image.asset(
                                    profile2,
                                    height: size.height / 4,
                                    width: size.height / 4,
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: group.image,
                                    height: size.height / 4,
                                    width: size.height / 4,
                                    alignment: Alignment.center,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      profile2,
                                      height: size.height / 4,
                                      width: size.height / 4,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          SizedBox(
                            height: size.height / 40,
                          ),
                          Text(
                            group.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                  fontSize: size.height / 30,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                          SizedBox(
                            height: size.height / 70,
                          ),
                          Divider(thickness: size.height / 400),
                          SizedBox(
                            height: size.height / 70,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Description",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: size.height / 70,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                            .withOpacity(0.6),
                                      ),
                                ),
                                SizedBox(
                                  height: size.height / 70,
                                ),
                                Text(
                                  group.about,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        fontSize: size.height / 50,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height / 70,
                          ),
                          Divider(thickness: size.height / 400),
                          SizedBox(
                            height: size.height / 70,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Members",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontSize: size.height / 35,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                              ),
                              if (group.admins
                                  .contains(Api.auth.currentUser!.uid))
                                IconButton(
                                    onPressed: () async {
                                      group = await Navigator.of(context).push(
                                          PageTransition(
                                              child: AddMemberScreen(
                                                  title: "Add Members",
                                                  subTitle: "",
                                                  group: group),
                                              type: PageTransitionType
                                                  .rightToLeftWithFade));
                                    },
                                    icon: const Icon(Icons.add))
                            ],
                          ),
                          SizedBox(
                            height: size.height / 70,
                          ),
                          Divider(thickness: size.height / 400),
                          SizedBox(
                            height: size.height / 3,
                            child: StreamBuilder(
                              stream: Api.firestore
                                  .collection('userdata')
                                  .where('uid', whereIn: group.users)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                  case ConnectionState.none:
                                    return Center(
                                        child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ));
                                  case ConnectionState.active:
                                  case ConnectionState.done:
                                    if (!snapshot.hasData ||
                                        snapshot.data == null ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Center(
                                        child: Text(
                                          "No users",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onBackground),
                                        ),
                                      );
                                    }

                                    List<ChatUser> userList = snapshot
                                        .data!.docs
                                        .map((e) => ChatUser.fromMap(e.data()))
                                        .toList();

                                    userList.sort(
                                      (a, b) {
                                        if (group.admins.contains(a.uid) &&
                                                !group.admins.contains(b.uid) ||
                                            (a.uid ==
                                                Api.auth.currentUser!.uid)) {
                                          return 0;
                                        }

                                        return 1;
                                      },
                                    );
                                    return Column(
                                      children: [
                                        Expanded(
                                          child: _isLoading
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator
                                                          .adaptive(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .background,
                                                  ),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  itemCount: userList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final user =
                                                        userList[index];
                                                    return Column(
                                                      children: [
                                                        InkWell(
                                                          onLongPress:
                                                              _isLoading
                                                                  ? () {}
                                                                  : () {
                                                                      if (!group
                                                                          .admins
                                                                          .contains(Api
                                                                              .auth
                                                                              .currentUser!
                                                                              .uid)) {
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              ShowProfileDialog(user: user),
                                                                        );
                                                                      }
                                                                      if (group.admins.contains(Api
                                                                              .auth
                                                                              .currentUser!
                                                                              .uid) &&
                                                                          (user.uid !=
                                                                              Api.auth.currentUser!.uid)) {
                                                                        showSelectDialog(
                                                                            group:
                                                                                group,
                                                                            size:
                                                                                size,
                                                                            user:
                                                                                user,
                                                                            makeAdmin:
                                                                                () async {
                                                                              _isLoading = true;
                                                                              setState(() {});
                                                                              if (group.admins.contains(user.uid)) {
                                                                                await Api.removeFromGroupAdmin(group, user).then((value) {
                                                                                  group = value;
                                                                                  _isLoading = false;
                                                                                });
                                                                              } else {
                                                                                await Api.makeGroupAdmin(group, user).then((value) {
                                                                                  group = value;
                                                                                  _isLoading = false;
                                                                                });
                                                                              }

                                                                              setState(() {});
                                                                            },
                                                                            viewProfile:
                                                                                () {},
                                                                            kickFromGroup:
                                                                                () {
                                                                              _isLoading = true;
                                                                              setState(() {});
                                                                              Api.kickFromTheGroup(group, user).then((value) {
                                                                                group = value;
                                                                                _isLoading = false;
                                                                                setState(() {});
                                                                              });
                                                                            });
                                                                      }
                                                                      if (user.uid ==
                                                                          Api
                                                                              .auth
                                                                              .currentUser!
                                                                              .uid) {
                                                                        Navigator.of(context).push(PageTransition(
                                                                            child:
                                                                                const ProfileScreen(),
                                                                            type:
                                                                                PageTransitionType.rightToLeftWithFade));
                                                                      }
                                                                    },
                                                          child: ListTile(
                                                            title: Text(
                                                              user.name,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onBackground,
                                                                    fontSize:
                                                                        size.height /
                                                                            50,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                            ),
                                                            subtitle: Text(
                                                              user.about,
                                                              maxLines: 1,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .onBackground,
                                                                    fontSize:
                                                                        size.height /
                                                                            70,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                            ),
                                                            trailing: group
                                                                    .admins
                                                                    .contains(
                                                                        userList[index]
                                                                            .uid)
                                                                ? Text(
                                                                    "Admin",
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodySmall!
                                                                        .copyWith(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .onBackground,
                                                                          fontSize:
                                                                              size.height / 80,
                                                                          fontWeight:
                                                                              FontWeight.w400,
                                                                        ),
                                                                  )
                                                                : const SizedBox
                                                                    .shrink(),
                                                            leading:
                                                                CircleAvatar(
                                                              foregroundColor: Theme
                                                                      .of(context)
                                                                  .colorScheme
                                                                  .onSecondary,
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                              child: user.image ==
                                                                      ""
                                                                  ? const Icon(
                                                                      CupertinoIcons
                                                                          .person,
                                                                    )
                                                                  : ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(size.height /
                                                                              7),
                                                                      child:
                                                                          CachedNetworkImage(
                                                                        imageUrl:
                                                                            user.image,
                                                                        width: size.height /
                                                                            10,
                                                                        height:
                                                                            size.height /
                                                                                10,
                                                                        alignment:
                                                                            Alignment.center,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                const CircularProgressIndicator(),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Image.asset(
                                                                          profile2,
                                                                          height:
                                                                              size.height / 4,
                                                                          width:
                                                                              size.height / 4,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              size.height / 90,
                                                        ),
                                                        Divider(
                                                            thickness:
                                                                size.height /
                                                                    400),
                                                      ],
                                                    );
                                                  },
                                                ),
                                        ),
                                      ],
                                    );
                                }
                              },
                            ),
                          ),
                          Divider(thickness: size.height / 400),
                          SizedBox(
                            height: size.height / 60,
                          ),
                          buildButton(
                            size: size,
                            color1: Colors.red,
                            submit: _isLoading
                                ? () {}
                                : () => showExitDialog(
                                      size,
                                      "Are you sure want to Exit Group?",
                                      "Exit Group",
                                      () async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await Api.exitGroup(group, context)
                                            .then((value) {
                                          _isLoading = value;
                                          log("Is Loading: ${_isLoading.toString()}");
                                          setState(() {});
                                        });
                                      },
                                    ),
                            widget: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Exit Group",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: Colors.white,
                                        fontSize: size.height / 50,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                                const Icon(
                                  Icons.arrow_right,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height / 70,
                          ),
                          if (group.admins.contains(Api.auth.currentUser!.uid))
                            Divider(thickness: size.height / 400),
                          if (group.admins.contains(Api.auth.currentUser!.uid))
                            SizedBox(
                              height: size.height / 60,
                            ),
                          if (group.admins.contains(Api.auth.currentUser!.uid))
                            buildButton(
                              size: size,
                              color1: Colors.red,
                              submit: _isLoading
                                  ? () {}
                                  : () => showExitDialog(
                                        size,
                                        "Are you sure want to Delete Group?",
                                        "Delete Group",
                                        () async {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          await Api.deleteGroup(group, context)
                                              .then((value) {
                                            _isLoading = value;
                                            log("Is Loading: ${_isLoading.toString()}");
                                            setState(() {});
                                          });
                                        },
                                      ),
                              widget: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Delete Group",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: Colors.white,
                                          fontSize: size.height / 50,
                                          fontWeight: FontWeight.w400,
                                        ),
                                  ),
                                  const Icon(
                                    Icons.arrow_right,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          SizedBox(
                            height: size.height / 70,
                          ),
                        ],
                      ),
                    ),
                  );
              }
            },
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
    );
  }

  void showSelectDialog(
      {required GroupModel group,
      required Size size,
      required ChatUser user,
      required VoidCallback makeAdmin,
      required VoidCallback kickFromGroup,
      required VoidCallback viewProfile}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor:
            Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
        title: Text(
          "${user.name}'s Profile",
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.white,
                fontSize: size.height / 50,
                fontWeight: FontWeight.w400,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                onPressed: () {
                  makeAdmin();
                  Navigator.of(context).pop();
                },
                child: Text(
                  group.admins.contains(user.uid)
                      ? "Remove from Admin"
                      : "Make Admin",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                        fontSize: size.height / 70,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                onPressed: () {
                  log("hello");
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => ShowProfileDialog(user: user),
                  );
                },
                child: Text(
                  "View Profile",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                        fontSize: size.height / 70,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                ),
                onPressed: () {
                  kickFromGroup();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Kick From Group",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                        fontSize: size.height / 70,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                        fontSize: size.height / 70,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showExitDialog(
      Size size, String title, String buttonText, VoidCallback function) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        backgroundColor:
            Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.white,
                fontSize: size.height / 50,
                fontWeight: FontWeight.w400,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.6)),
                onPressed: () {
                  function();
                  Navigator.of(context).pop();
                },
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                        fontSize: size.height / 70,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                        fontSize: size.height / 70,
                        fontWeight: FontWeight.w400,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
