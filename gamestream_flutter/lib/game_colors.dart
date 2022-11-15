import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';

class GameColors {
  static final Color facebook = Color.fromRGBO(66, 103, 178, 1);
  static final Color black = Color.fromRGBO(38, 34, 47, 1.0);

  static final Color brown00 = Color.fromRGBO(46, 34, 47, 1);
  static final Color brown01 = Color.fromRGBO(62, 53, 70, 1);
  static final Color brown02 = Color.fromRGBO(98, 85, 101, 1);
  static final Color brown03 = Color.fromRGBO(150, 108, 108, 1);
  static final Color brown04 = Color.fromRGBO(171, 148, 122, 1);

  static final Color brownDark = Color.fromRGBO(36, 33, 38, 1);
  static final Color brownLight = Color.fromRGBO(48, 48, 48, 1.0);
  static final Color black05 = black.withOpacity(0.05);
  static final Color black10 = black.withOpacity(0.1);
  static final Color black15 = black.withOpacity(0.15);
  static final Color black20 = black.withOpacity(0.2);
  static final Color black382 = black.withOpacity(goldenRatio_0381);
  static final Color black618 = black.withOpacity(goldenRatio_0618);

  static final Color white = Colors.white;
  static final Color white05 = Colors.white.withOpacity(0.05);
  static final Color white10 = Colors.white.withOpacity(0.10);
  static final Color white382 = Colors.white.withOpacity(0.382);
  static final Color white60 = Colors.white.withOpacity(0.60);
  static final Color white618 = Colors.white.withOpacity(0.618);
  static final Color white70 = Colors.white.withOpacity(0.70);
  static final Color white80 = Colors.white.withOpacity(0.80);
  static final Color white85 = Colors.white.withOpacity(0.85);
  static final Color white90 = Colors.white.withOpacity(0.90);
  static final Color white95 = Colors.white.withOpacity(0.95);

  static final Color none = Colors.transparent;

  static final Color redDarkest = Color.fromRGBO(66, 21, 46, 1);
  static final Color redDark1 = Color.fromRGBO(92, 30, 55, 1);
  static final Color redDark = Color.fromRGBO(179, 56, 49, 1);

  static final Color redWhite = Color.fromRGBO(255, 192, 171, 1.0);
  static final Color red = Color.fromRGBO(234, 79, 54, 1.0);
  static final Color orange = Color.fromRGBO(247, 150, 23, 1);
  static final Color green = Color.fromRGBO(30, 188, 115, 1);
  static final Color greenDark = Color.fromRGBO(20, 114, 71, 1.0);
  static final Color yellow = Color.fromRGBO(251, 185, 84, 1);
  static final Color yellowDark = Color.fromRGBO(158, 69, 57, 1);

  static final Color blue = Color.fromRGBO(77, 155, 230, 1);
  static final Color blueDarkest = Color.fromRGBO(50, 51, 83, 1);
  static final Color aqua = Color.fromRGBO(143, 248, 226, 1);
  static final Color aquaDarkest = Color.fromRGBO(11, 94, 101, 1);
  static final Color purple = Color.fromRGBO(168, 132, 243, 1);
  static final Color purpleDarkest = Color.fromRGBO(69, 41, 63, 1);
  static final Color transparent = Colors.transparent;

  static final Color grey = Color.fromRGBO(120, 120, 120, 1.0);
  static final Color greyDark = Color.fromRGBO(60, 60, 60, 1.0);

  Color get blood => redDark;

  static final Color inventoryHint = Colors.orange.withOpacity(0.85);
}
