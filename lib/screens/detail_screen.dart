import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailScreen extends StatefulWidget {
  final String imageUrl;

  DetailScreen({required this.imageUrl});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Hero(
            tag: widget.imageUrl,
            child: Container(
              width: screenWidth,
              height: screenHeight,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              onTap: setWallpaper,
              child: Container(
                width: screenWidth / 2,
                height: 50,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 25),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Text(
                  'Set Wallpaper',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> setWallpaper() async {
    var file = await DefaultCacheManager().getSingleFile(widget.imageUrl);
    await showOptions();
    print(selected);
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await WallpaperManager.setWallpaperFromFile(file.path, selected!);
      Fluttertoast.showToast(msg: 'Wallpaper changed');
    } on PlatformException {
      false;
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  Future<void> showOptions() async {
    selected = await showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                child: const Text('Set as home screen'),
                onPressed: () {
                  Navigator.pop(context, WallpaperManager.HOME_SCREEN);
                },
              ),
              SimpleDialogOption(
                child: const Text('Set as lock screen'),
                onPressed: () {
                  Navigator.pop(context, WallpaperManager.LOCK_SCREEN);
                },
              ),
              SimpleDialogOption(
                child: const Text('Set as both'),
                onPressed: () {
                  Navigator.pop(context, WallpaperManager.BOTH_SCREEN);
                },
              ),
            ],
          );
        });
    setState(() {});
  }
}
