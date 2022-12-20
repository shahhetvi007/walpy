import 'dart:async';

import 'package:flutter/material.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/screens/home_screen.dart';
import 'package:work_manager_demo/screens/signin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) {
        return AuthHelper().user != null ? const HomeScreen() : const SignInScreen();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: const Text(
            'WALPY',
            style: TextStyle(
              fontSize: 50,
              fontFamily: 'Chalkduster',
            ),
          ),
        ),
      ),
    );
  }
}
