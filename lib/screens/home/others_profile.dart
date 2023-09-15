import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/material.dart';

class OtherProfileScreen extends StatelessWidget {
  const OtherProfileScreen({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          "${user.name} Profile",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: size.height / 30,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height / 20,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(size.height / 7),
                  child: user.image == ""
                      ? Image.asset(
                          profile2,
                          height: size.height / 4,
                          width: size.height / 4,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          user.image,
                          height: size.height / 4,
                          width: size.height / 4,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(
                  height: size.height / 40,
                ),
                Divider(thickness: size.height / 400),
                SizedBox(
                  height: size.height / 70,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.person, size: size.width / 10),
                    SizedBox(
                      width: size.width / 20,
                    ),
                    Expanded(
                        child: Text(
                      user.name,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: size.height / 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    )),
                  ],
                ),
                SizedBox(
                  height: size.height / 70,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: size.width / 10),
                    SizedBox(
                      width: size.width / 20,
                    ),
                    Expanded(
                        child: Text(
                      user.about,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: size.height / 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    )),
                  ],
                ),
                SizedBox(
                  height: size.height / 70,
                ),
                Divider(thickness: size.height / 400),
                SizedBox(
                  height: size.height / 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: size.width / 10),
                    SizedBox(
                      width: size.width / 20,
                    ),
                    Expanded(
                        child: Text(
                      formatNumber(user.phoneNumber),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: size.height / 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    )),
                  ],
                ),
                SizedBox(
                  height: size.height / 70,
                ),
                Divider(thickness: size.height / 400),
                SizedBox(
                  height: size.height / 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
