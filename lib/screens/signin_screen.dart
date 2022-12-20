import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/helper/validations.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/home_screen.dart';
import 'package:work_manager_demo/screens/signup_screen.dart';
import 'package:work_manager_demo/widgets/common_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with InputValidationMixin {
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.max,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Sign In',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Theme.of(context).primaryColor,
                    fontFamily: 'Jost'),
              ),
              const SizedBox(height: 30),
              commonTextFormField(
                context: context,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (isEmailValid(value!)) {
                    return null;
                  }
                  return 'Please enter valid email';
                },
                onTextChanged: (val) {
                  setState(() {
                    email = val;
                  });
                },
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              const SizedBox(height: 30),
              commonTextFormField(
                context: context,
                keyboardType: TextInputType.text,
                obscureText: true,
                onTextChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is empty';
                  }
                  return null;
                },
                labelText: 'Password',
                hintText: 'Enter password',
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  // gradient: primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    signIn(context);
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).scaffoldBackgroundColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(fontFamily: 'Jost', fontSize: 16),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (ctx) => const SignUpScreen(Role.User)));
                    },
                    child: const Text(
                      ' Sign Up',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontFamily: 'Jost', fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                    text: 'Sign up as an ',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontFamily: 'Jost',
                        fontSize: 16),
                    children: [
                      TextSpan(
                          text: 'Admin',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Jost',
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (ctx) => const SignUpScreen(Role.Admin)));
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
    await AuthHelper().signIn(email, password).then((value) async {
      if (value == null) {
        await AuthHelper().isAdmin();
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (ctx) => const HomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
      }
    });
  }
}
