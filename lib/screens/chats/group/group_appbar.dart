import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/material.dart';

class GroupAppBar extends StatelessWidget {
  const GroupAppBar({super.key, required this.group});
  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size.height / 7),
          child: group.image == ""
              ? Image.asset(
                  profile2,
                  height: size.height / 25,
                  width: size.height / 25,
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: group.image,
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
        Text(
          group.name,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: size.width / 15),
        ),
      ],
    );
  }
}
