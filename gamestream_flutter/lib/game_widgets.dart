import 'package:flutter/material.dart';
import 'package:lemon_watch/src.dart';

import 'instances/engine.dart';

Widget watch<T>(Watch<T> watch, Widget Function(T t) builder) => WatchBuilder(watch, builder);




const borderRadius4 = BorderRadius.all(Radius.circular(4));

ButtonStyle buildButtonStyle(Color borderColor, double borderWidth) {
  return OutlinedButton.styleFrom(
    side: BorderSide(color: borderColor, width: borderWidth),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
  );
}

Widget dialog({
  required Widget child,
  double padding = 8,
  double width = 400,
  double height = 600,
  Color color = Colors.white24,
  Color borderColor = Colors.white,
  double borderWidth = 2,
  BorderRadius borderRadius = borderRadius4,
  Alignment alignment = Alignment.center,
  EdgeInsets margin = EdgeInsets.zero,
}) {
  return Container(
    width: engine.screen.width,
    height: engine.screen.height,
    alignment: alignment,
    child: Container(
      margin: margin,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: borderRadius,
          color: color),
      padding: EdgeInsets.all(padding),
      width: width,
      height: height,
      child: child,
    ),
  );
}
