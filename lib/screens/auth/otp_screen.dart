import 'dart:async';
import 'dart:developer';

import 'package:chat_mess/provider/auth_provider.dart';
import 'package:chat_mess/screens/auth/make_profile_screen.dart';
import 'package:chat_mess/screens/home/home_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/consts.dart';
import '../../models/user_model.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen(
      {super.key,
      required this.phonecode,
      required this.verificationId,
      required this.phoneNumber});
  final String verificationId;
  final String phonecode;
  final String phoneNumber;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController pinController = TextEditingController();
  bool isLoading = false;

  bool hasInternet = true;
  late StreamSubscription subscription;
  late StreamSubscription internetSubscription;
  void checkConnectionStatus() {
    subscription = Connectivity().onConnectivityChanged.listen((event) {
      final isInternet = event != ConnectivityResult.none;
      if (mounted) {
        setState(() {
          hasInternet = isInternet;
        });
      }
    });
    internetSubscription =
        InternetConnectionChecker().onStatusChange.listen((event) {
      final isInternet = event == InternetConnectionStatus.connected;
      if (mounted) {
        setState(() {
          hasInternet = isInternet;
        });
        if (!hasInternet) {
          showSnackBar(context, "No Internet");
        }
      }
    });
    log("Has Internet: ${hasInternet.toString()}");
  }

  @override
  void initState() {
    super.initState();
    checkConnectionStatus();
  }

  @override
  void dispose() {
    super.dispose();
    subscription.cancel();
    internetSubscription.cancel();
  }

  void verifyOtp(BuildContext context, String userOtp) {
    setState(() {
      isLoading = true;
    });
    final ap = ref.watch(authProvider.notifier);
    final authState = ref.read(authProvider);

    ap.verifyOtp(
        context: context,
        verificationId: widget.verificationId,
        userOtp: userOtp,
        onSuccess: () {
          ap.checkExistingUser().then((value) async {
            if (value) {
              setState(() {
                isLoading = false;
              });
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                  (route) => false);
            } else {
              UserModel userModel = UserModel(
                uid: authState.uid,
                phoneNumber: "+${widget.phonecode}${widget.phoneNumber}",
                groupList: [],
                usersList: [],
              );
              setState(() {
                isLoading = false;
              });
              ap.saveUserDataToFirebase(
                  context: context,
                  userModel: userModel,
                  onSuccess: () {
                    ap.saveUserDataToSP().then((value) => ap.setSignIn().then(
                        (value) => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const MakeProfileScreen(),
                            ),
                            (route) => false)));
                  });
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final defaultPinTheme = PinTheme(
      width: size.height / 17,
      height: size.height / 17,
      textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: size.height / 40,
            color: Theme.of(context).colorScheme.secondary,
          ),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: size.height / 40,
            color: Theme.of(context).colorScheme.onBackground,
          ),
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Theme.of(context).colorScheme.onBackground),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      textStyle: TextStyle(
          fontSize: size.height / 40,
          color: const Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildSticker(
                      image: image3,
                      size1: size.height / 90,
                      size2: size.height / 2.3,
                    ),
                    Text(
                      "A SMS with a One Time Password (OTP) has been sent to ${formatNumber(widget.phoneNumber)}",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: size.height / 40,
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withOpacity(0.8),
                          ),
                    ),
                    SizedBox(
                      height: size.height / 80,
                    ),
                    Text(
                      "Enter OTP",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: size.height / 35,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                    SizedBox(
                      height: size.height / 30,
                    ),
                    Pinput(
                      length: 6,
                      controller: pinController,
                      androidSmsAutofillMethod: AndroidSmsAutofillMethod.none,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: submittedPinTheme,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      showCursor: true,
                    ),
                    SizedBox(
                      height: size.height / 30,
                    ),
                    buildButton(
                      size: size,
                      color1: w2,
                      color2: b1,
                      submit: () {
                        if (hasInternet) {
                          if (pinController.text.trim().length == 6) {
                            verifyOtp(context, pinController.text.trim());
                          } else {
                            showSnackBar(context, "Enter 6-Digit Code");
                          }
                        }
                      },
                      widget: isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Continue",
                              style: TextStyle(
                                color: b1,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                    )
                  ],
                ),
                Positioned(
                  top: size.height / 15,
                  left: size.width / 20,
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
