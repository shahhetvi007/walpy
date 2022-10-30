import 'package:flutter/material.dart';
import 'package:work_manager_demo/res/color_resources.dart';

class AddImage extends StatelessWidget {
  const AddImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorTheme),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
