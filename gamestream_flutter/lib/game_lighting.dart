import 'package:flutter/material.dart';
import 'package:gamestream_flutter/library.dart';

class GameLighting {
  static final Color_Lightning = HSVColor.fromColor(Colors.white.withOpacity(Engine.GoldenRatio_0_381));
  static final Transparent =  GameColors.black.withOpacity(0.5).value;

  static final Default_Color_Start =  HSVColor.fromColor(Color.fromRGBO(38, 34, 47, 1.0).withOpacity(0));
  static final Default_Color_End =  HSVColor.fromColor(Color.fromRGBO(38, 34, 47, 1.0).withOpacity(1));

  static var hueStart = Default_Color_Start.hue;
  static var saturationStart = Default_Color_Start.saturation;
  static var valueStart = Default_Color_Start.value;
  static var alphaStart = Default_Color_Start.alpha;
  static var hueEnd = Default_Color_End.hue;
  static var saturationEnd = Default_Color_End.saturation;
  static var valueEnd = Default_Color_End.value;
  static var alphaEnd = Default_Color_End.alpha;
  static final Color_Shades = Uint32List(7);

  static void setStartHSVColor(HSVColor color){
    hueStart = color.hue;
    saturationStart = color.saturation;
    valueStart = color.value;
    alphaStart = color.alpha;
  }

  static final ts = [
    0.00,
    0.20,
    0.40,
    0.60,
    0.80,
    0.92,
    1.00,
  ];

  static void refreshValues(){
    for (var i = 0; i < 7; i++) {
      final t = ts[i];
      Color_Shades[i] = hsvToColorValue(
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

