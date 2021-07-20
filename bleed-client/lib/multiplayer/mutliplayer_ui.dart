import 'package:flutter/material.dart';

Widget text(String value) {
  return Text(value, style: TextStyle(color: Colors.white));
}

Widget button(String value, Function onPressed) {
  return OutlinedButton(
    child: Text(value, style: TextStyle(color: Colors.white)),
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.white, width: 2),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
    ),
    onPressed: onPressed,
  );
}

Widget column(List<Widget> children) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: children);
}
