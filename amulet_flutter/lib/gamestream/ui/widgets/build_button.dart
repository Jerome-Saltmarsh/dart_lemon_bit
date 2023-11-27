
import 'package:flutter/material.dart';
import 'package:amulet_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

Widget buildButton({
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
  Key? key,
}){
  late Widget con;
  if (hoverColor != null){
    con = MouseOver(
      builder: (mouseOver) {
        return Container(
          key: key,
          decoration: decoration,
          padding: padding ?? const EdgeInsets.only(left: 8),
          alignment: alignment,
          width: width.toDouble(),
          height: height.toDouble(),
          color: mouseOver ? hoverColor : color ?? Colors.grey,
          margin: margin,
          child: child == null
              ? null : child is Widget ? child : buildText(child),
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
          ? null : child is Widget ? child : buildText(child),
    );
  }

  if (toolTip != null){
    con = Tooltip(
      message: toolTip,
      child: con,
    );
  }

  if (action == null) return con;
  return onPressed(child: con, action: action);
}