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
            TextField(
              controller: categoryController,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Category',
                hintText: 'Enter category',
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
                              : Image.file(
                                  File(imageFileList[i].path),
                                  fit: BoxFit.cover,
                                );
                        }),
                  ),
            ElevatedButton(
                onPressed: () async {
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
                },
                child: const Text('Upload images')),
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
    setState(() {});
  }

  Widget addImageContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.add),
    );
  }
}
