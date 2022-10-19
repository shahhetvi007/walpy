import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String imageUrl, category;

  const CategoryTile(
      {super.key, required this.imageUrl, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              height: 50,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            height: 50,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Container(
            height: 50,
            width: 100,
            alignment: Alignment.center,
            child: Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }
}
