import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';

final _Colors colours = _Colors();

final Color none = Colors.transparent;
final Color white05 = Colors.white.withOpacity(0.05);

Color get green => colours.green;

class _Colors {

  final Color facebook = Color.fromRGBO(66, 103, 178, 1);
  final Color black = Color.fromRGBO(33, 29, 43, 1.0);
  final Color brownDark = Color.fromRGBO(36, 33, 38, 1);
  final Color brownLight = Color.fromRGBO(48, 48, 48, 1.0);
  final Color black05 = Colors.black.withOpacity(0.05);
  final Color black10 = Colors.black.withOpacity(0.1);
  final Color black15 = Colors.black.withOpacity(0.15);
  final Color black20 = Colors.black.withOpacity(0.2);
  final Color black382 = Colors.black.withOpacity(goldenRatio_0381);
  final Color black618 = Colors.black.withOpacity(goldenRatio_0618);

  final Color white = Colors.white;
  final Color white05 = Colors.white.withOpacity(0.05);
  final Color white10 = Colors.white.withOpacity(0.10);
  final Color white382 = Colors.white.withOpacity(0.382);
  final Color white60 = Colors.white.withOpacity(0.60);
  final Color white618 = Colors.white.withOpacity(0.618);
  final Color white70 = Colors.white.withOpacity(0.70);
  final Color white80 = Colors.white.withOpacity(0.80);
  final Color white85 = Colors.white.withOpacity(0.85);
  final Color white90 = Colors.white.withOpacity(0.90);
  final Color white95 = Colors.white.withOpacity(0.95);

  final Color none = Colors.transparent;

  final Color redDarkest = Color.fromRGBO(66, 21, 46, 1);
  final Color redDark1 = Color.fromRGBO(92, 30, 55, 1);
  final Color redDark = Color.fromRGBO(179, 56, 49, 1);
  // final Color redWhite = Color.fromRGBO(244, 166, 154, 1.0);
  // final Color redWhite = Color.fromRGBO(242, 155, 172, 1.0);
  final Color redWhite = Color.fromRGBO(255, 192, 171, 1.0);
  final Color red = Color.fromRGBO(234, 79, 54, 1.0);
  final Color orange = Color.fromRGBO(247, 150, 23, 1);
  final Color green = Color.fromRGBO(30, 188, 115 , 1);
  final Color greenDark = Color.fromRGBO(20, 114, 71, 1.0);
  final Color yellow = Color.fromRGBO(251, 185, 84, 1);
  final Color yellowDark  = Color.fromRGBO(158, 69, 57, 1);

  final Color blue =  Color.fromRGBO(77, 155, 230, 1);
  final Color blueDarkest =  Color.fromRGBO(50, 51, 83, 1);
  final Color aqua =  Color.fromRGBO(143, 248, 226, 1);
  final Color aquaDarkest =  Color.fromRGBO(11, 94, 101, 1);
  final Color purple =  Color.fromRGBO(168, 132, 243, 1);
  final Color purpleDarkest =  Color.fromRGBO(69, 41, 63, 1);
  final Color transparent =  Colors.transparent;

  final Color grey = Color.fromRGBO(120, 120, 120, 1.0);
  final Color greyDark = Color.fromRGBO(60, 60, 60, 1.0);

  final Color skinCaucasian01 = Color.fromRGBO(226, 198, 181, 1.0);
  final Color skinCaucasian02 = Color.fromRGBO(168, 130, 123, 1.0);
  final Color skinCaucasian03 = Color.fromRGBO(142, 96, 98, 1.0);
  final Color skinCaucasian04 = Color.fromRGBO(85, 56, 58, 1.0);
  final Color pitchBlack = Color.fromRGBO(28, 27, 23, 1.0);
  Color get blood => redDark;
}
