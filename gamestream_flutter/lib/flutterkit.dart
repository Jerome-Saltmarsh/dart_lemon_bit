import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/constants/colors/white.dart';
import 'package:gamestream_flutter/constants/fontWeights/normal.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

const empty = SizedBox();


class _FlutterKitConfiguration {
  Color defaultTextColor = Colors.white;
  double defaultTextFontSize = 18;
}

final _FlutterKitConfiguration flutterKitConfiguration = _FlutterKitConfiguration();

Widget text(dynamic value, {
    num? size,
    Function? onPressed,
    TextDecoration decoration = TextDecoration.none,
    FontWeight weight = normal,
    bool italic = false,
    bool bold = false,
    bool underline = false,
    Color? color,
    String? family,
}) {
  final Widget _text = Text(
      value.toString(),
      style: TextStyle(
          color: color ?? flutterKitConfiguration.defaultTextColor,
          fontSize: size?.toDouble() ?? flutterKitConfiguration.defaultTextFontSize,
          decoration: underline ? TextDecoration.underline : decoration,
          fontWeight: bold ? FontWeight.bold : weight,
          fontFamily: family,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal
      )
  );

  if (onPressed == null) return _text;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      child: _text,
      onTap: (){
        onPressed();
      },
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

Widget button(dynamic value, Function onPressed, {
  double? width,
  double? height,
  String? hint,
  double borderWidth = 1,
  EdgeInsets? margin,
  BorderRadius borderRadius = borderRadius4,
  Color fillColorMouseOver = Colors.black26,
  Color fillColor = Colors.transparent,
  Color borderColor = Colors.white,
  Color borderColorMouseOver = Colors.white,
  int? fontSize = 18,
  bool boldOnHover = false,
  Alignment alignment = Alignment.center
}) {
  final Widget _button = pressed(
      callback: onPressed,
      child: mouseOver(builder: (BuildContext context, bool mouseOver) {
        return border(
            margin: margin,
            radius: borderRadius,
            borderWidth: borderWidth,
            child: value is Widget ? value : text(value, size: fontSize, bold: mouseOver && boldOnHover),
            color: mouseOver ? borderColorMouseOver : borderColor,
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

Widget pressed({
  required Widget child,
  required Function? callback,
  dynamic hint
}) {
  return onPressed(child: child, callback: callback, hint: hint);
}

Widget onPressed({
    required Widget child,
    required Function? callback,
    Function? onRightClick,
    dynamic hint,
}) {
  final Widget widget = MouseRegion(
      cursor: callback != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: GestureDetector(
          child: child,
          onSecondaryTap: onRightClick != null ? (){
            onRightClick.call();
          } : null,
          onTap: (){
            if (callback == null) return;
            callback();
          }
      ));

  if (hint == null) return widget;

  return Tooltip(
    message: hint.toString(),
    child: widget,
  );
}


typedef RefreshBuilder = Widget Function();
typedef WidgetFunction = Widget Function();

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
  Alignment alignment = Alignment.center,
  Color? color,
}) {
  return Container(
      // alignment: alignment,
      width: double.infinity,
      height: double.infinity,
      color: color,
      child: child
  );

}

Widget height(double value) {
  return SizedBox(height: value);
}

final Widget height2 = height(2);
final Widget height4 = height(4);
final Widget height8 = height(8);
final Widget height16 = height(16);
final Widget height20 = height(20);
final Widget height24 = height(24);
final Widget height32 = height(32);
final Widget height50 = height(50);
final Widget height64 = height(64);

Widget width(double value) {
  return SizedBox(width: value);
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

Widget bottomCenter({required Widget child, double padding = 0}){
  return Positioned(
      bottom: padding,
      child: Container(
        width: engine.screen.width,
        child: Row(
          mainAxisAlignment: axis.main.center,
          crossAxisAlignment: axis.cross.end,
          children: [child],
        ),
      ));
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

Widget buildDecorationImage({
  required DecorationImage image,
  double? width,
  double? height,
  double borderWidth = 1,
  Color? color,
  Color? borderColor,
}) {
  return Container(
    width: width,
    height: height,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      image: image,
      color: color,
      border: borderWidth > 0 && borderColor != null
          ? Border.all(color: borderColor, width: borderWidth)
          : null,
      borderRadius: borderRadius4,
    ),
  );
}

Widget visibleBuilder(Watch<bool> watch, Widget widget){
  return WatchBuilder(watch, (bool visible){
    if (!visible){
      return const SizedBox();
    }
    return widget;
  });
}

Widget textBuilder(Watch watch){
  return WatchBuilder(watch, (dynamic value){
    return text(value);
  });
}

Widget boolBuilder(Watch<bool> watch, {required Widget widgetTrue, required Widget widgetFalse}){
  return WatchBuilder(watch, (bool visible){
    return visible ? widgetTrue : widgetFalse;
  });
}