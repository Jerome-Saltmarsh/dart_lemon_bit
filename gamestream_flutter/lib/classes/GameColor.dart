
import 'dart:typed_data';

import 'package:gamestream_flutter/library.dart';

final gameCols = GameCols();

class GameCols {
  var hueStart = 258.0;
  var saturationStart = 27.0;
  var valueStart = 18.0;
  var alphaStart = 0.0;
  var hueEnd = 258.0;
  var saturationEnd = 27.0;
  var valueEnd = 18.0;
  var alphaEnd = 1.0;
  final values = Uint32List(7);

  final ts = [
    0.00,
    0.20,
    0.40,
    0.60,
    0.80,
    0.92,
    1.00,
  ];

  void refreshValues(){
    for (var i = 0; i < 7; i++) {
      final t = ts[i];
      values[i] = hsvToColorValue(
          linerInterpolation(hueStart, hueEnd, t),
          linerInterpolation(saturationStart, saturationEnd, t),
          linerInterpolation(valueStart, valueEnd, t),
          linerInterpolation(alphaStart, alphaEnd, t),
      );
    }
  }

  static double linerInterpolation(double a, double b, double t) {
    if (a == b || (a.isNaN == true) && (b.isNaN == true))
      return a;
    assert(a.isFinite, 'Cannot interpolate between finite and non-finite values');
    assert(b.isFinite, 'Cannot interpolate between finite and non-finite values');
    assert(t.isFinite, 't must be finite when interpolating between values');
    return a * (1.0 - t) + b * t;
    // return clamp01(a * (1.0 - t) + b * t);
  }

  static int hsvToColorValue(double hue, double saturation, double value, double alpha) {
    final chroma = saturation * value;
    final secondary = chroma * (1.0 - (((hue / 60.0) % 2.0) - 1.0).abs());
    final match = value - chroma;
    return colorIntFromHue(alpha, hue, chroma, secondary, match);
  }

  static int colorIntFromHue(
      double alpha,
      double hue,
      double chroma,
      double secondary,
      double match,
      ) {
    double red;
    double green;
    double blue;
    if (hue < 60.0) {
      red = chroma;
      green = secondary;
      blue = 0.0;
    } else if (hue < 120.0) {
      red = secondary;
      green = chroma;
      blue = 0.0;
    } else if (hue < 180.0) {
      red = 0.0;
      green = chroma;
      blue = secondary;
    } else if (hue < 240.0) {
      red = 0.0;
      green = secondary;
      blue = chroma;
    } else if (hue < 300.0) {
      red = secondary;
      green = 0.0;
      blue = chroma;
    } else {
      red = chroma;
      green = 0.0;
      blue = secondary;
    }
    return colorValueFromARGB((alpha * 0xFF).round(), ((red + match) * 0xFF).round(), ((green + match) * 0xFF).round(), ((blue + match) * 0xFF).round());
  }

  static int colorValueFromARGB(int a, int r, int g, int b) =>
      (((a & 0xff) << 24) |
      ((r & 0xff) << 16) |
      ((g & 0xff) << 8)  |
      ((b & 0xff) << 0)) & 0xFFFFFFFF;
}
