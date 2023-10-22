import 'dart:async';
import 'dart:developer';

import 'package:chat_mess/screens/auth/login_screen.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:page_transition/page_transition.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height / 10,
              ),
              buildSticker(image: image1, size1: 0, size2: size.height / 2.1),
              Text(
                "Welcome to",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: size.height / 40,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.8),
                    ),
              ),
              Text(
                "Chat Messenger",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: size.height / 25,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.8),
                    ),
              ),
              SizedBox(
                height: size.height / 30,
              ),
              // _buildButton(size, context),
              buildButton(
                size: size,
                color1: w2,
                submit: () {
                  checkConnectionStatus();
                  hasInternet
                      ? Navigator.of(context).push(PageTransition(
                          child: const LoginScreen(),
                          type: PageTransitionType.rightToLeftWithFade))
                      : null;
                },
                widget: const Text(
                  "Get Started",
                  style: TextStyle(
                    color: b1,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
