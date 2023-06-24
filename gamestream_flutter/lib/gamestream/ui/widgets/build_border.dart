import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_widgets.dart';

Widget buildBorder({
  required Widget child,
  Color color = Colors.white,
  double width = 1,
  BorderRadius radius = borderRadius4,
  Color fillColor = Colors.transparent,
}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: Border.all(color: color, width: width),
      borderRadius: radius,
    ),
    child: child,
  );
}
