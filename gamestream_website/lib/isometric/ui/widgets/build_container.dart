
import 'package:flutter/material.dart';
import 'package:gamestream_flutter/flutterkit.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';

Widget container({
  dynamic child,
  Color? color,
  Color? hoverColor,
  Function? action,
  Alignment alignment = Alignment.centerLeft,
  num width = 200,
  num height = 50,
  String? toolTip,
  Decoration? decoration,
  EdgeInsets? margin,
  EdgeInsets? padding,
}){
  late Widget con;
  if (hoverColor != null){
    con = onMouseOver(
      builder: (context, mouseOver) {
        return Container(
          decoration: decoration,
          padding: padding ?? const EdgeInsets.only(left: 8),
          alignment: alignment,
          width: width.toDouble(),
          height: height.toDouble(),
          color: mouseOver ? hoverColor : color ?? Colors.grey,
          margin: margin,
          child: child == null
              ? null : child is Widget ? child : text(child),
        );
      }
    );
  } else {
    con = Container(
      decoration: decoration,
      padding: padding ?? const EdgeInsets.only(left: 8),
      alignment: alignment,
      width: width.toDouble(),
      height: height.toDouble(),
      color: color ?? Colors.grey,
      margin: margin,
      child: child == null
          ? null : child is Widget ? child : text(child),
    );
  }

  if (toolTip != null){
    con = Tooltip(
      message: toolTip,
      child: con,
    );
  }

  if (action == null) return con;
  return onPressed(child: con, callback: action);
}