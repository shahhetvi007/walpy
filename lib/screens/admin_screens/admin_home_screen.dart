import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:work_manager_demo/helper/firebase_helper.dart';
import 'package:work_manager_demo/res/color_resources.dart';

class AdminHomeScreen extends StatefulWidget {
  String? category;

  AdminHomeScreen({this.category});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  TextEditingController categoryController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  List<XFile> imageFileList = [];
  bool isLoading = false;
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    categoryController.text = widget.category ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TextField(
                  controller: categoryController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontFamily: 'Jost'),
                  onChanged: (val) {
                    print(val);
                    if ((val.isNotEmpty || val != '') && imageFileList.isNotEmpty) {
                      isButtonEnabled = true;
                    } else {
                      isButtonEnabled = false;
                    }
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                    hintText: 'Enter category',
                    labelStyle: const TextStyle(fontFamily: 'Jost'),
                    hintStyle: const TextStyle(fontFamily: 'Jost'),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // (imageFileList.isEmpty)
            isLoading
                ? const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Flexible(
                    flex: 3,
                    fit: FlexFit.loose,
                    child: GridView.builder(
                        itemCount: imageFileList.length + 1,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemBuilder: (ctx, i) {
                          return i == imageFileList.length
                              ? GestureDetector(
                                  onTap: selectImages, child: addImageContainer())
                              : Container(
                                  child: Image.file(
                                    File(imageFileList[i].path),
                                    fit: BoxFit.cover,
                                  ),
                                );
                        }),
                  ),
            GestureDetector(
              onTap: isButtonEnabled
                  ? () async {
                      setState(() {
                        isLoading = true;
                      });
                      await FirebaseHelper()
                          .uploadImages(imageFileList, categoryController.text)
                          .then((value) {
                        setState(() {
                          isLoading = false;
                          categoryController.text = '';
                          imageFileList = [];
                        });
                      });
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isButtonEnabled ? Theme.of(context).primaryColor : grey,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Text(
                  'Upload images',
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void selectImages() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList.addAll(selectedImages);
    }
    if ((categoryController.text.isNotEmpty || categoryController.text != '') &&
        imageFileList.isNotEmpty) {
      isButtonEnabled = true;
    } else {
      isButtonEnabled = false;
    }
    setState(() {});
  }

  Widget addImageContainer() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      margin: const EdgeInsets.all(2),
      child: OutlinedButton(
        onPressed: () {
          selectImages();
        },
        style: ButtonStyle(
            side: MaterialStateProperty.all(BorderSide(
          color: Theme.of(context).primaryColor,
        ))),
        child: Icon(
          Icons.add,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
