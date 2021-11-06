import 'dart:ui';

import 'package:flutter/painting.dart';

class ColorMap {
  int h;
  int s;
  int v;
  Color get color => HSVColor.fromAHSV(1, h.toDouble(), s.toDouble(), v.toDouble()).toColor();

  ColorMap(this.h, this.s, this.v);
}

Color m = ColorMap(200, 100, 50).color;

class ColorGrid {
  int column1Value;
  int column2Value;
  int column3Value;
}
