import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:chat_mess/apis/api.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';

const String userChatfolder = 'user_chat_DB';
const String userChatdb = 'user_chat.db';
const String chatMessagefolder = 'chat_message_DB';
const String chatMessagedb = 'chat_message.db';

const Color g1 = Color.fromARGB(255, 26, 56, 103);
const Color g2 = Color.fromARGB(255, 40, 57, 92);
const Color ab1 = Color.fromARGB(255, 44, 57, 87);
const Color ab2 = Color.fromARGB(237, 16, 61, 106);
const Color w1 = Colors.white;
const Color w2 = Color.fromARGB(172, 255, 255, 255);
const Color b1 = Colors.black;
const Color b2 = Color.fromARGB(176, 0, 0, 0);

const String image1 = 'assets/animation/1.json';
const String image2 = 'assets/animation/2.json';
const String image3 = 'assets/animation/3.json';
const String image4 = 'assets/animation/4.json';
const String profile1 = 'assets/images/p1.png';
const String profile2 = 'assets/images/p2.png';
const String profile3 = 'assets/images/p3.png';
const String chatIcon = 'assets/images/chat_icon.png';
const String gallery = 'assets/images/gallery.png';
const String camera = 'assets/images/camera.png';

showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

buildSticker(
    {required String image, required double size1, required double size2}) {
  return Container(
    margin: EdgeInsets.only(top: size1),
    child: Lottie.asset(
      image,
      height: size2,
      repeat: true,
      reverse: true,
      fit: BoxFit.cover,
    ),
  );
}

String timeGetter(String time, BuildContext context) {
  final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
  final dayTime = TimeOfDay.fromDateTime(date).format(context);
  return dayTime;
}

String getLastActiveTime(
    {required BuildContext context, required String lastActive}) {
  final i = int.tryParse(lastActive) ?? -1;
  if (i == -1) {
    return "Last Active Time Not Available";
  }

  final time = DateTime.fromMillisecondsSinceEpoch(i);
  // log(time.toString());
  final now = DateTime.now();

  final formattedTime = TimeOfDay.fromDateTime(time).format(context);
  if (now.day == time.day && now.month == time.month && now.year == time.year) {
    return "Last Seen today at $formattedTime";
  }

  if ((now.difference(time).inHours / 24).round() == 1) {
    return "Last Seen Yesterday at $formattedTime";
  }

  if (now.year - time.year > 1) {
    return "Last seen on ${time.day} ${getMonth(time)},${time.year} on $formattedTime";
  }

  return "Last seen on ${time.day} ${getMonth(time)} on $formattedTime";
}

String dateGetter(String time1, BuildContext context) {
  final time = DateTime.fromMillisecondsSinceEpoch(int.parse(time1));

  final now = DateTime.now();

  if (now.day == time.day && now.month == time.month && now.year == time.year) {
    return "Today";
  }
  if (now.month == time.month &&
      now.year == time.year &&
      now.day - time.day == 1) {
    return "Yesterday";
  }

  if (now.year - time.year > 1) {
    final date =
        "${time.day.toString()} ${getMonth(time)},${time.year.toString()}";
    return date;
  }
  return "${time.day.toString()} ${getMonth(time)}";
}

String getMonth(DateTime data) {
  switch (data.month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
  }
  return "NA";
}

buildButton(
    {required Size size,
    required Color color1,
    required Color color2,
    required VoidCallback submit,
    required Widget widget}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color1,
      fixedSize: Size(size.width / 1.3, size.height / 15),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(size.height / 8),
        ),
      ),
    ),
    onPressed: submit,
    child: widget,
  );
}

String convertNumber(String n) {
  String number = "";
  for (int i = 0; i < n.length; i++) {
    if (num.tryParse(n[i]) != null) {
      number = number + n[i];
    }
  }
  return number;
}

String getConversationId(String id) {
  final uid = Api.auth.currentUser!.uid;
  return uid.hashCode <= id.toString().hashCode
      ? '${uid.toString()}_${id.toString()}'
      : '${id.toString()}_${uid.toString()}';
}

String formatNumber(String number) {
  final num3 = number.substring(number.length - 5);
  final num2 = number.substring(number.length - 10, number.length - 5);
  if (number.length > 10) {
    final num1 = number.substring(0, number.length - 10);
    return "$num1 $num2 $num3";
  }
  return "$num2 $num3";
}

Future<String> createInternalFolder(String folder) async {
  final abc = (await getExternalStorageDirectories())!.first;
  final path = Directory("${abc.path}/$folder");
  String res = '';

  if (await path.exists()) {
    log("Existed file");
    res = path.path;
  } else {
    log("created new folder");
    final Directory appDocDirNewFolder = await path.create(recursive: true);
    res = appDocDirNewFolder.path;
  }
  return res;
}

Future<void> deletefile(Directory file) async {
  log("entered delete");
  final s = await file.exists();
  log(s.toString());
  try {
    if (await file.exists()) {
      log("deleting");
      await file.delete().then((value) {
        log("deleted: ${value.path}");
      });
    }
  } catch (e) {
    // error in getting access to the file.
  }
}
