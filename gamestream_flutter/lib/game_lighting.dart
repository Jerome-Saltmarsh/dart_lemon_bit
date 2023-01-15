import 'package:gamestream_flutter/library.dart';

class GameLighting {

  static double getRandomHue() => randomBetween(0, 360);

  static var interpolations = [
    0,
    0.26530612244897944,
    0.4897959183673469,
    0.6734693877551021,
    0.8163265306122449,
    0.9183673469387755,
    0.9795918367346939,
  ];

  static double linerInterpolation(double a, double b, double t) {
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

