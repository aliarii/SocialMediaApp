import 'package:flutter/material.dart';

class ThemeProvider{

  static final darkTheme=ThemeData(
    scaffoldBackgroundColor: Colors.black,
    dialogBackgroundColor: Colors.black,
    primarySwatch: primaryBlack,
    //cardColor: Colors.orange,
    hintColor: Colors.white,
    accentColor: Colors.black,
    colorScheme: ColorScheme.dark(),
    backgroundColor: Colors.black,


  );
  static final lightTheme=ThemeData(
    scaffoldBackgroundColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    primarySwatch: primaryWhite,
    //cardColor: Colors.black,
    hintColor: Colors.black,
    accentColor: Colors.white,
    colorScheme: ColorScheme.light(),
    backgroundColor: Colors.white,
  );



}
const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _blackPrimaryValue = 0xFF000000;

const MaterialColor primaryWhite = MaterialColor(
  _whitePrimaryValue,
  <int, Color>{
    50: Color(0xFFFFFFFF),
    100: Color(0xFFFFFFFF),
    200: Color(0xFFFFFFFF),
    300: Color(0xFFFFFFFF),
    400: Color(0xFFFFFFFF),
    500: Color(_whitePrimaryValue),
    600: Color(0xFFFFFFFF),
    700: Color(0xFFFFFFFF),
    800: Color(0xFFFFFFFF),
    900: Color(0xFFFFFFFF),
  },
);
const int _whitePrimaryValue = 0xFFFFFFFF;
