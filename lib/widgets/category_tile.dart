import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String category;

  CategoryTile({super.key, required this.category});

  final CollectionReference _collectionReference =
      FirebaseFirestore.instance.collection('wallpapers');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: StreamBuilder(
          stream: _collectionReference.doc(category).collection('images').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return snapshot.hasData
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          snapshot.data.docs[0]['url'],
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
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Jost'),
                        ),
                      )
                    ],
                  )
                : const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
