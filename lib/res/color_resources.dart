import 'package:flutter/material.dart';

const colorTheme = Color(0xff000000);
const colorWhite = Color(0xffffffff);
const colorRed = Colors.red;
const appBarColor = Colors.white60;
final black1 = Colors.black.withOpacity(0.2);
const white1 = Colors.white60;
const grey = Colors.grey;

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
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xffffffff),
    100: Color(0xffffffff),
    200: Color(0xffffffff),
    300: Color(0xffffffff),
    400: Color(0xffffffff),
    500: Color(_whitePrimaryValue),
    600: Color(0xffffffff),
    700: Color(0xffffffff),
    800: Color(0xffffffff),
    900: Color(0xffffffff),
  },
);
const int _whitePrimaryValue = 0xffffffff;
