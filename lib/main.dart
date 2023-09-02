import 'dart:developer';
import 'package:chat_mess/apis/api.dart';
import 'package:chat_mess/screens/auth/make_profile_screen.dart';
import 'package:chat_mess/screens/auth/start_screen.dart';
import 'package:chat_mess/screens/home/home_screen.dart';
import 'package:chat_mess/theme/theme_const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent));

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatMess',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: StreamBuilder<User?>(
          stream: Api.auth.authStateChanges(),
          builder: (context, snapshot) {
            try {
              if (snapshot.hasData && snapshot.data != null) {
                snapshot.data!.reload();
              }
            } catch (e) {
              log(e.toString());
            }

            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasData && snapshot.data != null) {
                  log(snapshot.data!.uid);
                  if (snapshot.data!.displayName == null) {
                    return const MakeProfileScreen();
                  } else {
                    return const HomeScreen();
                  }
                }
                return const StartScreen();
            }
          }),
    );
  }
}
