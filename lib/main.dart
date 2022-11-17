import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/helper/prefs_utils.dart';
import 'package:work_manager_demo/helper/wallpaper_Setting.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/home_screen.dart';
import 'package:work_manager_demo/screens/signin_screen.dart';
import 'package:workmanager/workmanager.dart';

const myTask = "syncWithTheBackEnd";
const periodicTask = "periodicTask";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Workmanager().initialize(callbackDispatcher);
  await PreferenceUtils.init();
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    switch (task) {
      case myTask:
        print("this method was called from native!");
        break;
      case periodicTask:
        print("this method was called from periodic task!");
        await WallpaperSetting().setWallpaper();
        break;
      case Workmanager.iOSBackgroundTask:
        print("iOS background fetch delegate ran");
        break;
    }

    //Return true when the task executed successfully or not
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  ThemeMode _theme = ThemeMode.system;

  void changeTheme({required ThemeMode theme}) {
    setState(() {
      _theme = theme;
    });
  }

  getTheme() {
    String themeString = PreferenceUtils.getString('theme');
    switch (themeString) {
      case 'Light':
        _theme = ThemeMode.light;
        break;
      case 'Dark':
        _theme = ThemeMode.dark;
        break;
      case 'System':
        _theme = ThemeMode.system;
        break;
      default:
        _theme = ThemeMode.system;
        break;
    }
  }

  @override
  void initState() {
    getTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _theme,
      home: AuthHelper().user != null ? const HomeScreen() : const SignInScreen(),
    );
  }

  ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: primaryWhite,
      primaryColor: colorWhite,
      backgroundColor: colorTheme,
      scaffoldBackgroundColor: colorTheme,
      appBarTheme: const AppBarTheme(
          backgroundColor: colorTheme,
          iconTheme: IconThemeData(color: colorWhite),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: colorWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
      textTheme: const TextTheme(titleLarge: TextStyle(color: colorWhite)),
      textButtonTheme:
          TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: colorWhite)),
      elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll<Color>(colorWhite),
        foregroundColor: MaterialStatePropertyAll<Color>(colorTheme),
      )));

  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: primaryBlack,
    primaryColor: colorTheme,
    backgroundColor: colorWhite,
    scaffoldBackgroundColor: colorWhite,
    appBarTheme: const AppBarTheme(
        backgroundColor: white1,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        titleTextStyle: TextStyle(
          color: colorTheme,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        )),
    textTheme: const TextTheme(titleLarge: TextStyle(color: colorTheme)),
    inputDecorationTheme: const InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: colorTheme)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: colorTheme)),
        labelStyle: TextStyle(color: colorTheme)),
  );
}
