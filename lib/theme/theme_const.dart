import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  textTheme: GoogleFonts.comfortaaTextTheme(),
  colorScheme: ColorScheme.light(
    background: Colors.greenAccent.shade100,
    onBackground: Colors.black,
    primary: Colors.green,
    onPrimary: Colors.black,
    secondary: Colors.white,
    onSecondary: Colors.black,
    secondaryContainer: Colors.white,
    onPrimaryContainer: const Color.fromARGB(210, 0, 0, 0),
    tertiary: const Color.fromARGB(255, 17, 86, 19),
  ),
);

ThemeData darkTheme = ThemeData(
  textTheme: GoogleFonts.comfortaaTextTheme(),
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    background: Color.fromARGB(255, 2, 26, 47),
    onBackground: Colors.white,
    primary: Color.fromARGB(255, 8, 20, 31),
    onPrimary: Colors.white,
    secondary: Colors.white,
    onSecondary: Colors.black,
    secondaryContainer: Color.fromARGB(255, 22, 21, 21),
    onPrimaryContainer: Colors.white60,
    tertiary: Color.fromARGB(255, 21, 51, 79),
  ),
);
