import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/main.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/home_screen.dart';
import 'package:work_manager_demo/screens/signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Sign In',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: colorTheme,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                onChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorTheme)),
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                keyboardType: TextInputType.text,
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorTheme)),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                onPressed: () {
                  signIn(context);
                },
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account?'),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const SignUpScreen()));
                    },
                    child: const Text(
                      ' Sign Up',
                      style: TextStyle(
                        // color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                    text: 'Sign up as an ',
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                          text: 'Admin',
                          style: const TextStyle(
                            color: colorTheme,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => const SignUpScreen()));
                            })
                    ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future signIn(BuildContext context) async {
    await AuthHelper().signIn(email, password).then((value) {
      if (value == null) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (ctx) => HomeScreen()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(value)));
      }
    });
  }
}
