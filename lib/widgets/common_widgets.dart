import 'package:flutter/material.dart';

Widget commonTextFormField({
  required BuildContext context,
  String hintText = "",
  String labelText = "",
  bool obscureText = false,
  bool readOnly = false,
  TextInputType keyboardType = TextInputType.text,
  TextInputAction textInputAction = TextInputAction.next,
  TextCapitalization textCapitalization = TextCapitalization.sentences,
  int maxLines = 1,
  TextEditingController? controller,
  String? Function(String?)? validator,
  void Function(String)? onTextChanged,
}) {
  return TextFormField(
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    textCapitalization: textCapitalization,
    controller: controller,
    validator: validator,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    onChanged: onTextChanged,
    obscureText: obscureText,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Jost'),
      labelText: labelText,
      labelStyle: TextStyle(color: Theme.of(context).primaryColor, fontFamily: 'Jost'),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.2)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.2)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.2)),
    ),
  );
}
