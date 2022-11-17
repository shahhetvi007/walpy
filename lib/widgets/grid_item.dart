import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/helper/prefs_utils.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/detail_screen.dart';
import 'package:work_manager_demo/screens/home_screen.dart';

class GridItem extends StatefulWidget {
  String imageUrl;

  GridItem(this.imageUrl, {bool isFavoriteScreen = false});

  @override
  State<GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> with WidgetsBindingObserver {
  bool isFavorite = false;
  final CollectionReference collectionReference = FirebaseFirestore.instance
      .collection('favorites')
      .doc(AuthHelper().user.uid)
      .collection('images');
  String filename = '';
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    isAdmin = PreferenceUtils.getBool('isAdmin');
    checkIfFavorite();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    checkIfFavorite();
    print('AppLifecycleState: $state');
  }

  @override
  void didUpdateWidget(covariant GridItem oldWidget) {
    checkIfFavorite();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    checkIfFavorite();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => DetailScreen(imageUrl: widget.imageUrl)));
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Hero(
                tag: widget.imageUrl,
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
        isAdmin
            ? Container()
            : Positioned(
                bottom: 10,
                right: 15,
                child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? colorRed : colorWhite,
                    ),
                    onPressed: () {
                      addFavorite(context);
                    })),
      ],
    );
  }

  addFavorite(BuildContext ctx) async {
    if (!mounted) return;
    checkIfFavorite();
    if (isFavorite) {
      Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (ctx) => HomeScreen()));
      await collectionReference.doc(filename).delete();
    } else {
      await collectionReference.doc(filename).set({'url': widget.imageUrl});
    }
  }

  checkIfFavorite() async {
    RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
    var matches = regExp.allMatches(widget.imageUrl);
    var match = matches.elementAt(0);
    setState(() {
      filename = Uri.decodeFull(match.group(2)!);
    });
    // print(filename);

    var item = await collectionReference.doc(filename).get();
    if (mounted) {
      if (item.exists) {
        setState(() {
          isFavorite = true;
        });
      } else {
        // if (mounted) {
        setState(() {
          isFavorite = false;
        });
        // }
      }
    }
  }
}
