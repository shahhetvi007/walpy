import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:work_manager_demo/helper/auth_helper.dart';
import 'package:work_manager_demo/widgets/grid_item.dart';

import '../../res/color_resources.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final CollectionReference collectionReference = FirebaseFirestore.instance
      .collection('favorites')
      .doc(AuthHelper().user.uid)
      .collection('images');

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.5;
    final double itemWidth = size.width / 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: StreamBuilder(
            stream: collectionReference.snapshots(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return snapshot.hasData
                  ? GridView.builder(
                      itemCount: snapshot.data.docs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3,
                        childAspectRatio: itemWidth / itemHeight,
                      ),
                      itemBuilder: (ctx, index) {
                        RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
                        var matches = regExp.allMatches(snapshot.data.docs[index]['url']);
                        var match = matches.elementAt(0);
                        String filename = Uri.decodeFull(match.group(2)!);
                        return GridItem(snapshot.data.docs[index]['url'], filename);
                      })
                  : const Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
