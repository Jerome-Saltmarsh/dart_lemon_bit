import 'package:flutter/material.dart';
import 'package:gradients/gradients.dart';
import 'package:gamestream_flutter/library.dart';

class GameLighting {

  static late RadialGradientPainter gradient;

  static double getRandomHue() => randomBetween(0, 360);

  static final Color_Lightning = HSVColor.fromColor(Colors.white.withOpacity(Engine.GoldenRatio_0_381));


  static final Color_Torch = Color.fromRGBO(7, 255, 153, 0.61);
  static final Color_Torch_HSV =  HSVColor.fromColor(Color_Torch);

  static final Ambient_Color = Color.fromRGBO(94, 66, 136, 0.61);
  static final Ambient_Color_HSV = HSVColor.fromColor(Ambient_Color);
  static final Ambient_Color_Start = Ambient_Color_HSV.withAlpha(0);
  static final Ambient_Color_End = Ambient_Color_Start.withAlpha(1);

  static var start_hue_shift = Watch(getRandomHue());
  static var _start_hue = Ambient_Color_Start.hue;
  static var start_saturation = Ambient_Color_Start.saturation;
  static var start_value = Ambient_Color_Start.value;
  static var start_alpha = Ambient_Color_Start.alpha;

  static var end_hue_shift = Watch(getRandomHue());
  static var _end_hue = Ambient_Color_End.hue;
  static var end_saturation = Ambient_Color_End.saturation;
  static var end_value = Ambient_Color_End.value;
  static var end_alpha = Ambient_Color_End.alpha;

  static double get start_hue => _start_hue;
  static double get end_hue => _end_hue;

  static final values = Uint32List(7);
  static final values_transparent = Uint32List(7);

  static set start_hue(double value){
    assert (value >= 0);
    _start_hue = value % 360.0;
  }

  static set end_hue(double value){
    assert (value >= 0);
    _end_hue = value % 360.0;
  }

  static void setStartHSVColor(HSVColor color){
    start_hue = color.hue;
    start_saturation = color.saturation;
    start_value = color.value;
    start_alpha = color.alpha;
  }

  static final interpolations = [
    0.00,
    0.25,
    0.40,
    0.60,
    0.80,
    0.95,
    1.00,
  ];

  static void applyHueShift(){
    start_hue = (start_hue + start_hue_shift.value);
    end_hue = (start_hue + end_hue_shift.value);
  }

  static Color get colorStart => Color(hsvToColorValue(
     start_hue, start_saturation, start_value, start_alpha,
  ));

  static Color get colorEnd => Color(hsvToColorValue(
    end_hue, end_saturation, end_value, end_alpha,
  ));

  static void refreshValues({bool applyHueShift = true}) {

    if (applyHueShift){
      start_hue = (start_hue + start_hue_shift.value);
      end_hue = (start_hue + end_hue_shift.value);
    }

    for (var i = 0; i < 7; i++) {
      final t = interpolations[i];
      values[i] = hsvToColorValue(
        linerInterpolation(start_hue, end_hue, t),
        linerInterpolation(start_saturation, end_saturation, t),
        linerInterpolation(start_value, end_value, t),
        linerInterpolation(start_alpha, end_alpha, t),
      );
      values_transparent[i] = hsvToColorValue(
        linerInterpolation(start_hue, end_hue, t),
        linerInterpolation(start_saturation, end_saturation, t),
        linerInterpolation(start_value, end_value, t),
        // linerInterpolation(0.5, end_alpha, t),
        0.5,
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

  static int colorValueFromARGB(int a, int r, int g, int b) => (
      ((a & 0xff) << 24) |
      ((r & 0xff) << 16) |
      ((g & 0xff) << 08) |
      ((b & 0xff) << 00)
      ) & 0xFFFFFFFF;
}

