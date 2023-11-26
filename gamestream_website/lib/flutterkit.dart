import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamestream_flutter/styles.dart';
import 'package:gamestream_flutter/utils/widget_utils.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_watch/watch.dart';
import 'package:lemon_watch/watch_builder.dart';

import 'ui/style.dart';

const empty = SizedBox();


class _FlutterKitConfiguration {
  Color defaultTextColor = Colors.white;
  double defaultTextFontSize = 18;
}

final _FlutterKitConfiguration flutterKitConfiguration = _FlutterKitConfiguration();

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

// BoxDecoration panelDecoration({
//   double borderWidth = 2.0,
//   Color borderColor = Colors.white,
//   double borderRadius = 4,
//   Color fillColor = Colors.white,
// }) {
//   return BoxDecoration(
//       border: Border.all(color: borderColor, width: borderWidth),
//       borderRadius: borderRadius4,
//       color: fillColor);
// }

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

final width32 = width(32);
final width16 = width(16);
final width8 = width(8);
final width6 = width(6);
final width4 = width(4);
final width2 = width(2);

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

Widget buildCanvas({
  required PaintCanvas paint,
  required ValueNotifier<int> frame,
  ShouldRepaint? shouldRepaint,
}){
  return CustomPaint(
    painter: CustomPainterPainter(
        paint,
        shouldRepaint ?? (CustomPainter oldDelegate) => false,
        frame
    ),
  );
}

typedef PaintCanvas = void Function(Canvas canvas, Size size);
typedef ShouldRepaint = bool Function(CustomPainter oldDelegate);

class CustomPainterPainter extends CustomPainter {

  final PaintCanvas paintCanvas;
  final ShouldRepaint doRepaint;

  CustomPainterPainter(this.paintCanvas, this.doRepaint, ValueNotifier<int> frame) : super(repaint: frame);

  @override
  void paint(Canvas canvas, Size size) {
    return paintCanvas(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return doRepaint(oldDelegate);
  }
}