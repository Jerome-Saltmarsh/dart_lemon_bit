

import 'package:flutter/material.dart';

Widget buildText(dynamic value, {
  num size = 18,
  TextDecoration decoration = TextDecoration.none,
  FontWeight weight = FontWeight.normal,
  bool italic = false,
  bool bold = false,
  bool underline = false,
  Color color = Colors.white,
  String? family,
  TextAlign? align,
  double height = 1.0,
}) => Text(
    value.toString(),
    textAlign: align,
    style: TextStyle(
        color: color,
        fontSize: size.toDouble(),
        decoration: underline ? TextDecoration.underline : decoration,
        fontWeight: bold ? FontWeight.bold : weight,
        fontFamily: family,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        height: height
    )
);
