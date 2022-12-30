import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/helper/validations.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/home_screen.dart';
import 'package:work_manager_demo/screens/signin_screen.dart';
import 'package:work_manager_demo/models/user_model.dart';
import 'package:work_manager_demo/widgets/common_widgets.dart';
import 'package:work_manager_demo/widgets/custom_radio_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen(this.role, {Key? key}) : super(key: key);

  final Role role;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with InputValidationMixin {
  TextEditingController passwordController = TextEditingController();

  String email = '';
  String password = '';
  String username = '';
  String imageUrl = '';
  bool isLoading = false;
  File? imagePicked;

  var roleSelectedValue = Role.User;
  bool _isUserSelected = true;
  bool _isAdminSelected = false;
  final formGlobalKey = GlobalKey<FormState>();

  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    roleSelectedValue = widget.role;
    _isUserSelected = roleSelectedValue == Role.User ? true : false;
    _isAdminSelected = roleSelectedValue == Role.Admin ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Form(
                  key: formGlobalKey,
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'New User? Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Theme.of(context).primaryColor,
                              fontFamily: 'Jost',
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Align(alignment: Alignment.center, child: addProfile()),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Add Profile Photo',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontFamily: 'Jost',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        commonTextFormField(
                          context: context,
                          hintText: 'Name',
                          labelText: 'Name',
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter username';
                            }
                            return null;
                          },
                          onTextChanged: (val) {
                            setState(() {
                              username = val;
                            });
                          },
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
                          controller: passwordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          validator: (value) {
                            if (isPasswordValid(value!)) {
                              return null;
                            }
                            return 'Please enter valid password';
                          },
                          labelText: 'Password',
                          hintText: 'Enter password',
                        ),
                        const SizedBox(height: 30),
                        commonTextFormField(
                          context: context,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value != passwordController.text) {
                              return 'Password do not match';
                            }
                            return null;
                          },
                          onTextChanged: (val) {
                            if (val == passwordController.text) {
                              setState(() {
                                password = val;
                              });
                            }
                          },
                          obscureText: true,
                          labelText: 'Confirm Password',
                          hintText: 'Confirm password',
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                                child: CustomRadioButton(
                              title: Role.User.name,
                              value: Role.User,
                              groupValue: roleSelectedValue,
                              isSelected: _isUserSelected,
                              onChanged: (dynamic val) {
                                setState(() {
                                  roleSelectedValue = val;
                                  _isUserSelected = true;
                                  _isAdminSelected = false;
                                });
                              },
                            )),
                            const SizedBox(width: 10),
                            Flexible(
                                child: CustomRadioButton(
                              title: Role.Admin.name,
                              value: Role.Admin,
                              groupValue: roleSelectedValue,
                              isSelected: _isAdminSelected,
                              onChanged: (dynamic val) {
                                setState(() {
                                  roleSelectedValue = val;
                                  _isUserSelected = false;
                                  _isAdminSelected = true;
                                });
                              },
                            )),
                          ],
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            if (formGlobalKey.currentState!.validate()) {
                              signUp(context);
                            }
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(fontFamily: 'Jost'),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) => const SignInScreen()));
                              },
                              child: Text(
                                ' Sign In',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Jost',
                                  fontSize: 14,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget addProfile() {
    return GestureDetector(
      onTap: _chooseImageSourceType,
      child: Stack(children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border.all(color: Theme.of(context).primaryColor),
          ),
        ),
        (imagePicked != null)
            ? Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: FileImage(
                        imagePicked!,
                      ),
                      fit: BoxFit.fill,
                    )),
              )
            : Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Icon(
                  Icons.person_add_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
              )
      ]),
    );
  }

  void _chooseImageSourceType() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext ctx) {
          return Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: imgFromCamera,
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: imgFromGallery,
              )
            ],
          );
        });
  }

  Future imgFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        imagePicked = File(pickedFile.path);
      });
      Navigator.pop(context);
      print(imagePicked);
    } else {
      print('No image path received');
      Navigator.pop(context);
    }
  }

  Future imgFromGallery() async {
    PermissionStatus? result;
    if (Platform.isIOS) {
      result = await Permission.photos.request();
      print(result);
    }
    // if (result.isGranted) {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePicked = File(pickedFile.path);
      });
      Navigator.pop(context);
      print(imagePicked);
    } else {
      print('No image path received');
      Navigator.pop(context);
    }
  }

  Future addUserToDb() async {
    User user = User(
      id: AuthHelper().user.uid,
      email: email,
      username: username,
      photoUrl: imageUrl,
      isAdmin: _isAdminSelected,
    );
    try {
      await _firestore.collection('users').doc(AuthHelper().user.uid).set(user.toMap());
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  Future uploadImage(File image) async {
    String fileName = image.path.split('/').last;
    final firebaseStorage = FirebaseStorage.instance;
    if (image != null) {
      //Upload to Firebase
      var snapshot =
          await firebaseStorage.ref().child('user_profiles/$fileName').putFile(image);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      if (!mounted) return;
      setState(() {
        imageUrl = downloadUrl;
      });
    } else {
      print('No Image Path Received');
    }
  }

  Future signUp(BuildContext context) async {
    setState(() {
      isLoading = true;
      passwordController.text = '';
    });
    await AuthHelper().signUp(email, password).then((value) async {
      if (value == null) {
        if (imagePicked != null) {
          print('imagePicked');
          await uploadImage(imagePicked!);
        }
        if (AuthHelper().user != null) {
          print('AuthHelper');
          await addUserToDb();
          await AuthHelper().isAdmin();
          Navigator.pushReplacement(
              this.context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
      }
    }, onError: (err) {
      print(err.toString());
    });
    setState(() {
      isLoading = false;
    });
  }
}

enum Role { User, Admin }
