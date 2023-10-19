import 'dart:developer';

import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/models/user_model.dart';
import 'package:chat_mess/widgets/group_card.dart';
import 'package:flutter/material.dart';

class GroupChatTab extends StatefulWidget {
  const GroupChatTab({super.key});

  @override
  State<GroupChatTab> createState() => _GroupChatTabState();
}

class _GroupChatTabState extends State<GroupChatTab> {
  List<GroupModel> groupDataList = [];
  List<String> groupList = [];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return StreamBuilder(
      stream: Api.firestore
          .collection('users')
          .doc(Api.auth.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return const Center(
                child: Text("Something went wrong."),
              );
            }
            final data = snapshot.data!;

            final user = data.data();
            if (user == null) {
              return const Center(
                child: Text("Something went wrong."),
              );
            }
            log(user.toString());
            groupList = UserModel.fromMap(user).groupList;

            if (groupList.isEmpty) {
              return Center(
                child: Text(
                  "No Groups Yet.",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
              );
            }

            return StreamBuilder(
              stream: Api.firestore
                  .collection('groupdata')
                  .where('id', whereIn: groupList)
                  .snapshots(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data!.docs;

                    groupDataList =
                        data.map((e) => GroupModel.fromJson(e.data())).toList();

                    if (groupDataList.isNotEmpty) {
                      return ListView.builder(
                        padding: EdgeInsets.only(top: size.height / 50),
                        itemCount: groupDataList.length,
                        itemBuilder: (context, index) {
                          return GroupCard(
                            user: groupDataList[index],
                          );
                        },
                      );
                    }
                    return const Center(
                      child: Text("No chats Yet"),
                    );
                }
              },
            );
        }
      },
    );
  }
}
