import 'dart:async';

import 'package:bleed_client/constants/colors/white.dart';
import 'package:bleed_client/constants/fontWeights/normal.dart';
import 'package:bleed_client/ui/state/flutter_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lemon_engine/state/size.dart';

Widget text(dynamic value, {
    fontSize = 18,
    Function onPressed,
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
    Widget child,
    Color color = Colors.white,
    double width = 1,
    BorderRadius radius = borderRadius4,
    EdgeInsets padding = padding8,
    EdgeInsets margin,
    Alignment alignment,
    Color fillColor}) {
  return Container(
    alignment: alignment,
    margin: margin,
    padding: padding,
    decoration: BoxDecoration(
        border: color != null ? Border.all(color: color, width: width) : null,
        borderRadius: radius,
        color: fillColor),
    child: child,
  );
}

BoxDecoration boxDecoration({
    double borderWidth = 2.0,
    Color borderColor = white,
    double borderRadius = 4,
    Color fillColor
    }) {
  return BoxDecoration(
      border: Border.all(color: borderColor, width: borderWidth),
      borderRadius: borderRadius4,
      color: fillColor);
}

Widget comingSoon({Widget child}) {
  return Tooltip(
    message: "Coming Soon",
    child: child,
  );
}

Widget onPressed({Widget child, Function callback, dynamic hint}) {
  Widget widget = MouseRegion(
      cursor: callback != null ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(child: child, onTap: callback));

  if (hint == null) return widget;

  return Tooltip(
    message: hint.toString(),
    child: widget,
  );
}

class Refresh extends StatefulWidget {
  final WidgetBuilder builder;
  final Duration duration;

  Refresh({this.builder, this.duration});

  @override
  _RefreshState createState() => _RefreshState();
}

class _RefreshState extends State<Refresh> {
  Timer timer;
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
    return widget.builder(context);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
}

Widget button(String value, Function onPressed,
    {double fontSize = 18.0,
    ButtonStyle buttonStyle,
    Alignment alignment = Alignment.centerLeft}) {
  return OutlinedButton(
    child: Container(
        width: 200,
        height: 50,
        alignment: alignment,
        child: Text(value,
            style: TextStyle(color: white, fontSize: fontSize))),
    style: buttonStyle ?? _buttonStyle,
    onPressed: onPressed,
  );
}

Widget center(Widget child) {
  return Container(
    width: globalSize.width,
    height: globalSize.height,
    alignment: Alignment.center,
    child: child,
  );
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

Widget width(double value) {
  return Container(width: value);
}

final Widget width16 = width(16);
final Widget width8 = width(8);
final Widget width4 = width(4);

ButtonStyle _buttonStyle = buildButtonStyle(white, 2);

ButtonStyle buildButtonStyle(Color borderColor, double borderWidth) {
  return OutlinedButton.styleFrom(
    side: BorderSide(color: borderColor, width: borderWidth),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
  );
}

final Widget blank = const Positioned(child: const Text(""), top: 0, left: 0,);
