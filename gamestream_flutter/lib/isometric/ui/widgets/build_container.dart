
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';

Widget container({
  dynamic child,
  Color? color,
  Function? action,
  Alignment alignment = Alignment.centerLeft,
  num width = 200,
  num height = 50,
  String? toolTip,
  Decoration? decoration,
}){
  Widget con = Container(
    decoration: decoration,
    padding: const EdgeInsets.only(left: 8),
    alignment: alignment,
    width: width.toDouble(),
    height: height.toDouble(),
    color: color ?? Colors.grey,
    child: child == null
        ? null : child is Widget ? child : text(child),
  );

  if (toolTip != null){
    con = Tooltip(
      message: toolTip,
      child: con,
    );
  }

  if (action == null) return con;
  return onPressed(child: con, callback: action);
}