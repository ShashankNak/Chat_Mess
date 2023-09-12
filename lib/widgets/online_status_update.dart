import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/screens/home/others_profile.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'consts.dart';

class OnlineStatusUpdate extends StatelessWidget {
  const OnlineStatusUpdate({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageTransition(
            duration: const Duration(milliseconds: 150),
            child: OtherProfileScreen(user: user),
            type: PageTransitionType.rightToLeftWithFade));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size.height / 7),
            child: user.image == ""
                ? Image.asset(
                    profile2,
                    height: size.height / 25,
                    width: size.height / 25,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    user.image,
                    height: size.height / 25,
                    width: size.height / 25,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(
            width: size.width / 30,
          ),
          Column(
            children: [
              Text(
                user.name,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: size.width / 15),
              ),
              StreamBuilder(
                stream: Api.firestore
                    .collection("userdata")
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: size.height / 1000,
                            ),
                            Text("Offline",
                                style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data!.data();
                      final userData = ChatUser.fromMap(data!);
                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: userData.isOnline
                                ? const Color.fromARGB(255, 0, 255, 132)
                                : const Color.fromARGB(255, 64, 64, 64),
                            maxRadius: size.height / 150,
                          ),
                          SizedBox(
                            width: size.width / 80,
                          ),
                          Text(
                            userData.isOnline ? "Online" : "Offline",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: userData.isOnline
                                      ? const Color.fromARGB(255, 0, 255, 132)
                                      : const Color.fromARGB(255, 64, 64, 64),
                                ),
                          ),
                        ],
                      );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
