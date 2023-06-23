import 'package:flutter/material.dart';
import 'package:gamestream_flutter/game_widgets.dart';

Widget buildText(dynamic value, {
  num size = 18,
  Function? onPressed,
  TextDecoration decoration = TextDecoration.none,
  FontWeight weight = FontWeight.normal,
  bool italic = false,
  bool bold = false,
  bool underline = false,
  Color color = Colors.white,
  String? family,
  TextAlign? align,
  String Function(dynamic t)? format,
  double height = 1.0,
}) {
  final _text = Text(

      value.toString(),
      textAlign: align,
      style: TextStyle(
          color: color,
          fontSize: size.toDouble(),
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
