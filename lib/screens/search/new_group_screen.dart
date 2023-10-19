import 'dart:developer';
import 'dart:io';
// import 'package:chat_mess/apis/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/models/user_model.dart';
import 'package:chat_mess/screens/auth/start_screen.dart';
import 'package:chat_mess/screens/home/home_screen.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen(
      {super.key, required this.groupId, required this.members});
  final String groupId;
  final List<ChatUser> members;

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final _formkey = GlobalKey<FormState>();
  final name = TextEditingController();
  final about = TextEditingController();
  bool _isloading = false;

  int counter = 0;
  String? _image;

  void testCompressAndGetFile(String path, String targetPath) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 50,
    );

    if (result != null) {
      log("compress image path: ${result.path}");
      setState(() {
        _image = result.path;
      });
      log("compress image size: ${await result.length()}");
      return;
    }
  }

  //for picking and compressing image

  void imagePicker(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: source);
    if (photo != null) {
      final path =
          "/data/user/0/com.example.chat_mess/cache/${widget.groupId}$counter.jpeg";

      log("image size: ${await photo.length()}");
      log("image path: ${photo.path}");
      testCompressAndGetFile(photo.path, path);
      log("counter: $counter");
      setState(() {
        counter++;
      });
    }
    return;
  }

  void showBottomSheet(Size size) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          padding:
              EdgeInsets.only(top: size.height / 40, bottom: size.height / 40),
          children: [
            Text(
              "Pick Profile Picture",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: size.height / 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
            ),
            SizedBox(
              height: size.height / 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    shape: const CircleBorder(),
                    fixedSize: Size(
                      size.width / 4,
                      size.width / 4,
                    ),
                  ),
                  onPressed: () {
                    imagePicker(ImageSource.gallery);

                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    alignment: Alignment.center,
                    gallery,
                    fit: BoxFit.fill,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Theme.of(context).colorScheme.background,
                    fixedSize: Size(
                      size.width / 4,
                      size.width / 4,
                    ),
                  ),
                  onPressed: () {
                    imagePicker(ImageSource.camera);

                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    alignment: Alignment.center,
                    camera,
                    fit: BoxFit.fill,
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  // creating profile and storing image in firebase storage
  void submit() async {
    final isValid = _formkey.currentState!.validate();
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    if (!isValid) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formkey.currentState!.save();

    setState(() {
      _isloading = true;
    });
    List<String> users = [Api.auth.currentUser!.uid];
    for (ChatUser i in widget.members) {
      users.add(i.uid);
    }
    try {
      if (_image == null) {
        final group = GroupModel(
          admins: [Api.auth.currentUser!.uid],
          users: users,
          id: widget.groupId,
          name: name.text,
          about: about.text,
          image: "",
          createdAt: time,
        );

        await Api.firestore
            .collection('groupdata')
            .doc(widget.groupId)
            .set(group.toJson())
            .then((value) async {
          setState(() {
            _isloading = false;
          });
          showSnackBar(context, "Group Created.");
          Navigator.of(context).pushAndRemoveUntil(
              PageTransition(
                  child: const HomeScreen(),
                  type: PageTransitionType.rightToLeftWithFade),
              (route) => false);
        });
        return;
      }
      final image = File(_image!);
      final ext = image.path.split(".").last;
      final ref =
          Api.storage.ref().child('group_profiles/${widget.groupId}.$ext');

      //storage file in ref with path

      //uploading image
      await ref
          .putFile(image, SettableMetadata(contentType: 'image/$ext'))
          .then((p0) async {
        log('data transfered: ${p0.bytesTransferred / 1000} kb');

        final String img = await ref.getDownloadURL();
        log(img);

        final group = GroupModel(
          admins: [Api.auth.currentUser!.uid],
          users: users,
          id: widget.groupId,
          name: name.text,
          about: about.text,
          image: img,
          createdAt: time,
        );

        await Api.firestore
            .collection('groupdata')
            .doc(widget.groupId)
            .set(group.toJson())
            .then((value) async {
          setState(() {
            _isloading = false;
          });
          showSnackBar(context, "Group Created.");
          Navigator.of(context).pushAndRemoveUntil(
              PageTransition(
                  child: const HomeScreen(),
                  type: PageTransitionType.rightToLeftWithFade),
              (route) => false);
        });

        for (String ids in users) {
          final raw = await Api.firestore.collection("users").doc(ids).get();
          if (raw.data() == null) {
            continue;
          }
          List<String> gl = UserModel.fromMap(raw.data()!).groupList;
          gl.add(widget.groupId);
          await Api.firestore
              .collection("users")
              .doc(ids)
              .update({"groupList": gl});
        }
      });
    } catch (e) {
      log(e.toString());
      () {
        showSnackBar(context, "Something went wrong.Try again later.");
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const StartScreen(),
            ),
            (route) => false);
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    // final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Create Group",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: size.height / 40,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
              ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onPrimary,
            size: size.height / 30,
          ),
        ),
        actions: [
          if (_isloading)
            Container(
              margin: EdgeInsets.only(right: size.width / 70),
              padding: EdgeInsets.all(size.width / 30),
              width: size.width / 8,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          IconButton(
            onPressed: _isloading ? () {} : submit,
            icon: Icon(
              Icons.arrow_right,
              size: size.width / 10,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            height: size.height,
            width: size.width,
            padding: const EdgeInsets.all(12),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: size.height / 20,
                  ),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(size.height / 7),
                        child: _image == null
                            ? Image.asset(
                                profile2,
                                height: size.height / 4,
                                width: size.height / 4,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(_image!),
                                height: size.height / 4,
                                width: size.height / 4,
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: size.height / 15,
                          height: size.height / 15,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Theme.of(context).colorScheme.secondary),
                          child: IconButton(
                            icon: Icon(
                              LineAwesomeIcons.camera,
                              size: size.height / 30,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            onPressed: () {
                              if (!_isloading) {
                                showBottomSheet(size);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height / 40,
                  ),
                  Divider(thickness: size.height / 400),
                  SizedBox(
                    height: size.height / 70,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.group, size: size.width / 10),
                      SizedBox(
                        width: size.width / 20,
                      ),
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.trim().length < 3) {
                              return "Invalid Name. Must be atleast 3 characters long";
                            }
                            return null;
                          },
                          controller: name,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                          cursorColor:
                              Theme.of(context).colorScheme.onBackground,
                          autocorrect: false,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: size.height / 45,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.8),
                                  ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            labelText: "Name",
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.9)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height / 70,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: size.width / 6),
                    child: Text(
                      "This is not your Username or pin. This name will be visible to your Chat Messenger contacts.",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.8),
                          ),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.info_outline, size: size.width / 10),
                      SizedBox(
                        width: size.width / 20,
                      ),
                      Expanded(
                        child: TextField(
                          minLines: 1,
                          maxLines: 4,
                          controller: about,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                          cursorColor:
                              Theme.of(context).colorScheme.onBackground,
                          autocorrect: false,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: size.height / 45,
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.8),
                                  ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            labelText: "About",
                            labelStyle: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.9)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height / 70,
                  ),
                  Container(
                    padding: EdgeInsets.only(left: size.width / 6),
                    child: Text(
                      "Write about yourself something.",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.8),
                          ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 70,
                  ),
                  Divider(thickness: size.height / 400),
                  SizedBox(
                    height: size.height / 70,
                  ),
                  Text(
                    "Members",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: size.height / 50,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(
                    height: size.height / 70,
                  ),
                  Divider(thickness: size.height / 400),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.members.length,
                      itemBuilder: (context, index) {
                        return userCard(widget.members[index], size);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget userCard(ChatUser user, Size size) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.transparent,
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
            icon: const Icon(Icons.remove),
            onPressed: () {
              if (!_isloading) {
                widget.members.remove(user);
                setState(() {});
              }
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
