import 'dart:async';

import 'package:bleed_client/constants/colors/white.dart';
import 'package:bleed_client/constants/fontWeights/normal.dart';
import 'package:bleed_client/styles.dart';
import 'package:bleed_client/utils/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lemon_engine/state/screen.dart';

Widget text(dynamic value, {
    fontSize = 18,
    GestureTapCallback? onPressed,
    TextDecoration decoration = TextDecoration.none,
    FontWeight fontWeight = normal,
    Color color = white
}) {
  Widget _text = Text(value.toString(),
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          decoration: decoration,
          fontWeight: fontWeight));

  if (onPressed == null) return _text;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      child: _text,
      onTap: onPressed,
    ),
  );
}

Widget border({
  required dynamic child,
  Color color = Colors.white,
  double borderWidth = 1,
  BorderRadius radius = borderRadius4,
  EdgeInsets padding = padding8,
  EdgeInsets? margin,
  Alignment alignment = Alignment.center,
  Color fillColor = Colors.transparent,
  double? width,
  double? height,
}) {
  return Container(
    alignment: alignment,
    margin: margin,
    padding: padding,
    width: width,
    height: height,
    decoration: BoxDecoration(
        border: Border.all(color: color, width: borderWidth),
        borderRadius: radius,
        color: fillColor),
    child: child is Widget ? child : text(child),
  );
}

BoxDecoration boxDecoration({
  double borderWidth = 2.0,
  Color borderColor = white,
  double borderRadius = 4,
  Color fillColor = Colors.white,
}) {
  return BoxDecoration(
      border: Border.all(color: borderColor, width: borderWidth),
      borderRadius: borderRadius4,
      color: fillColor);
}

Widget button(dynamic value, GestureTapCallback onPressed, {
  double? width,
  double? height,
  String? hint,
  double borderWidth = 1,
  EdgeInsets? margin,
  BorderRadius borderRadius = borderRadius4,
  Color fillColorMouseOver = Colors.black26,
  Color fillColor = Colors.transparent,
  Color borderColor = Colors.white,
  Alignment alignment = Alignment.center
}) {
  final Widget _button = pressed(
      callback: onPressed,
      child: mouseOver(builder: (BuildContext context, bool mouseOver) {
        return border(
            margin: margin,
            radius: borderRadius,
            borderWidth: borderWidth,
            child: value,
            color: borderColor,
            fillColor: mouseOver ? fillColorMouseOver : fillColor,
            width: width,
            height: height,
            alignment: alignment);
      }));

  if (hint != null) {
    return Tooltip(message: hint, child: _button);
  }
  return _button;
}

Widget pressed(
    {required Widget child,
    required GestureTapCallback? callback,
    dynamic hint}) {
  return onPressed(child: child, callback: callback, hint: hint);
}

Widget onPressed(
    {required Widget child,
    required GestureTapCallback? callback,
    dynamic hint}) {
  Widget widget = MouseRegion(
      cursor: callback != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: GestureDetector(child: child, onTap: callback));

  if (hint == null) return widget;

  return Tooltip(
    message: hint.toString(),
    child: widget,
  );
}


typedef RefreshBuilder = Widget Function();

class Refresh extends StatefulWidget {
  final RefreshBuilder builder;
  late final Duration duration;

  Refresh(this.builder, {int seconds = 0, int milliseconds = 100}) {
    this.duration = Duration(seconds: seconds, milliseconds: milliseconds);
  }

  @override
  _RefreshState createState() => _RefreshState();
}

class _RefreshState extends State<Refresh> {
  late Timer timer;
  bool assigned = false;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(widget.duration, (timer) {
      rebuild();
    });
  }

  void rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
}

Widget center(Widget child) {
  return fullScreen(child: child);
}

Widget fullScreen({
  required Widget child,
  Alignment alignment = Alignment.center
}) {
  return Container(
      alignment: alignment,
      width: screen.width,
      height: screen.height,
      child: child);
}

Widget page({required List<Widget> children}) {
  return fullScreen(
      child: Stack(
    children: children,
  ));
}

Widget height(double value) {
  return Container(height: value);
}

final Widget height2 = height(2);
final Widget height4 = height(4);
final Widget height8 = height(8);
final Widget height16 = height(16);
final Widget height20 = height(20);
final Widget height32 = height(32);
final Widget height50 = height(50);
final Widget height64 = height(64);

Widget width(double value) {
  return Container(width: value);
}

final Widget width16 = width(16);
final Widget width8 = width(8);
final Widget width4 = width(4);

ButtonStyle buildButtonStyle(Color borderColor, double borderWidth) {
  return OutlinedButton.styleFrom(
    side: BorderSide(color: borderColor, width: borderWidth),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
  );
}

final Widget blank = const Positioned(
  child: const Text(""),
  top: 0,
  left: 0,
);


Widget topLeft({required Widget child, double padding = 0}) {
  return Positioned(
    top: padding,
    left: padding,
    child: child,
  );
}

Widget topRight({required Widget child, double padding = 0}) {
  return Positioned(
    top: padding,
    right: padding,
    child: child,
  );
}

Widget bottomRight({required Widget child, double padding = 0}) {
  return Positioned(
    bottom: padding,
    right: padding,
    child: child,
  );
}

Widget bottomLeft({required Widget child, double padding = 0}) {
  return Positioned(
    bottom: padding,
    left: padding,
    child: child,
  );
}