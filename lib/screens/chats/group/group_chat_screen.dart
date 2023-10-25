import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/models/group_msg_model.dart';
import 'package:chat_mess/screens/chats/group/group_appbar.dart';
import 'package:chat_mess/screens/chats/group/group_drawer.dart';
import 'package:chat_mess/screens/chats/group/group_image_showing.dart';
import 'package:chat_mess/screens/chats/group/group_image_upload_screen.dart';
import 'package:chat_mess/screens/chats/group/group_message_card.dart';
import 'package:chat_mess/screens/chats/group/group_profile_screen.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, required this.group});
  final GroupModel group;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _showEmoji = false;
  List<GroupMessageModel> _message = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showEmoji = false;
          });
          FocusScope.of(context).unfocus();
        },
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            }
            return Future.value(true);
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: isDark
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.background,
            appBar: AppBar(
              leading: null,
              backgroundColor: isDark
                  ? Theme.of(context).colorScheme.background
                  : Theme.of(context).colorScheme.primary,
              title: GestureDetector(
                onTap: () {
                  if (MediaQuery.of(context).viewInsets.bottom > 0) {
                    FocusScope.of(context).unfocus();
                    log("keyboard");
                  }
                  Navigator.of(context).push(PageTransition(
                      child: GroupProfileScreen(groupId: widget.group.id),
                      type: PageTransitionType.fade));
                },
                child: GroupAppBar(
                  group: widget.group,
                ),
              ),
              actions: [
                Builder(
                  builder: (context) {
                    return IconButton(
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        icon: const Icon(Icons.online_prediction_rounded));
                  },
                )
              ],
            ),
            endDrawer: GroupDrawer(group: widget.group),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: Api.getAllGroupMessages(widget.group),
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
                          if (snapshot.data == null) {
                            return Center(
                              child: Text(
                                "Nothing Yet",
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
                          final data = snapshot.data!.docs;
                          _message = data
                              .map((e) => GroupMessageModel.fromJson(e.data()))
                              .toList();

                          if (_message.isNotEmpty) {
                            _message.removeWhere((element) =>
                                !element.deleteChat
                                    .containsKey(Api.auth.currentUser!.uid) ||
                                element.deleteChat[Api.auth.currentUser!.uid]!);
                          }

                          if (_message.isNotEmpty) {
                            _message.sort(
                              (a, b) => b.sentTime.compareTo(a.sentTime),
                            );

                            bool isSameDay = false;
                            String newDate = '';

                            return ListView.builder(
                              itemCount: _message.length,
                              reverse: true,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return StreamBuilder(
                                  stream: Api.firestore
                                      .collection("userdata")
                                      .doc(_message[index].fromId)
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
                                          _message.remove(_message[index]);
                                        }

                                        final userdata = ChatUser.fromMap(
                                            snapshot.data!.data()!);
                                        if (index == _message.length - 1) {
                                          newDate = dateGetter(
                                              _message[index].sentTime,
                                              context);
                                        } else {
                                          final date = DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  int.parse(_message[index]
                                                      .sentTime));
                                          final prevdate = DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  int.parse(_message[index + 1]
                                                      .sentTime));
                                          isSameDay = (date.day ==
                                                  prevdate.day) &&
                                              (date.month == prevdate.month) &&
                                              (date.year == prevdate.year);
                                          newDate = isSameDay
                                              ? ''
                                              : dateGetter(
                                                  _message[index].sentTime,
                                                  context);
                                          if (index == 0) {
                                            newDate = isSameDay
                                                ? ""
                                                : dateGetter(
                                                    _message[index].sentTime,
                                                    context);
                                          } else {
                                            newDate = isSameDay
                                                ? ''
                                                : dateGetter(
                                                    _message[index - 1]
                                                        .sentTime,
                                                    context);
                                          }
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              if (newDate.isNotEmpty)
                                                Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: isDark
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .background
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15.0),
                                                      child: Text(
                                                        newDate,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .copyWith(
                                                                color: isDark
                                                                    ? Colors
                                                                        .white
                                                                    : Colors
                                                                        .black),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              GestureDetector(
                                                onTap: () => Navigator.of(
                                                        context)
                                                    .push(PageTransition(
                                                        child:
                                                            GroupImageShowing(
                                                                msg: _message[
                                                                    index],
                                                                user: userdata),
                                                        type: PageTransitionType
                                                            .fade)),
                                                child: GroupMessageCard(
                                                  chat: _message[index],
                                                  user: userdata,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                    }
                                  },
                                );
                              },
                            );
                          }

                          return Center(
                            child: Text(
                              "No chats Yet",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: size.width / 15),
                            ),
                          );
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onBackground,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                messageInput(isDark, size),
                if (_showEmoji) showEmoji(isDark, size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showEmoji(bool isDark, Size size) {
    return SizedBox(
        height: size.height / 2.5,
        child: EmojiPicker(
          textEditingController: _messageController,
          // onBackspacePressed: _onBackspacePressed,
          config: Config(
            columns: 7,
            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            initCategory: Category.RECENT,
            bgColor: Theme.of(context).colorScheme.background,
            indicatorColor:
                isDark ? Colors.white : Theme.of(context).colorScheme.tertiary,
            iconColor: Colors.grey,
            iconColorSelected:
                isDark ? Colors.white : Theme.of(context).colorScheme.tertiary,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            recentTabBehavior: RecentTabBehavior.RECENT,
            recentsLimit: 28,
            replaceEmojiOnLimitExceed: false,
            noRecents: const Text(
              'No Recents',
              style: TextStyle(fontSize: 20, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
            loadingIndicator: const SizedBox.shrink(),
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: const CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL,
            checkPlatformCompatibility: true,
          ),
        ));
  }

  Widget messageInput(bool isDark, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height / 90,
        horizontal: size.width / 40,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: isDark
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width / 15),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: size.width / 90,
                  ),
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Future.delayed(
                        const Duration(milliseconds: 300),
                      ).then((value) {
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      size: size.width / 14,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onSubmitted: (value) => Api.sendGroupMessage(
                          widget.group, _messageController.text),
                      onTap: () {
                        if (_showEmoji) {
                          setState(() {
                            _showEmoji = false;
                          });
                        }
                      },
                      cursorColor: isDark ? Colors.white : Colors.black,
                      autocorrect: false,
                      minLines: 1,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.height / 50,
                          color: Theme.of(context).colorScheme.onBackground),
                      decoration: InputDecoration(
                        label: Text(
                          "Type Here...",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final images =
                          await picker.pickMultiImage(imageQuality: 70);

                      if (images.isNotEmpty) {
                        setState(() {
                          _isUploading = true;
                        });
                        for (var img in images) {
                          await Api.sendgroupImageMessage(
                                  widget.group, img.path, "")
                              .then((value) {
                            setState(() {
                              _isUploading = true;
                            });
                          });
                        }
                      }
                      setState(() {
                        _isUploading = false;
                      });
                    },
                    icon: Icon(
                      Icons.image,
                      size: size.width / 14,
                    ),
                  ),
                  SizedBox(
                    width: size.width / 90,
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      await picker
                          .pickImage(source: ImageSource.camera)
                          .then((value) {
                        if (value != null) {
                          Navigator.of(context).push(PageTransition(
                              child: GroupImageUploadScreen(
                                file: value,
                                group: widget.group,
                              ),
                              type: PageTransitionType.rightToLeftWithFade));
                        }
                      });
                    },
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      size: size.width / 14,
                    ),
                  ),
                  SizedBox(
                    width: size.width / 90,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: size.width / 90,
          ),
          MaterialButton(
            color: isDark
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.secondary,
            padding: const EdgeInsets.all(10),
            shape: const CircleBorder(),
            onPressed: () {
              if (_messageController.text.isEmpty) {
                log("no empty messages");
                return;
              }
              Api.sendGroupMessage(widget.group, _messageController.text);
              _messageController.clear();
            },
            minWidth: 0,
            child: Icon(
              Icons.send,
              size: size.width / 12,
            ),
          )
        ],
      ),
    );
  }
}
