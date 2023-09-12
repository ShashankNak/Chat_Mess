import 'package:chat_mess/apis/api.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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

DateTime dateTimeGetter(String time) {
  final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
  // final now = DateTime.now();

  // if(now.day==date.day && now.month==date.month&&now.year==now.year){}
  return date;
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
