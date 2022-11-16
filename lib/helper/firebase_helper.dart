import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseHelper {
  final collectionRef = FirebaseFirestore.instance.collection('wallpapers');

  Future<String> addPhotoToStorage(XFile image) async {
    String fileName = image.path.split('/').last;
    final firebaseStorage = FirebaseStorage.instance;
    if (image.path.isNotEmpty) {
      //Upload to Firebase
      TaskSnapshot snapshot = await firebaseStorage
          .ref()
          .child('uploads/$fileName')
          .putFile(File(image.path));
      return await snapshot.ref.getDownloadURL();
    } else {
      print('No Image Path Received');
      return '';
    }
  }

  Future getDownloadUrls(List<XFile> imageFileList) async {
    List<String> imageUrls = [];
    for (var image in imageFileList) {
      String url = await FirebaseHelper().addPhotoToStorage(image);
      imageUrls.add(url);
    }
    print(imageUrls);
    return imageUrls;
  }

  Future uploadImages(List<XFile> imageFileList, String category) async {
    List<String> imageUrls = await getDownloadUrls(imageFileList);
    final doc = await collectionRef.doc(capitalize(category)).get();
    final docRef = collectionRef.doc(capitalize(category));
    RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');

    for (String downloadUrl in imageUrls) {
      //This Regex won't work if you remove ?alt...token
      var matches = regExp.allMatches(downloadUrl);
      var match = matches.elementAt(0);
      String filename = Uri.decodeFull(match.group(2)!);
      print('exists');
      print(doc.exists);
      if (doc.exists) {
        docRef.collection('images').doc(filename).set({'url': downloadUrl}).then((_) {
          print('Image uploaded');
        });
      } else {
        Map<String, Object> dummyMap = HashMap<String, Object>();
        await docRef.set(dummyMap);
        docRef.collection('images').doc(filename).set({'url': downloadUrl}).then((_) {
          print('Image uploaded');
        });
      }
    }
  }

  String capitalize(String s) =>
      (s != null && s.length > 1) ? s[0].toUpperCase() + s.substring(1) : s.toUpperCase();
}
