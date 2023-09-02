import 'package:chat_mess/screens/auth/login_screen.dart';
import 'package:chat_mess/widgets/consts.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
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
                color2: b1,
                submit: () {
                  Navigator.of(context).push(PageTransition(
                      child: const LoginScreen(),
                      type: PageTransitionType.rightToLeftWithFade));
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
