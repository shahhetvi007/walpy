import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';

class WallpaperSetting {
  Future<void> setWallpaper() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? screen = prefs.getInt('screen');
    print(screen);
    String? source = prefs.getString('source');
    String imageUrl;
    if (source!.toLowerCase() == 'favorites') {
      imageUrl = await getFavoriteImageUrl();
    } else {
      imageUrl = await getRandomImageUrl();
    }
    var file = await DefaultCacheManager().getSingleFile(imageUrl);
    try {
      await WallpaperManager.setWallpaperFromFile(
          file.path, screen ?? WallpaperManager.HOME_SCREEN);
      // Fluttertoast.showToast(msg: 'Wallpaper changed');
    } on PlatformException catch (e) {
      print(e.toString());
    }
  }

  Future<String> getRandomImageUrl() async {
    await Firebase.initializeApp();

    final CollectionReference _collectionReference =
        FirebaseFirestore.instance.collection('wallpapers');
    QuerySnapshot snapshot1 = await _collectionReference.get();

    final data = snapshot1.docs.map((e) => e.id).toList();
    final random = Random().nextInt(data.length);
    print(data[random]);

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('wallpapers')
        .doc(data[random])
        .collection('images')
        .get();

    int index = Random().nextInt(5);

    String imageUrl = snapshot.docs.elementAt(index).get('url');
    return imageUrl;
  }

  Future<String> getFavoriteImageUrl() async {
    final CollectionReference _collectionReference =
        FirebaseFirestore.instance.collection('favorites');

    QuerySnapshot snapshot = await _collectionReference
        .doc(AuthHelper().user.uid)
        .collection('images')
        .get();

    int index = Random().nextInt(snapshot.size);

    String imageUrl = snapshot.docs.elementAt(index).get('url');
    return imageUrl;
  }
}
