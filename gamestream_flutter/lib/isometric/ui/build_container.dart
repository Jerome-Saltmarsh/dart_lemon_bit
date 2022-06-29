
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';

Widget container({
  required dynamic child,
  Color? color,
  Function? action,
  Alignment alignment = Alignment.centerLeft,
  double width = 200,
  double height = 50
}){
  final con = Container(
    padding: const EdgeInsets.only(left: 8),
    alignment: alignment,
    width: width,
    height: height,
    color: color ?? Colors.grey,
    child: child is Widget ? child : text(child),
  );
  if (action == null) return con;
  return onPressed(child: con, callback: action);
}