import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';

Widget button({required Function action, required Widget child, Color? color}){
  return onPressed(
      callback: action,
      child: Container(
          padding: EdgeInsets.only(left: 8),
          alignment: Alignment.centerLeft,
          width: 200,
          height: 50,
          color: color ?? Colors.grey,
          child: child)
  );
}