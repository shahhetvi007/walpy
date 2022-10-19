import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  TextEditingController categoryController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];
  List<String> imageUrls = [];
  final collectionRef = FirebaseFirestore.instance.collection('wallpapers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: categoryController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'Enter category',
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
              ),
            ),
            const SizedBox(height: 20),
            // (imageFileList.isEmpty)
            TextButton(
              onPressed: selectImages,
              child: const Text('Select images'),
            ),
            Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: GridView.builder(
                    itemCount: imageFileList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (ctx, i) {
                      return Image.file(
                        File(imageFileList[i].path),
                        fit: BoxFit.cover,
                      );
                    })),
            ElevatedButton(
                onPressed: uploadImages, child: Text('Upload images')),
          ],
        ),
      ),
    );
  }

  void selectImages() async {
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages!.isNotEmpty) {
      imageFileList.addAll(selectedImages);
    }
    setState(() {});
  }

  Future<String> addPhotoToStorage(XFile image) async {
    String fileName = image.path.split('/').last;
    final firebaseStorage = FirebaseStorage.instance;
    if (image.path.isNotEmpty) {
      //Upload to Firebase
      TaskSnapshot snapshot = await firebaseStorage
          .ref()
          .child('uploads/$fileName')
          .putFile(File(image.path));
      // print(await snapshot.ref.getDownloadURL());
      return await snapshot.ref.getDownloadURL();
    } else {
      print('No Image Path Received');
      return '';
    }
  }

  Future getDownloadUrls() async {
    for (var image in imageFileList) {
      String url = await addPhotoToStorage(image);
      imageUrls.add(url);
      setState(() {});
    }
    print('urls');
    print(imageUrls);
  }

  Future uploadImages() async {
    await getDownloadUrls();
    final doc =
        await collectionRef.doc(capitalize(categoryController.text)).get();
    final docRef = collectionRef.doc(capitalize(categoryController.text));
    RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');

    for (String downloadUrl in imageUrls) {
      //This Regex won't work if you remove ?alt...token
      var matches = regExp.allMatches(downloadUrl);
      var match = matches.elementAt(0);
      String filename = Uri.decodeFull(match.group(2)!);
      if (doc.exists) {
        docRef
            .collection('images')
            .doc(filename)
            .update({'url': downloadUrl}).then((_) {
          print('Image uploaded');
        });
      } else {
        Map<String, Object> dummyMap = HashMap<String, Object>();
        await docRef.set(dummyMap);
        docRef
            .collection('images')
            .doc(filename)
            .set({'url': downloadUrl}).then((_) {
          print('Image uploaded');
        });
      }
    }
    setState(() {
      imageUrls = [];
      imageFileList = [];
      categoryController.text = '';
    });
  }

  String capitalize(String s) => (s != null && s.length > 1)
      ? s[0].toUpperCase() + s.substring(1)
      : s.toUpperCase();
}
