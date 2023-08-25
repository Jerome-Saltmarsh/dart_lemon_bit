import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';

class IsometricColors {
  static const Black = Color.fromRGBO(38, 34, 47, 1.0);

  final brown_4 = Color.fromRGBO(46, 34, 47, 1);
  final brown_3 = Color.fromRGBO(62, 53, 70, 1);
  final brown_2 = Color.fromRGBO(98, 85, 101, 1);
  final brown_1 = Color.fromRGBO(150, 108, 108, 1);
  final brown_0 = Color.fromRGBO(171, 148, 122, 1);

  final aqua_5 = Color.fromRGBO(11, 94, 101, 1);
  final aqua_4 = Color.fromRGBO(11, 138, 143, 1);
  final aqua_3 = Color.fromRGBO(14, 175, 155, 1);
  final aqua_2 = Color.fromRGBO(48, 225, 185, 1);
  final aqua_1 = Color.fromRGBO(143, 248, 226, 1);

  final blue_0 = Color.fromARGB(255, 143, 211, 255);
  final blue_1 = Color.fromARGB(255, 77, 155, 230);
  final blue_2 = Color.fromARGB(255, 77, 101, 180);
  final blue_3 = Color.fromARGB(255, 72, 74, 119);
  final blue_4 = Color.fromARGB(255, 50, 51, 83);

  final green_0 = Color.fromRGBO(205, 223, 108, 1);
  final green_1 = Color.fromRGBO(145, 219, 105, 1);
  final green_2 = Color.fromRGBO(30, 188, 115, 1);
  final green_3 = Color.fromRGBO(35, 144, 99, 1);
  final green_4 = Color.fromRGBO(22, 90, 76, 1);
  final green_5 = Color.fromRGBO(30, 61, 62, 1);

  final fair_0 = Color.fromRGBO(253, 203, 176, 1);
  final fair_1 = Color.fromRGBO(252, 167, 144, 1);
  final fair_2 = Color.fromRGBO(246, 129, 129, 1);
  final fair_3 = Color.fromRGBO(240, 79, 120, 1);
  final fair_4 = Color.fromRGBO(195, 36, 84, 1);
  final fair_5 = Color.fromRGBO(131, 28, 93, 1);
  final fair_6 = Color.fromRGBO(84, 30, 71, 1);

  final brownDark = Color.fromRGBO(36, 33, 38, 1);
  final brownDarkX = Color.fromRGBO(29, 27, 31, 1.0);
  final brownLight = Color.fromRGBO(48, 48, 48, 1.0);

  final black = Black;
  final black05 = Black.withOpacity(0.05);
  final black10 = Black.withOpacity(0.1);
  final black15 = Black.withOpacity(0.15);
  final black20 = Black.withOpacity(0.2);
  final black382 = Black.withOpacity(goldenRatio_0381);
  final black618 = Black.withOpacity(goldenRatio_0618);

  final white = Colors.white;
  final white05 = Colors.white.withOpacity(0.05);
  final white10 = Colors.white.withOpacity(0.10);
  final white382 = Colors.white.withOpacity(0.382);
  final white60 = Colors.white.withOpacity(0.60);
  final white618 = Colors.white.withOpacity(0.618);
  final white70 = Colors.white.withOpacity(0.70);
  final white80 = Colors.white.withOpacity(0.80);
  final white85 = Colors.white.withOpacity(0.85);
  final white90 = Colors.white.withOpacity(0.90);
  final white95 = Colors.white.withOpacity(0.95);

  final red0 = Color.fromARGB(255, 245, 125, 74);
  final red1 = Color.fromARGB(255, 234, 79, 54);
  final red2 = Color.fromARGB(255, 179, 56, 49);
  final red3 = Color.fromARGB(255, 110, 39, 39);
  final orange = Color.fromARGB(255, 249, 194, 43);
  final blue1_05 = Color.fromARGB(126, 77, 155, 230);

  late final List<Color> shadeBrown = [
    brown_4,
    brown_3,
    brown_2,
    brown_1,
    brown_0,
  ];

  late final List<Color> shadeAqua = [
    aqua_1,
    aqua_2,
    aqua_3,
    aqua_4,
    aqua_5,
  ];

  late final List<List<Color>> shades = [
    shadeBrown,
    shadeAqua,
  ];

  late final List<Color> palette;

  IsometricColors(){
    palette = [
      brown_4,
      brown_3,
      brown_2,
      brown_1,
      brown_0,
      green_5,
      green_4,
      green_3,
      green_2,
      green_1,
      green_0,
      fair_6,
      fair_5,
      fair_4,
      fair_3,
      fair_2,
      fair_1,
      fair_0,
    ];
  }
}
