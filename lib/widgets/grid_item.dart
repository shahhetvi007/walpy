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
  String filename;

  GridItem(this.imageUrl, this.filename, {bool isFavoriteScreen = false});

  @override
  State<GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isFavorite = false;
  final CollectionReference collectionReference = FirebaseFirestore.instance
      .collection('favorites')
      .doc(AuthHelper().user.uid)
      .collection('images');
  // String filename = '';
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    isAdmin = PreferenceUtils.getBool('isAdmin');
    // checkIfFavorite();
  }

  // @override
  // void didUpdateWidget(covariant GridItem oldWidget) {
  //   checkIfFavorite();
  //   super.didUpdateWidget(oldWidget);
  // }
  //
  // @override
  // void didChangeDependencies() {
  //   checkIfFavorite();
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: collectionReference.doc(widget.filename).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            const Center(
              child: CircularProgressIndicator(),
            );
          }
          return snapshot.hasData
              ? Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) =>
                                    DetailScreen(imageUrl: widget.imageUrl)));
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
                              placeholder: (ctx, value) {
                                return const Center(
                                  child: Text(
                                    'WALPY',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontFamily: 'Chalkduster',
                                    ),
                                  ),
                                );
                              },
                              // progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                              //     child: CircularProgressIndicator(value: downloadProgress.progress)),
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
                                  snapshot.data!.exists
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: snapshot.data!.exists ? colorRed : colorWhite,
                                ),
                                onPressed: () {
                                  print(widget.filename);
                                  print(snapshot.data!.exists);
                                  if (snapshot.data!.exists) {
                                    collectionReference.doc(widget.filename).delete();
                                  } else {
                                    collectionReference
                                        .doc(widget.filename)
                                        .set({'url': widget.imageUrl});
                                  }
                                  // print(snapshot.data!.docs.first.id);
                                  // if(snapshot.data!.docs
                                  //     .where((element) => element.id == filename)
                                  //     .isEmpty){
                                  //   collectionReference.doc(filename).set({'url' : widget.imageUrl});
                                  // }
                                  // // if (snapshot.data!.docs.contains(filename)) {
                                  // print(snapshot.data!.size);
                                  // }
                                })),
                  ],
                )
              : const Center(child: CircularProgressIndicator());
        });
  }

  // addFavorite(BuildContext ctx) async {
  //   if (!mounted) return;
  //   checkIfFavorite();
  //   if (isFavorite) {
  //     Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (ctx) => HomeScreen()));
  //     await collectionReference.doc(filename).delete();
  //   } else {
  //     await collectionReference.doc(filename).set({'url': widget.imageUrl});
  //   }
  // }
  //
  // checkIfFavorite() async {
  //   RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
  //   var matches = regExp.allMatches(widget.imageUrl);
  //   var match = matches.elementAt(0);
  //   setState(() {
  //     filename = Uri.decodeFull(match.group(2)!);
  //   });
  //   // print(filename);
  //
  //   var item = await collectionReference.doc(filename).get();
  //   if (mounted) {
  //     if (item.exists) {
  //       setState(() {
  //         isFavorite = true;
  //       });
  //     } else {
  //       // if (mounted) {
  //       setState(() {
  //         isFavorite = false;
  //       });
  //       // }
  //     }
  //   }
  // }
}
