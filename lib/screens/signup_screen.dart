import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/main.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/home_screen.dart';
import 'package:work_manager_demo/screens/signin_screen.dart';
import 'package:work_manager_demo/models/user_model.dart';
import 'package:work_manager_demo/widgets/custom_radio_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController passwordController = TextEditingController();

  String email = '';
  String password = '';
  String username = '';
  String imageUrl = '';
  File? imagePicked;

  var roleSelectedValue = Role.User;
  bool _isUserSelected = true;
  bool _isAdminSelected = false;

  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: colorTheme,
            fontWeight: FontWeight.bold,
          ),
        ),
        // centerTitle: true,
        backgroundColor: appBarColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(alignment: Alignment.center, child: addProfile()),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Add Profile Photo',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    // print(val);
                    setState(() {
                      username = val;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: colorTheme)),
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
                  controller: passwordController,
                  keyboardType: TextInputType.text,
                  obscureText: true,
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
                TextFormField(
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Password do not match';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    // print(val);
                    if (val == passwordController.text) {
                      setState(() {
                        password = val;
                      });
                    }
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm password',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: colorTheme)),
                  ),
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
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: () {
                    signUp(context);
                  },
                  child: const Text('Sign Up'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => const SignInScreen()));
                      },
                      child: const Text(
                        ' Sign In',
                        style: TextStyle(
                          color: colorTheme,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget addProfile() {
    return GestureDetector(
      onTap: _chooseImageSourceType,
      child: Stack(children: [
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(shape: BoxShape.circle, color: black1),
        ),
        (imagePicked != null)
            ? Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: black1,
                    image: DecorationImage(
                      image: FileImage(
                        imagePicked!,
                      ),
                      fit: BoxFit.fill,
                    )),
              )
            : const Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Icon(
                  Icons.person_add_alt_1_outlined,
                  color: colorTheme,
                  size: 40,
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
      await _firestore
          .collection('users')
          .doc(AuthHelper().user.uid)
          .set(user.toMap());
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  Future uploadImage(File image) async {
    String fileName = image.path.split('/').last;
    final firebaseStorage = FirebaseStorage.instance;
    if (image != null) {
      //Upload to Firebase
      var snapshot = await firebaseStorage
          .ref()
          .child('user_profiles/$fileName')
          .putFile(image);
      // .whenComplete(() {});
      // .onComplete();
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
    await AuthHelper().signUp(email, password);
    await uploadImage(imagePicked!);
    await addUserToDb();
    if (AuthHelper().user != null) {
      Navigator.pushReplacement(
          this.context, MaterialPageRoute(builder: (ctx) => HomeScreen()));
    }
  }
}

enum Role { User, Admin }
