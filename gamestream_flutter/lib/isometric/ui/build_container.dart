
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';

Widget container({required Widget child, Color? color, Function? onClicked}){
  final con = Container(
    padding: const EdgeInsets.only(left: 8),
    alignment: Alignment.centerLeft,
    width: 200,
    height: 50,
    color: color ?? Colors.grey,
    child: child,
  );
  if (onClicked == null) return con;
  return onPressed(child: con, callback: onClicked);
}