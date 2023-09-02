import 'dart:developer';

import 'package:chat_mess/models/chat_user_model.dart';
import 'package:flutter/material.dart';

import '../../apis/api.dart';
import '../../models/user_model.dart';
import '../../widgets/user_card.dart';

class UserChatTab extends StatefulWidget {
  const UserChatTab({super.key});

  @override
  State<UserChatTab> createState() => _UserChatTabState();
}

class _UserChatTabState extends State<UserChatTab> {
  List<ChatUser> userDataList = [];
  List<String> usersList = [];
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
            usersList = UserModel.fromMap(user).usersList;

            if (usersList.isEmpty) {
              return Center(
                child: Text(
                  "No Chats Yet.",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
              );
            }

            return StreamBuilder(
              stream: Api.firestore
                  .collection('userdata')
                  .where('uid', whereIn: usersList)
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

                    userDataList =
                        data.map((e) => ChatUser.fromMap(e.data())).toList();
                    if (userDataList.isNotEmpty) {
                      return ListView.builder(
                        padding: EdgeInsets.only(top: size.height / 50),
                        itemCount: userDataList.length,
                        itemBuilder: (context, index) {
                          return UserCard(
                            user: userDataList[index],
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
