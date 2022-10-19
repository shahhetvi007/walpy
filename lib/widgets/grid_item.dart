import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:work_manager_demo/res/color_resources.dart';
import 'package:work_manager_demo/screens/detail_screen.dart';

class GridItem extends StatefulWidget {
  String imageUrl;

  GridItem(this.imageUrl);

  @override
  State<GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<GridItem> {
  bool isFavorite = false;
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('favorites');

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
        Positioned(
            bottom: 10,
            right: 15,
            child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? colorRed : colorWhite,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                })),
      ],
    );
  }

  addFavorite() {}
}
