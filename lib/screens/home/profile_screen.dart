// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_mess/apis/api.dart';
// import 'package:chat_mess/models/chat_user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/consts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  bool _isLoadingImg = false;
  bool _isLoadingname = false;
  bool _isLoadingabout = false;
  final _formkey = GlobalKey<FormState>();
  int counter = 0;
  String? _image;

  @override
  void initState() {
    setState(() {
      Api.getSelfInfo();
    });
    super.initState();
  }

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
      setState(() {
        _isLoadingImg = true;
      });

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
        await Api.firestore
            .collection('userdata')
            .doc(Api.auth.currentUser!.uid)
            .update({"image": img});
        Api.getSelfInfo();
        await Api.auth.currentUser!.updatePhotoURL(img);
      });
      setState(() {
        _isLoadingImg = false;
      });
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
    final size = MediaQuery.of(context).size;

    void submit(String field) async {
      final isValid = _formkey.currentState!.validate();
      if (!isValid) {
        return;
      }
      FocusScope.of(context).unfocus();
      _formkey.currentState!.save();
      if (field == "Name") {
        setState(() {
          _isLoadingname = true;
        });
        await Api.auth.currentUser!.updateDisplayName(_nameController.text);
        await Api.firestore
            .collection('userdata')
            .doc(Api.auth.currentUser!.uid)
            .update({"name": _nameController.text}).then((value) {
          _nameController.text = "";
          Navigator.of(context).pop();
          Api.getSelfInfo();
          setState(() {
            _isLoadingname = false;
          });
        });
        return;
      } else {
        setState(() {
          _isLoadingabout = true;
        });
        await Api.firestore
            .collection('userdata')
            .doc(Api.auth.currentUser!.uid)
            .update({"about": _aboutController.text}).then((value) {
          _aboutController.text = "";
          Navigator.of(context).pop();
          Api.getSelfInfo();
          setState(() {
            _isLoadingabout = false;
          });
        });
        return;
      }
    }

    void showBottomSheetForEdit(
        Size size, String field, TextEditingController textEditingController) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
                top: size.height / 40,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    size.height / 80),
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: size.width / 50),
              children: [
                Text(
                  "Edit $field",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: size.height / 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
                SizedBox(
                  height: size.height / 40,
                ),
                Form(
                  key: _formkey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(field == "Name" ? Icons.person : Icons.info_outline,
                          size: size.width / 10),
                      SizedBox(
                        width: size.width / 20,
                      ),
                      Expanded(
                        child: TextFormField(
                          validator: (value) {
                            if (field == "Name") {
                              if (value == null || value.trim().length < 3) {
                                return "Invalid Name. Must be atleast 3 characters long";
                              }
                            }
                            return null;
                          },
                          controller: textEditingController,
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
                            labelText: field,
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
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: _isLoadingname || _isLoadingabout
                          ? null
                          : () {
                              if (field == 'Name') {
                                _nameController.text = "";
                              } else {
                                _aboutController.text = "";
                              }
                              Navigator.of(context).pop();
                            },
                      child: Text(
                        "Cancel",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: size.height / 40,
                            color: Theme.of(context).colorScheme.onBackground),
                      ),
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(size.width / 3, size.height / 20),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.4)),
                        onPressed: (_isLoadingname || _isLoadingabout)
                            ? null
                            : () {
                                submit(field);
                              },
                        child: (_isLoadingname || _isLoadingabout)
                            ? const CircularProgressIndicator()
                            : Text(
                                "Edit",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                        fontSize: size.height / 40,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                              ))
                  ],
                )
              ],
            ),
          );
        },
      );
    }

    void showBottomSheetForImage(Size size) {
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Your Profile",
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
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(size.height / 7),
                      child: _image == null
                          ? Api.me.image == ""
                              ? Image.asset(
                                  profile2,
                                  height: size.height / 4,
                                  width: size.height / 4,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: Api.me.image,
                                  height: size.height / 4,
                                  width: size.height / 4,
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                    profile2,
                                    height: size.height / 4,
                                    width: size.height / 4,
                                    fit: BoxFit.cover,
                                  ),
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
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimary
                                .withOpacity(0.6)),
                        child: _isLoadingImg
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: size.height / 30,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                onPressed: () {
                                  showBottomSheetForImage(size);
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.person, size: size.width / 10),
                    SizedBox(
                      width: size.width / 20,
                    ),
                    Expanded(
                        child: Text(
                      Api.me.name,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: size.height / 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    )),
                    _isLoadingname
                        ? const CircularProgressIndicator()
                        : IconButton(
                            onPressed: () {
                              showBottomSheetForEdit(
                                  size, "Name", _nameController);
                            },
                            icon: const Icon(Icons.edit)),
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
                      Api.me.about,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontSize: size.height / 30,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    )),
                    _isLoadingabout
                        ? const CircularProgressIndicator()
                        : IconButton(
                            onPressed: () {
                              showBottomSheetForEdit(
                                  size, "About", _aboutController);
                            },
                            icon: const Icon(Icons.edit)),
                  ],
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
                    Icon(Icons.phone, size: size.width / 10),
                    SizedBox(
                      width: size.width / 20,
                    ),
                    Expanded(
                        child: Text(
                      formatNumber(Api.me.phoneNumber),
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
