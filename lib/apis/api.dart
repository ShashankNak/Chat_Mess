import 'dart:developer';
import 'dart:io';
import 'package:chat_mess/models/chat_msg_model.dart';
import 'package:chat_mess/models/chat_user_model.dart';
import 'package:chat_mess/models/group_model.dart';
import 'package:chat_mess/models/group_msg_model.dart';
import 'package:chat_mess/models/user_model.dart';
import 'package:chat_mess/screens/home/home_screen.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class Api {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static User user = auth.currentUser!;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static late ChatUser me;

  static get type => null;

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

  //for personal messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationId(user.uid)}/messages/')
        .orderBy("sentTime", descending: true)
        .snapshots();
  }

  //for group messages

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllGroupMessages(
      GroupModel group) {
    return firestore
        .collection('groupChat/${group.id}/messages/')
        .orderBy("sentTime", descending: true)
        .snapshots();
  }

  //for personal chats

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
        read: "",
        chatImage: "",
        type: Type.text);
    final ref =
        firestore.collection('chats/${getConversationId(user.uid)}/messages/');

    await ref.doc(time).set(message.toMap());
  }

  //for Group chats
  static Future<void> sendGroupMessage(GroupModel group, String msg) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    Map<String, dynamic> deleteChat = {};

    for (String i in group.users) {
      deleteChat.addAll({i: false});
    }

    final message = GroupMessageModel(
      text: msg,
      groupId: group.id,
      fromId: auth.currentUser!.uid,
      sentTime: time,
      deleteChat: deleteChat,
      type: TypeG.text,
      chatImage: '',
    );
    final ref = firestore.collection('groupChat/${group.id}/messages/');

    await ref.doc(time).set(message.toMap());
  }

  //for personal chats
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

  //for group Chats
  static Future<void> deleteGroupMessageForAll(GroupMessageModel msg) async {
    if (msg.type == TypeG.image) {
      final ext = msg.chatImage.split("?").first.split(".").last;
      log('images/${msg.groupId}/${msg.sentTime}.$ext');
      try {
        final ref = Api.storage
            .ref()
            .child('images/${msg.groupId}/${msg.sentTime}.$ext');
        await ref.delete();
      } catch (e) {
        log(e.toString());
        return;
      }
    }
    await firestore
        .collection('groupChat/${msg.groupId}/messages/')
        .doc(msg.sentTime)
        .delete();
  }

  static Future<void> deleteGroupMessageForMe(GroupMessageModel msg) async {
    msg.deleteChat[auth.currentUser!.uid] = true;
    await firestore
        .collection('groupChat/${msg.groupId}/messages/')
        .doc(msg.sentTime)
        .update(msg.toMap());
  }

  //for personal chats
  static Future<void> deleteMessageForMe(MessageModel msg) async {
    msg.deleteChat[auth.currentUser!.uid] = true;
    await firestore
        .collection('chats/${msg.chatId}/messages/')
        .doc(msg.sentTime)
        .update(msg.toMap());
  }

  static Future<void> deleteMessageForAll(MessageModel msg) async {
    if (msg.type == Type.image) {
      final ext = msg.chatImage.split("?").first.split(".").last;
      log('images/${getConversationId(msg.toId)}/${msg.sentTime}.$ext');
      try {
        final ref = Api.storage.ref().child(
            'images/${getConversationId(msg.toId)}/${msg.sentTime}.$ext');
        await ref.delete();
      } catch (e) {
        log(e.toString());
        return;
      }
    }
    await firestore
        .collection('chats/${msg.chatId}/messages/')
        .doc(msg.sentTime)
        .delete();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUsersList() {
    return firestore.collection("users").doc(auth.currentUser!.uid).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> searchUsers(
      List<String> users) {
    return firestore
        .collection("userdata")
        .where('uid', whereIn: users)
        .snapshots();
  }

  //For group
  static Future<bool> exitGroup(GroupModel group, BuildContext context) async {
    if (group.admins.contains(auth.currentUser!.uid) &&
        group.admins.length == 1) {
      showSnackBar(context, "Atleast 1 admin Needed. Make anyone Admin.");
      return false;
    }
    group.admins.remove(auth.currentUser!.uid);
    group.users.remove(auth.currentUser!.uid);
    await firestore
        .collection("groupdata")
        .doc(group.id)
        .update(group.toJson());

    final raw = await firestore
        .collection("users")
        .doc(Api.auth.currentUser!.uid)
        .get();

    final data = UserModel.fromMap(raw.data()!);
    data.groupList.remove(group.id);
    await firestore
        .collection("users")
        .doc(Api.auth.currentUser!.uid)
        .update(data.toMap())
        .then((value) {
      showSnackBar(context, "Leaving ${group.name}..");
      Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
              child: const HomeScreen(), type: PageTransitionType.fade),
          (route) => false);
    });
    return false;
  }

  static Future<bool> deleteGroup(
      GroupModel group, BuildContext context) async {
    for (String id in group.users) {
      final raw = await firestore.collection('users').doc(id).get();
      if (!raw.exists || raw.data() == null) {
        continue;
      }
      final data = UserModel.fromMap(raw.data()!);
      data.groupList.remove(group.id);
      await firestore.collection('users').doc(id).update(data.toMap());
    }
    await firestore.collection("groupdata").doc(group.id).delete();
    await firestore
        .collection("groupChat")
        .doc(group.id)
        .delete()
        .then((value) {
      showSnackBar(context, "Leaving ${group.name}..");
      Navigator.of(context).pushAndRemoveUntil(
          PageTransition(
              child: const HomeScreen(), type: PageTransitionType.fade),
          (route) => false);
    });
    return false;
  }

  static Future<GroupModel> makeGroupAdmin(
      GroupModel group, ChatUser user) async {
    group.admins.add(user.uid);
    await firestore
        .collection('groupdata')
        .doc(group.id)
        .update(group.toJson());
    return group;
  }

  static Future<GroupModel> removeFromGroupAdmin(
      GroupModel group, ChatUser user) async {
    group.admins.remove(user.uid);
    await firestore
        .collection('groupdata')
        .doc(group.id)
        .update(group.toJson());
    return group;
  }

  static Future<GroupModel> kickFromTheGroup(
      GroupModel group, ChatUser user) async {
    final raw = await firestore.collection('users').doc(user.uid).get();
    if (!raw.exists || raw.data() == null) {
      return group;
    }
    final data = UserModel.fromMap(raw.data()!);
    data.groupList.remove(group.id);
    await firestore.collection('users').doc(user.uid).update(data.toMap());
    group.admins.remove(user.uid);
    group.users.remove(user.uid);
    await firestore
        .collection("groupdata")
        .doc(group.id)
        .update(group.toJson());
    return group;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> searchForAddUser(
      List<String> users) {
    return firestore
        .collection("userdata")
        .where('uid', whereIn: users)
        .snapshots();
  }

  static Future<GroupModel> addMemberToGroup(
      GroupModel group, List<String> uids) async {
    for (String uid in uids) {
      final raw = await firestore.collection("users").doc(uid).get();
      if (raw.data() == null) {
        continue;
      }
      final user = UserModel.fromMap(raw.data()!);
      user.groupList.add(group.id);
      await firestore.collection('users').doc(uid).update(user.toMap());

      group.users.add(user.uid);
      await firestore
          .collection("groupdata")
          .doc(group.id)
          .update(group.toJson());
    }
    return group;
  }

  //Image sending in chat
  static Future<void> sendChatImageMessage(
      ChatUser user, String image, String text) async {
    final file = File(image);
    final ext = file.path.split(".").last;
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final id = getConversationId(user.uid);

    final ref = Api.storage
        .ref()
        .child('images/${getConversationId(user.uid)}/$time.$ext');

    //storage file in ref with path

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) async {
      log('data transfered: ${p0.bytesTransferred / 1000} kb');

      final String img = await ref.getDownloadURL();
      log(img);
      final message = MessageModel(
          text: text,
          toId: user.uid,
          fromId: auth.currentUser!.uid,
          chatId: id,
          sentTime: time,
          deleteChat: {
            auth.currentUser!.uid: false,
            user.uid: false,
          },
          read: "",
          chatImage: img,
          type: Type.image);

      await firestore
          .collection('chats/$id/messages/')
          .doc(time)
          .set(message.toMap());
    });
  }

  //group sending image
  static Future<void> sendgroupImageMessage(
      GroupModel group, String image, String text) async {
    final file = File(image);
    final ext = file.path.split(".").last;
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = Api.storage.ref().child('images/${group.id}/$time.$ext');

    //storage file in ref with path

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) async {
      log('data transfered: ${p0.bytesTransferred / 1000} kb');
      final String img = await ref.getDownloadURL();
      log(img);

      Map<String, dynamic> deleteChat = {};

      for (String i in group.users) {
        deleteChat.addAll({i: false});
      }

      final message = GroupMessageModel(
        text: text,
        groupId: group.id,
        fromId: auth.currentUser!.uid,
        sentTime: time,
        deleteChat: deleteChat,
        chatImage: img,
        type: TypeG.image,
      );

      await firestore
          .collection('groupChat/${group.id}/messages/')
          .doc(time)
          .set(message.toMap());
    });
  }
}
