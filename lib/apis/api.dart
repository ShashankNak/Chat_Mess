import 'dart:developer';
import 'package:chat_mess/models/chat_msg_model.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/widgets/consts.dart';
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

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(
      String uid) {
    return firestore.collection("userdata").doc(uid).snapshots();
  }

  static Future<void> updateOnlineStatus(bool isOnline) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final i = int.tryParse(time) ?? -1;
    if (i == -1) {
      await firestore.collection("userdata").doc(me.uid).update({
        'isOnline': isOnline,
      });
      return;
    }
    // log("time on function: ${DateTime.fromMillisecondsSinceEpoch(i)}");
    await firestore.collection("userdata").doc(me.uid).update({
      'isOnline': isOnline,
      'lastActive': time,
    });
    return;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('userdata').doc(user.uid).get().then((value) {
      if (value.exists) {
        me = ChatUser.fromMap(value.data()!);
      }
    });
  }

  // static Future<void> getUserList() async {}

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.uid)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser user, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final id = getConversationId(user.uid);

    final message = MessageModel(
        text: msg,
        toId: user.uid,
        fromId: auth.currentUser!.uid,
        chatId: id,
        sentTime: time,
        deleteChat: {
          auth.currentUser!.uid: false,
          user.uid: false,
        },
        read: "");
    final ref =
        firestore.collection('chats/${getConversationId(user.uid)}/messages/');

    await ref.doc(time).set(message.toMap());
  }

  static Future<void> updateMessageReadStatus(String uid) async {
    final snapshot = await firestore
        .collection('chats/${getConversationId(uid)}/messages/')
        .get();

    if (snapshot.docs.isEmpty) {
      log("empty");
      return;
    }
    final data =
        snapshot.docs.map((e) => MessageModel.fromJson(e.data())).toList();
    final now = DateTime.now().millisecondsSinceEpoch.toString();

    for (MessageModel m in data) {
      if (m.read.isEmpty && m.fromId != me.uid) {
        m.read = now;
        log("updating.....");
        log(m.read);
        await firestore
            .collection('chats/${getConversationId(uid)}/messages/')
            .doc(m.sentTime)
            .update(m.toMap());
      }
    }
  }

  static Future<void> deleteMessageForMe(MessageModel msg) async {
    msg.deleteChat[auth.currentUser!.uid] = true;
    await firestore
        .collection('chats/${msg.chatId}/messages/')
        .doc(msg.sentTime)
        .update(msg.toMap());
  }

  static Future<void> deleteMessageForAll(MessageModel msg) async {
    await firestore
        .collection('chats/${msg.chatId}/messages/')
        .doc(msg.sentTime)
        .delete();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUsersList() {
    return Api.firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> searchUsers(
      List<String> users) {
    return Api.firestore
        .collection("userdata")
        .where('uid', whereIn: users)
        .snapshots();
  }
}
