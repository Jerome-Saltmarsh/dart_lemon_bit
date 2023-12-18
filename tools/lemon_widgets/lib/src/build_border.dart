
import 'package:flutter/material.dart';

Widget buildBorder({
  required Widget child,
  Color color = Colors.white,
  double width = 1,
  BorderRadius radius = const BorderRadius.all(Radius.circular(4)),
  Color fillColor = Colors.transparent,
  EdgeInsets? padding,
}) {
  return Container(
    padding: padding,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(color: color, width: width),
      borderRadius: radius,
    ),
    child: child,
  );
}
