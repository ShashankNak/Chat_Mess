import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  textTheme: GoogleFonts.comfortaaTextTheme(),
  colorScheme: ColorScheme.light(
    background: Colors.blue.shade200,
    onBackground: Colors.black,
    primary: Colors.blue.shade400,
    onPrimary: Colors.black,
    secondary: Colors.white,
    onSecondary: Colors.black,
    secondaryContainer: Colors.white,
    onPrimaryContainer: const Color.fromARGB(210, 0, 0, 0),
  ),
);

ThemeData darkTheme = ThemeData(
  textTheme: GoogleFonts.comfortaaTextTheme(),
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    background: Colors.black,
    onBackground: Colors.white,
    primary: Color.fromARGB(255, 35, 35, 35),
    onPrimary: Colors.white,
    secondary: Colors.white,
    onSecondary: Colors.black,
    secondaryContainer: Color.fromARGB(255, 22, 21, 21),
    onPrimaryContainer: Colors.white60,
  ),
);
