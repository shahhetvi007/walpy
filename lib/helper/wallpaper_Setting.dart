import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperSetting {
  Future<void> setWallpaper() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? screen = prefs.getInt('screen');
    print(screen);
    String imageUrl = await getImageUrl();
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    try {
      await WallpaperManager.setWallpaperFromFile(
          file.path, screen ?? WallpaperManager.HOME_SCREEN);
      // Fluttertoast.showToast(msg: 'Wallpaper changed');
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  Future<String> getImageUrl() async {
    int index = Random().nextInt(5);
    await Firebase.initializeApp();
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('wallpapers')
        .doc('Anime')
        .collection('images')
        .get();
    // QuerySnapshot snapshot1 =
    //     await FirebaseFirestore.instance.collection('wallpapers').get();
    // print('size');
    // print(snapshot1.size);
    // int random = Random().nextInt(snapshot1.docs.length);
    // print(random);
    // String documentSnapshot = snapshot1.docs.elementAt(random).get('url');
    // print(documentSnapshot);
    String imageUrl = snapshot.docs.elementAt(index).get('url');
    // print(imageUrl);
    return imageUrl;
  }
}
