import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  late String phoneNumber;
  late String uid;
  late List<String> usersList;
  late List<String> groupList;
  UserModel({
    required this.usersList,
    required this.groupList,
    required this.uid,
    required this.phoneNumber,
  });

  //from map
  factory UserModel.fromMap(Map<String, dynamic> json) {
    return UserModel(
      phoneNumber: json['phoneNumber'] as String,
      uid: json['uid'] as String,
      usersList:
          (json['usersList'] as List<dynamic>).map((e) => e as String).toList(),
      groupList:
          (json['groupList'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  //to map

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "phoneNumber": phoneNumber,
      "groupList": groupList,
      "usersList": usersList,
    };
  }
}

abstract class AuthBase {
  Future<UserModel> currentUser();
  Stream<UserModel> get onAuthStateChanged;
  Future<void> signOut();
}

class Auth implements AuthBase {
  final _firebaseAuth = FirebaseAuth.instance;

  UserModel _userFromFirebase(User? user) {
    return UserModel(
        uid: user!.uid,
        phoneNumber: user.phoneNumber!,
        groupList: [],
        usersList: []);
  }

  @override
  Future<UserModel> currentUser() async {
    final user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  @override
  Stream<UserModel> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
