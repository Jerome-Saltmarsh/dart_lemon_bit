import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/gamestream/ui/widgets/mouse_over.dart';
import 'package:lemon_watch/src.dart';

import 'gamestream/ui/widgets/build_text.dart';
import 'gamestream/ui/widgets/nothing.dart';
import 'instances/engine.dart';

Widget watch<T>(Watch<T> watch, Widget Function(T t) builder){
  return WatchBuilder(watch, builder);
}

Widget buildWatch<T>(Watch<T> watch, Widget Function(T t) builder){
  return WatchBuilder(watch, builder);
}

Widget border({
  required Widget child,
  Color color = Colors.white,
  double width = 1,
  BorderRadius radius = borderRadius4,
  Color fillColor = Colors.transparent,
}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
        border: Border.all(color: color, width: width),
        borderRadius: radius,
    ),
    child: child,
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
  int fontSize = 18,
  bool boldOnHover = false,
  Alignment alignment = Alignment.center
}) {
  final _button = onPressed(
      callback: onPressed,
      child: MouseOver(builder: (bool mouseOver) {
        return border(
            radius: borderRadius,
            width: borderWidth,
            child: value is Widget ? value : buildText(value, size: fontSize, bold: mouseOver && boldOnHover),
            color: mouseOver ? borderColorMouseOver : borderColor,
            fillColor: mouseOver ? fillColorMouseOver : fillColor,
        );
      }));

  if (hint != null) {
    return Tooltip(message: hint, child: _button);
  }
  return _button;
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

Widget buildFullscreen({
  required Widget child,
  Alignment alignment = Alignment.center,
  Color? color,
}) =>
  Container(
      alignment: alignment,
      width: engine.screen.width,
      height: engine.screen.height,
      color: color,
      child: child
  );


const height2 = SizedBox(height: 2);
const height4 = SizedBox(height: 4);
const height6 = SizedBox(height: 6);
const height8 = SizedBox(height: 8);
const height12 = SizedBox(height: 12);
const height16 = SizedBox(height: 16);
const height20 = SizedBox(height: 20);
const height24 = SizedBox(height: 24);
const height32 = SizedBox(height: 32);
const height50 = SizedBox(height: 50);
const height64 = SizedBox(height: 64);

const width2 = SizedBox(width: 2);
const width3 = SizedBox(width: 3);
const width4 = SizedBox(width: 4);
const width6 = SizedBox(width: 6);
const width8 = SizedBox(width: 8);
const width16 = SizedBox(width: 16);
const width32 = SizedBox(width: 32);
const width64 = SizedBox(width: 64);
const width96 = SizedBox(width: 96);
const width128 = SizedBox(width: 128);
const width256 = SizedBox(width: 256);

const borderRadius4 = BorderRadius.all(Radius.circular(4));

ButtonStyle buildButtonStyle(Color borderColor, double borderWidth) {
  return OutlinedButton.styleFrom(
    side: BorderSide(color: borderColor, width: borderWidth),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
  );
}

final blank = const Positioned(
  child: const Text(""),
  top: 0,
  left: 0,
);

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

Widget buildWatchBool(
    Watch<bool> watch,
    Widget Function() builder,
    [bool match = true]
) =>
  WatchBuilder(watch, (bool value) => value == match ? builder() : nothing);


