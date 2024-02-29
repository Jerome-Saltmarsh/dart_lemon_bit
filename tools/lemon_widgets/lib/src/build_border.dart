
import 'package:flutter/material.dart';

Widget buildBorder({
  required Widget child,
  Color color = Colors.white,
  double width = 1,
  BorderRadius radius = const BorderRadius.all(Radius.circular(4)),
  Color fillColor = Colors.transparent,
  EdgeInsets? padding,
  double? fillHeight,
  double? fillWidth,
}) {
  return Container(
    padding: padding,
    alignment: Alignment.center,
    width: fillWidth,
    height: fillHeight,
    decoration: BoxDecoration(
      color: fillColor,
      border: Border.all(color: color, width: width),
      borderRadius: radius,
    ),
    child: child,
  );
}
