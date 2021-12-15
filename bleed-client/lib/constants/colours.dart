import 'package:bleed_client/common/enums/Shade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

final _Colors colours = _Colors();

class _Colors {

  final Color black = Color.fromRGBO(24, 21, 26, 1);

  final Color redDarkest = Color.fromRGBO(66, 21, 46, 1);
  final Color redDark = Color.fromRGBO(179, 56, 49, 1);
  final Color red = Color.fromRGBO(234, 79, 54, 1.0);
  final Color orange = Color.fromRGBO(247, 150, 23, 1);
  final Color green = Color.fromRGBO(30, 188, 115 , 1);
  final Color yellow = Color.fromRGBO(249, 194, 43, 1);
  final Color blue = Colors.blue;

  final Color white = Color.fromRGBO(220, 220, 220, 1.0);
  final Color grey = Color.fromRGBO(120, 120, 120, 1.0);
  final Color greyDark = Color.fromRGBO(60, 60, 60, 1.0);

  final Color skinCaucasian01 = Color.fromRGBO(226, 198, 181, 1.0);
  final Color skinCaucasian02 = Color.fromRGBO(168, 130, 123, 1.0);
  final Color skinCaucasian03 = Color.fromRGBO(142, 96, 98, 1.0);
  final Color skinCaucasian04 = Color.fromRGBO(85, 56, 58, 1.0);
  final Color pitchBlack = Color.fromRGBO(28, 27, 23, 1.0);



  Color get blood => redDark;
}


Color getColorSkin(Shade shading){
  switch (shading){
    case Shade.Bright:
      return colours.skinCaucasian01;
    case Shade.Medium:
      return colours.skinCaucasian02;
    case Shade.Dark:
      return colours.skinCaucasian03;
    case Shade.VeryDark:
      return colours.skinCaucasian04;
    case Shade.PitchBlack:
      return colours.pitchBlack;
  }
  throw Exception();
}