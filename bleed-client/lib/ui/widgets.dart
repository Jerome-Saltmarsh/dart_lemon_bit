import 'dart:async';

import 'package:bleed_client/game_engine/engine_state.dart';
import 'package:bleed_client/game_engine/game_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget text(String value, {fontSize = 18, Function onPressed}) {
  Widget _text = Text(value, style: TextStyle(color: Colors.white, fontSize: fontSize));
  if (onPressed == null) return _text;
  return GestureDetector(child: _text, onTap: onPressed,);

}

Widget border({Widget child}) {
  return Container(
    decoration: BoxDecoration(border: Border.all(color: Colors.white)),
    child: child,
  );
}


class Refresh extends StatefulWidget {

  final Builder builder;
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

  void rebuild(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder.builder(context);
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
}

Widget button(String value, Function onPressed,
    {double fontSize = 18.0, ButtonStyle buttonStyle}) {
  return OutlinedButton(
    child: Container(
        width: 200,
        height: 50,
        alignment: Alignment.centerLeft,
        child: Text(value,
            style: TextStyle(color: Colors.white, fontSize: fontSize))),
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

Widget height(double value){
  return Container(height: value);
}

final Widget height2 = height(2);
final Widget height4 = height(4);
final Widget height8 = height(8);
final Widget height16 = height(16);
final Widget height32 = height(32);
final Widget height50 = height(50);

Widget width(double value){
  return Container(width: value);
}

ButtonStyle _buttonStyle = buildButtonStyle(white, 2);

ButtonStyle buildButtonStyle(Color borderColor, double borderWidth) {
  return OutlinedButton.styleFrom(
    side: BorderSide(color: borderColor, width: borderWidth),
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5))),
  );
}
