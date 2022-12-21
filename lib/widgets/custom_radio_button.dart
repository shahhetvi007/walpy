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
    return Container(
      decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).scaffoldBackgroundColor
                : Theme.of(context).primaryColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Jost',
          ),
        ),
        trailing: Radio(
            toggleable: true,
            activeColor: Theme.of(context).primaryColor,
            fillColor: MaterialStatePropertyAll<Color>(isSelected
                ? Theme.of(context).scaffoldBackgroundColor
                : Theme.of(context).primaryColor),
            value: value,
            groupValue: groupValue,
            onChanged: onChanged),
      ),
    );
  }
}
