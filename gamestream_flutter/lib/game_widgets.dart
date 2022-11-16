import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'game_website.dart';
import 'ui/style.dart';


const empty = SizedBox();

class _FlutterKitConfiguration {
  Color defaultTextColor = Colors.white;
  double defaultTextFontSize = 18;
}

final flutterKitConfiguration = _FlutterKitConfiguration();

Widget watch<T>(Watch<T> watch, Widget Function(T t) builder){
  return WatchBuilder(watch, builder);
}

Widget text(dynamic value, {
    num? size,
    Function? onPressed,
    TextDecoration decoration = TextDecoration.none,
    FontWeight weight = FontWeight.normal,
    bool italic = false,
    bool bold = false,
    bool underline = false,
    Color? color,
    String? family,
    TextAlign? align,
    String Function(dynamic t)? format,
    double height = 1.0,
}) {
  final _text = Text(
      value.toString(),
      textAlign: align,
      style: TextStyle(
          color: color ?? flutterKitConfiguration.defaultTextColor,
          fontSize: size?.toDouble() ?? flutterKitConfiguration.defaultTextFontSize,
          decoration: underline ? TextDecoration.underline : decoration,
          fontWeight: bold ? FontWeight.bold : weight,
          fontFamily: family,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          height: height
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
  final _button = onPressed(
      callback: onPressed,
      child: onMouseOver(builder: (BuildContext context, bool mouseOver) {
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

Widget onPressed({
    required Widget child,
    Function? action,
    Function? onRightClick,
    dynamic hint,
}) {
  final widget = MouseRegion(
      cursor: action != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: GestureDetector(
         behavior: HitTestBehavior.opaque,
          child: child,
          onSecondaryTap: onRightClick != null ? (){
            onRightClick.call();
          } : null,
          onTap: (){
            if (action == null) return;
            action();
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
  return buildFullscreen(child: child);
}

Widget buildFullscreen({
  required Widget child,
  Alignment alignment = Alignment.center,
  Color? color,
}) =>
  Container(
      alignment: alignment,
      width: Engine.screen.width,
      height: Engine.screen.height,
      color: color,
      child: child
  );


Widget height(double value) {
  return SizedBox(height: value);
}

final Widget height2 = height(2);
final Widget height4 = height(4);
final Widget height6 = height(6);
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

final width2 = width(2);
final width3 = width(3);
final width4 = width(4);
final width6 = width(6);
final width8 = width(8);
final width16 = width(16);
final width32 = width(32);
final width64 = width(64);
final width96 = width(96);

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
    width: Engine.screen.width,
    height: Engine.screen.height,
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

Widget buildWatchBool(Watch<bool> watch, Widget Function() builder, [bool match = true]) =>
  WatchBuilder(watch, (bool value) =>
    value == match ? builder() : const SizedBox()
  );

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

Widget loadingText(String value, Function onPressed){
  var frame = 0;
  return Refresh(() {
     frame = (frame + 1) % 4;
     switch(frame){
       case 0:
         return text('-- $value --', size: FontSize.Large, bold: true, onPressed: onPressed);
       case 1:
         return text('/- $value -\\', size: FontSize.Large, bold: true, onPressed: onPressed);
       case 2:
         return text('|- $value -|', size: FontSize.Large, bold: true, onPressed: onPressed);
       case 3:
         return text('\\- $value -/', size: FontSize.Large, bold: true, onPressed: onPressed);
       default:
          return text(value);
     }
  }, milliseconds: 100);
}

Widget buildImage(String filename, {required double width, required double height}){
  return Container(
      width: width,
      height: height,
      decoration:
      BoxDecoration(image: DecorationImage(image: AssetImage(filename)))
  );
}

Widget buildTextButton(
    String value, {
      Function? action,
      double size = 24,
      Color? colorMouseOver,
      Color? colorRegular,
    }) =>
    onMouseOver(builder: (BuildContext context, bool mouseOver) =>
        text(value,
            onPressed: action,
            size: size,
            color: mouseOver ? colorMouseOver ?? Colors.white70 : colorRegular ?? Colors.white54
        ),
    );



const EdgeInsets padding16 = EdgeInsets.all(16);
const EdgeInsets padding6 = EdgeInsets.all(6);
const EdgeInsets padding8 = EdgeInsets.all(8);
const EdgeInsets padding4 = EdgeInsets.all(4);
const EdgeInsets padding0 = EdgeInsets.zero;
const BorderRadius borderRadius0 = BorderRadius.zero;
const BorderRadius borderRadius2 = BorderRadius.all(radius2);
const BorderRadius borderRadius4 = BorderRadius.all(radius4);
const BorderRadius borderRadius8 = BorderRadius.all(radius8);
const BorderRadius borderRadius16 = BorderRadius.all(radius16);
const BorderRadius borderRadius32 = BorderRadius.all(radius32);

const BorderRadius borderRadiusBottomRight8 = BorderRadius.only(bottomRight: radius8);

const Radius radius0 = Radius.circular(0);
const Radius radius2 = Radius.circular(2);
const Radius radius4 = Radius.circular(4);
const Radius radius8 = Radius.circular(8);
const Radius radius16 = Radius.circular(16);
const Radius radius32 = Radius.circular(32);

final _Radius radius = _Radius();

class _Radius {
  final Radius circular4 = const Radius.circular(4);
  final Radius circular8 = const Radius.circular(8);
  final Radius circular16 = const Radius.circular(16);
  final Radius circular32 = const Radius.circular(32);
}

final Border border3 = Border.all(width: 3.0);

final Color black26 = Colors.black26;
final Color black45 = Colors.black45;
final Color black54 = Colors.black54;

const FontWeight bold = FontWeight.bold;
final TextDecoration underline = TextDecoration.underline;

// final _Axis axis = _Axis();
//
// class _Axis {
//   final _Main main = _Main();
//   final _Cross cross = _Cross();
// }

// class _Main {
//   final MainAxisAlignment start = MainAxisAlignment.start;
//   final MainAxisAlignment end = MainAxisAlignment.end;
//   final MainAxisAlignment center = MainAxisAlignment.center;
//   final MainAxisAlignment between = MainAxisAlignment.spaceBetween;
//   final MainAxisAlignment spread = MainAxisAlignment.spaceBetween;
//   final MainAxisAlignment apart = MainAxisAlignment.spaceBetween;
//   final MainAxisAlignment even = MainAxisAlignment.spaceEvenly;
// }
//
// class _Cross {
//   final CrossAxisAlignment center = CrossAxisAlignment.center;
//   final CrossAxisAlignment start = CrossAxisAlignment.start;
//   final CrossAxisAlignment end = CrossAxisAlignment.end;
//   final CrossAxisAlignment stretch = CrossAxisAlignment.stretch;
// }

