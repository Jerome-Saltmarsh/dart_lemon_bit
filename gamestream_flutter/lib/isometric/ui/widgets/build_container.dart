
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';

Widget container({
  dynamic child,
  Color? color,
  Function? action,
  Alignment alignment = Alignment.centerLeft,
  double width = 200,
  double height = 50,
  String? toolTip,
}){
  Widget con = Container(
    padding: const EdgeInsets.only(left: 8),
    alignment: alignment,
    width: width,
    height: height,
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