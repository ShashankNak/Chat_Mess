import 'dart:convert';
import 'dart:developer';
import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/screens/auth/otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/consts.dart';
import '../models/user_model.dart';

class AuthState {
  bool isSignedIn;
  bool isLoading;
  String uid;
  UserModel userModel;

  AuthState({
    required this.isSignedIn,
    required this.isLoading,
    required this.uid,
    required this.userModel,
  });
}

class AuthProvider extends StateNotifier<AuthState> {
  AuthProvider()
      : super(AuthState(
            isSignedIn: false,
            isLoading: false,
            uid: '',
            userModel: UserModel(
                phoneNumber: '', uid: '', groupList: [], usersList: []))) {
    checkSign();
  }

  void signInWithPhone(
      BuildContext context, String phoneNumber, String phoneCode) async {
    state.isLoading = true;
    try {
      await Api.auth.verifyPhoneNumber(
        phoneNumber: "+$phoneCode$phoneNumber",
        verificationCompleted: (phoneAuthCredential) async {
          await Api.auth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          showSnackBar(context, error.message.toString());
          state.isLoading = true;
          log(error.message.toString());
          Navigator.of(context).pop();
        },
        codeSent: (verificationId, forceResendingToken) {
          state.isLoading = false;
          Navigator.of(context).push(
            PageTransition(
                child: OtpScreen(
                  verificationId: verificationId,
                  phoneNumber: phoneNumber,
                  phonecode: phoneCode,
                ),
                type: PageTransitionType.rightToLeftWithFade),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      () {
        Navigator.of(context).pop();
        state.isLoading = false;
        showSnackBar(context, e.message.toString());
      };
    }
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();

    state.isSignedIn = s.getBool("is_signedin") ?? false;
    // notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    state.isSignedIn = true;
    // notifyListeners();
  }

  void verifyOtp(
      {required BuildContext context,
      required String verificationId,
      required String userOtp,
      required Function onSuccess}) async {
    state.isLoading = true;
    // notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);
      User? user = (await Api.auth.signInWithCredential(creds)).user;

      if (user != null) {
        state.uid = user.uid;
        onSuccess();
      }
      state.isLoading = false;
      // notifyListeners();
    } on FirebaseAuthException catch (e) {
      () {
        showSnackBar(context, e.message.toString());
        state.isLoading = false;
        Navigator.of(context).pop();
      };
    }
  }

  Future<bool> checkExistingUser() async {
    final snapshot =
        await Api.firestore.collection('users').doc(state.uid).get();
    if (snapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  void saveUserDataToFirebase(
      {required BuildContext context,
      required UserModel userModel,
      required Function onSuccess}) async {
    state.isLoading = true;
    // notifyListeners();
    try {
      state.userModel = userModel;
      await Api.firestore
          .collection('users')
          .doc(state.uid)
          .set(userModel.toMap())
          .then((value) {
        onSuccess();
        state.isLoading = false;
        // notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      () {
        showSnackBar(context, e.message.toString());

        state.isLoading = false;
        Navigator.of(context).pop();
      };
    }
  }

  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(state.userModel.toMap()));
  }

  //this method is not used
  Future<AuthState> getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? '';
    state.userModel = UserModel.fromMap(jsonDecode(data));
    state.uid = state.userModel.uid;
    return state;
    // notifyListeners();
  }
}

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider();
});
