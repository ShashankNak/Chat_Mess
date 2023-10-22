import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/screens/home/others_profile.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../../../widgets/consts.dart';

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
      child: StreamBuilder(
        stream: Api.getUserInfo(user.uid),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
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
                        : CachedNetworkImage(
                            imageUrl: userData.image,
                            height: size.height / 25,
                            width: size.height / 25,
                            alignment: Alignment.center,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset(
                              profile2,
                              height: size.height / 25,
                              width: size.height / 25,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  SizedBox(
                    width: size.width / 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData.name,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: size.width / 15),
                      ),
                      Row(
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
                            userData.isOnline
                                ? "Online"
                                : getLastActiveTime(
                                    context: context,
                                    lastActive: userData.lastActive),
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
                      ),
                    ],
                  ),
                ],
              );
          }
        },
      ),
    );
  }
}
