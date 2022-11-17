import 'package:flutter/material.dart';
import 'package:work_manager_demo/res/color_resources.dart';

class CustomRadioButton extends StatelessWidget {
  String title;
  dynamic value;
  dynamic groupValue;
  bool isSelected;
  final ValueChanged<dynamic> onChanged;
  CustomRadioButton(
      {required this.title,
      this.value,
      this.groupValue,
      required this.isSelected,
      required this.onChanged});

//   @override
//   State<CustomRadioButton> createState() => _CustomRadioButtonState();
// }
//
// class _CustomRadioButtonState extends State<CustomRadioButton> {
  // bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : colorWhite,
            border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : colorTheme),
            borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(
                color:
                    isSelected ? Theme.of(context).scaffoldBackgroundColor : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          ),
          trailing: Radio(
              toggleable: true,
              activeColor: Theme.of(context).primaryColor,
              fillColor: MaterialStatePropertyAll<Color>(Colors.red),
              value: value,
              groupValue: groupValue,
              onChanged: onChanged),
        ),
      ),
    );
  }
}
