import 'dart:developer';
import 'dart:io';
import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/screens/auth/start_screen.dart';
import 'package:chat_mess/screens/home/home_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import '../../widgets/consts.dart';

class MakeProfileScreen extends StatefulWidget {
  const MakeProfileScreen({super.key});

  @override
  State<MakeProfileScreen> createState() => _MakeProfileScreenState();
}

class _MakeProfileScreenState extends State<MakeProfileScreen> {
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
          "/data/user/0/com.example.chat_mess/cache/${Api.auth.currentUser!.uid}$counter.jpeg";

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

  @override
  Widget build(BuildContext context) {
    // bottom sheet for image picking
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
            padding: EdgeInsets.only(
                top: size.height / 40, bottom: size.height / 40),
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

    //creating profile and storing image in firebase storage
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

      try {
        final userExist = (await Api.firestore
                .collection('userdata')
                .doc(Api.auth.currentUser!.uid)
                .get())
            .exists;

        if (userExist) return;

        if (_image == null) {
          final chatUser = ChatUser(
              uid: Api.auth.currentUser!.uid,
              phoneNumber: Api.auth.currentUser!.phoneNumber!,
              name: name.text,
              about: about.text,
              image: "",
              createdAt: time,
              lastActive: time,
              isOnline: true,
              pushToken: "");

          await Api.firestore
              .collection('userdata')
              .doc(Api.auth.currentUser!.uid)
              .set(chatUser.toMap())
              .then((value) {
            setState(() {
              _isloading = false;
            });
            Api.auth.currentUser!.updateDisplayName(name.text);
            Api.auth.currentUser!.updatePhotoURL(_image);
            showSnackBar(context, "Profile Created.");
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
        final ref = Api.storage
            .ref()
            .child('profile_pictures/${Api.auth.currentUser!.uid}.$ext');

        //storage file in ref with path

        //uploading image
        await ref
            .putFile(image, SettableMetadata(contentType: 'image/$ext'))
            .then((p0) async {
          log('data transfered: ${p0.bytesTransferred / 1000} kb');

          final String img = await ref.getDownloadURL();
          log(img);

          final chatUser = ChatUser(
              uid: Api.auth.currentUser!.uid,
              phoneNumber: Api.auth.currentUser!.phoneNumber!,
              name: name.text,
              about: about.text,
              image: img,
              createdAt: time,
              lastActive: time,
              isOnline: true,
              pushToken: "");

          await Api.firestore
              .collection('userdata')
              .doc(Api.auth.currentUser!.uid)
              .set(chatUser.toMap())
              .then((value) {
            setState(() {
              _isloading = false;
            });
            Api.auth.currentUser!.updateDisplayName(name.text);
            Api.auth.currentUser!.updatePhotoURL(_image);
            showSnackBar(context, "Profile Created.");
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
                (route) => false);
          });
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

    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontSize: size.height / 40,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
              ),
        ),
        leading: Icon(
          LineAwesomeIcons.user_1,
          color: Theme.of(context).colorScheme.onPrimary,
          size: size.height / 30,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(isDark ? LineAwesomeIcons.moon : LineAwesomeIcons.sun),
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
                              showBottomSheet(size);
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
                      Icon(Icons.person, size: size.width / 10),
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
                    height: size.height / 30,
                  ),
                  buildButton(
                    size: size,
                    color1: w2,
                    color2: b1,
                    submit: _isloading ? () {} : submit,
                    widget: _isloading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Submit",
                            style: TextStyle(
                              color: b1,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
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
}
