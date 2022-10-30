import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/helper/wallpaper_Setting.dart';
import 'package:work_manager_demo/models/common/globals.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/home_screen.dart';
import 'package:work_manager_demo/screens/signin_screen.dart';
import 'package:workmanager/workmanager.dart';

const myTask = "syncWithTheBackEnd";
const periodicTask = "periodicTask";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  await Firebase.initializeApp();
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

  @override
  Widget build(BuildContext context) {
    Globals.globalContext = context;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: primaryBlack,
          primaryColor: colorTheme,
          backgroundColor: colorWhite,
          appBarTheme: const AppBarTheme(
              backgroundColor: white1,
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0,
              titleTextStyle: TextStyle(
                color: colorTheme,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ))),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // primarySwatch: primaryWhite,
        primaryColor: colorWhite,
        backgroundColor: colorTheme,
        appBarTheme: const AppBarTheme(
            // backgroundColor: colorTheme,
            iconTheme: IconThemeData(color: colorWhite),
            elevation: 0,
            titleTextStyle: TextStyle(
              color: colorWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: colorWhite,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(colorWhite),
          textStyle:
              MaterialStateProperty.all(const TextStyle(color: colorWhite)),
        )),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              textStyle: MaterialStateProperty.all(
                  const TextStyle(color: colorTheme))),
        ),
      ),
      themeMode: _theme,
      home: AuthHelper().user != null ? HomeScreen() : const SignInScreen(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//           child: ElevatedButton(
//         child: Text('Periodic task'),
//         onPressed: () {
//           Workmanager().cancelAll();
//           Workmanager().registerPeriodicTask("2", periodicTask,
//               frequency: Duration(minutes: 15));
//         },
//       )),
//     );
//   }
// }
