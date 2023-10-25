import 'dart:developer';
import 'dart:io';

import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/models/group_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class GroupImageUploadScreen extends StatefulWidget {
  const GroupImageUploadScreen(
      {super.key, required this.file, required this.group});
  final XFile file;
  final GroupModel group;

  @override
  State<GroupImageUploadScreen> createState() => _GroupImageUploadScreenState();
}

class _GroupImageUploadScreenState extends State<GroupImageUploadScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _image;
  int counter = 0;
  bool _isLoadingImg = false;
  bool time = false;
  @override
  void initState() {
    super.initState();
    imagePicker();
  }

  void testCompressAndGetFile(String path, String targetPath) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      quality: 70,
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

      _image = image.path;
      setState(() {});
      log(_image!);
      setState(() {
        _isLoadingImg = false;
      });
      return;
    }
  }

  //for picking and compressing image

  void imagePicker() async {
    // final ImagePicker picker = ImagePicker();
    // XFile? photo = await picker.pickImage(source: ImageSource.camera);
    final path =
        "/data/user/0/com.example.chat_mess/cache/${Api.auth.currentUser!.uid}$counter.jpeg";

    log("image size: ${await widget.file.length()}");
    log("image path: ${widget.file.path}");
    testCompressAndGetFile(widget.file.path, path);
    log("counter: $counter");
    setState(() {
      counter++;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(37, 33, 33, 33),
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              )),
          title: Text(
            "Edit Image",
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontSize: size.height / 30, color: Colors.white),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 21, 21, 21),
        body: _isLoadingImg
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : SizedBox(
                height: size.height,
                width: size.width,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height / 10,
                      ),
                      if (_image != null)
                        Image.file(
                          File(_image!),
                          width: size.width,
                          height: size.height / 1.7,
                          fit: BoxFit.cover,
                        ),
                      SizedBox(
                        height: size.height / 60,
                      ),
                      messageInput(isDark, size),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget messageInput(bool isDark, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: size.height / 90,
        horizontal: size.width / 90,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: const Color.fromARGB(82, 74, 73, 73),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width / 10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width / 20),
                child: TextField(
                  // onEditingComplete: () =>
                  //     Api.sendMessage(widget.user, _messageController.text),
                  controller: _messageController,
                  // onSubmitted: (value) =>
                  //     Api.sendMessage(widget.user, _messageController.text),
                  cursorColor: Colors.white,
                  autocorrect: false,
                  minLines: 1,
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: size.height / 50, color: Colors.white),
                  decoration: InputDecoration(
                    label: Text(
                      "Type Here...",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: Colors.white),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width / 90,
          ),
          MaterialButton(
            color: const Color.fromARGB(82, 74, 73, 73),
            padding: const EdgeInsets.all(15),
            shape: const CircleBorder(),
            onPressed: () {
              if (_image == null) {
                Navigator.of(context).pop();
                return;
              }
              setState(() {
                _isLoadingImg = true;
              });
              Api.sendgroupImageMessage(
                      widget.group, _image!, _messageController.text)
                  .then((value) {
                _messageController.clear();

                setState(() {
                  _isLoadingImg = false;
                });
                Navigator.of(context).pop();
              });
              // Api.sendMessage(widget.user, _messageController.text);
            },
            minWidth: 0,
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: size.width / 12,
            ),
          )
        ],
      ),
    );
  }
}
