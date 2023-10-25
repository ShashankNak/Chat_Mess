import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/models/user_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.group});
  final String title;
  final String subTitle;
  final GroupModel group;

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  List<ChatUser> usersList = [];
  List<ChatUser> filteredList = [];
  List<String> finalList = [];
  List<String> selectedUsers = [];
  bool isSearch = false;
  bool isLoading = false;
  TextEditingController search = TextEditingController();

  void filterSearch(String value) {
    setState(() {
      filteredList = usersList.where((user) {
        return user.name.toLowerCase().contains(value.toLowerCase()) ||
            user.phoneNumber.contains(value);
      }).toList();
    });
    log(filteredList.length.toString());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDark
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: isDark
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.primary,
        leading: IconButton(
            onPressed: isSearch
                ? () {
                    setState(() {
                      filteredList = usersList;
                      search.clear();
                      isSearch = false;
                    });
                  }
                : () {
                    selectedUsers = [];
                    log("emptied");
                    Navigator.of(context).pop();
                  },
            icon: const Icon(Icons.arrow_back_outlined)),
        title: isSearch
            ? TextField(
                controller: search,
                onChanged: (value) {
                  filterSearch(value);
                },
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
                cursorColor: Theme.of(context).colorScheme.onBackground,
                decoration: InputDecoration(
                  hintText: "Search...",
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onBackground)),
                  hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.width / 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                  Text(
                    widget.subTitle,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.width / 30,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                ],
              ),
        actions: [
          IconButton(
            onPressed: () {
              if (isSearch) {
                filterSearch(search.text);
              } else {
                setState(() {
                  isSearch = true;
                });
              }
            },
            icon: const Icon(Icons.search_sharp),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: Api.getUsersList(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.active:
            case ConnectionState.done:
              if (!snapshot.hasData ||
                  snapshot.data == null ||
                  snapshot.data!.data() == null) {
                return Center(
                  child: Text(
                    "Something Went Wrong",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.width / 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                );
              }
              UserModel user = UserModel.fromMap(snapshot.data!.data()!);
              finalList = user.usersList;
              finalList.addAll(widget.group.users);
              finalList = finalList.toSet().toList();
              finalList.removeWhere(
                  (element) => widget.group.users.contains(element));
              if (finalList.isEmpty) {
                return Center(
                  child: Text(
                    "No Users",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.width / 15,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                );
              }
              return StreamBuilder(
                stream: Api.searchUsers(finalList),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (isLoading) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(
                              backgroundColor:
                                  Theme.of(context).colorScheme.onBackground),
                        );
                      }
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            "No Users",
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: size.width / 15,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                          ),
                        );
                      }

                      final rawList = snapshot.data!.docs;
                      usersList = rawList
                          .map((e) => ChatUser.fromMap(e.data()))
                          .toList();
                      return ListView.builder(
                        itemCount:
                            isSearch ? filteredList.length : usersList.length,
                        itemBuilder: (context, index) {
                          return userCard(
                              isSearch ? filteredList[index] : usersList[index],
                              size);
                        },
                      );
                  }
                },
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        elevation: 10,
        splashColor: isDark
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.tertiary,
        onPressed: isLoading
            ? () {}
            : () async {
                FocusScope.of(context).unfocus();
                isLoading = true;
                setState(() {});
                //API CALLING AND SELECTED USERS
                await Api.addMemberToGroup(widget.group, selectedUsers)
                    .then((value) {
                  selectedUsers = [];
                  setState(() {});
                  isLoading = false;
                  setState(() {});
                  Navigator.of(context).pop(value);
                });
              },
        child: Icon(
          Icons.arrow_circle_right_rounded,
          size: size.width / 8,
          color: isDark
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget userCard(ChatUser user, Size size) {
    return Column(
      children: [
        ListTile(
          tileColor: selectedUsers.contains(user.uid)
              ? Colors.white38
              : Colors.transparent,
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
            icon: Icon(
                selectedUsers.contains(user.uid) ? Icons.remove : Icons.add),
            onPressed: () {
              if (selectedUsers.contains(user.uid)) {
                selectedUsers.remove(user.uid);
                log(selectedUsers.toString());
                log("Removed ${user.name}, selectedUser: ${selectedUsers.contains(user.uid)}");
              } else {
                selectedUsers.add(user.uid);
                log(selectedUsers.toString());
                log("Added ${user.name}, selectedUser: ${selectedUsers.contains(user.uid)}");
              }
              setState(() {});
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
                        height: size.height / 10,
                        width: size.height / 10,
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
