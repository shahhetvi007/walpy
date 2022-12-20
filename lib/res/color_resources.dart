import 'package:flutter/material.dart';
import 'package:work_manager_demo/helper/prefs_utils.dart';

const colorWhite = Color(0xffe6e6e6);
const colorBlack = Colors.black;
final colorTheme =
    PreferenceUtils.getString('theme') == 'Light' ? colorBlack : colorWhite;
const colorRed = Colors.red;
const appBarColor = Colors.white60;
const black1 = Colors.black12;
const white1 = Colors.white60;
const grey = Colors.grey;

const lightestPink = Color(0xffD8CBFF);

// const primaryGradient =
//     LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [
//   Color(0xffab91ff),
//   Color(0xfffa5dc7),
//   Color(0xff68ddff),
// ]);

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xff343434),
    100: Color(0xff343434),
    200: Color(0xff343434),
    300: Color(0xff343434),
    400: Color(0xff343434),
    500: Color(_blackPrimaryValue),
    600: Color(0xff343434),
    700: Color(0xff343434),
    800: Color(0xff343434),
    900: Color(0xff343434),
  },
);
const int _blackPrimaryValue = 0xff343434;

const MaterialColor primaryWhite = MaterialColor(
  _whitePrimaryValue,
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
