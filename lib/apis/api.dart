import 'package:chat_mess/models/chat_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Api {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User user = auth.currentUser!;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static late ChatUser me;

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('userdata')
        .where('uid', isNotEqualTo: auth.currentUser!.uid)
        .snapshots();
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('userdata').doc(user.uid).get().then((value) {
      if (value.exists) {
        me = ChatUser.fromMap(value.data()!);
      }
    });
  }

  static Future<void> getUserList() async {}
}
