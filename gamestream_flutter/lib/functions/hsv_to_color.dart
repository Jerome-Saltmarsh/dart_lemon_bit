
import 'dart:ui';

const blueA = 255;
const blueH = 209;
const blueS = 66;
const blueV = 90;

final blue = Color(4293278780);

/// @hue a number between 0 and 255
/// @saturation a number between 0 and 255
/// @value a number between 0 and 255
/// @opacity a number between 0 and 255
int hsvToColor({
  required int hue,
  required int saturation,
  required int value,
  required int opacity,
}) {

  // Calculate color
  final p = (value * (255 - saturation)) >> 8;
  final q = (value * (255)) >> 8;
  final t = (value * (255 - ((saturation * (255)) >> 8))) >> 8;
  switch (hue ~/ 43) {
    case 0:
      return (opacity << 24) | (value << 16) | (t << 8) | p;
    case 1:
      return (opacity << 24) | (q << 16) | (value << 8) | p;
    case 2:
      return (opacity << 24) | (p << 16) | (value << 8) | t;
    case 3:
      return (opacity << 24) | (p << 16) | (q << 8) | value;
    case 4:
      return (opacity << 24) | (t << 16) | (p << 8) | value;
    case 5:
      return (opacity << 24) | (value << 16) | (p << 8) | q;
    default:
      return (opacity << 24) | (0 << 16) | (0 << 8) | 0;
  }
}


/// @saturation a number between 0 and 255
/// @value a number between 0 and 255
/// @opacity a number between 0 and 255
int hsvToColor2({
  required int hue,
  required int saturation,
  required int value,
  required int opacity,
}) {

  // Calculate color
  int r, g, b;
  final i = (hue ~/ 43);
  final f = (hue - (i * 43)) * 6;
  final p = (value * (255 - saturation)) >> 8;
  final q = (value * (255 - ((saturation * f) >> 8))) >> 8;
  final t = (value * (255 - ((saturation * (255 - f)) >> 8))) >> 8;
  switch (i) {
    case 0:
      r = value;
      g = t;
      b = p;
      break;
    case 1:
      r = q;
      g = value;
      b = p;
      break;
    case 2:
      r = p;
      g = value;
      b = t;
      break;
    case 3:
      r = p;
      g = q;
      b = value;
      break;
    case 4:
      r = t;
      g = p;
      b = value;
      break;
    case 5:
      r = value;
      g = p;
      b = q;
      break;
    default:
      r = 0;
      g = 0;
      b = 0;
      break;
  }

  // Combine color with opacity and return as integer
  return (opacity << 24) | (r << 16) | (g << 8) | b;
}


/// @hue between 0 and 360
/// @saturation between 0 and 100
/// @value between 0 and 100
/// @opacity 0 and 255
int hsvToColor3({
  required int hue,
  required int saturation,
  required int value,
  required int opacity,
}) {
  // Convert hue, saturation, and value to 0-255 range
  // final h = (hue / 360 * 255).round();
  // final s = (saturation * 255).round();
  // final v = (value * 255).round();

  // Calculate color
  int r, g, b;
  final i = (hue / 43).floor();
  final f = (hue - (i * 43)) * 6;
  final p = (value * (255 - saturation)) >> 8;
  final q = (value * (255 - ((saturation * f) >> 8))) >> 8;
  final t = (value * (255 - ((saturation * (255 - f)) >> 8))) >> 8;
  switch (i) {
    case 0:
      r = value;
      g = t;
      b = p;
      break;
    case 1:
      r = q;
      g = value;
      b = p;
      break;
    case 2:
      r = p;
      g = value;
      b = t;
      break;
    case 3:
      r = p;
      g = q;
      b = value;
      break;
    case 4:
      r = t;
      g = p;
      b = value;
      break;
    case 5:
      r = value;
      g = p;
      b = q;
      break;
    default:
      r = 0;
      g = 0;
      b = 0;
      break;
  }

  // Combine color with opacity and return as integer
  return ((opacity * 255).round() << 24) | (r << 16) | (g << 8) | b;
}


int hsvToColor4({
  required int hue,
  required int saturation,
  required int value,
  required int opacity,
}) {
  double h = hue / 360;
  double s = saturation / 100;
  double v = value / 100;

  int i = (h * 6).floor();
  double f = h * 6 - i;
  double p = v * (1 - s);
  double q = v * (1 - f * s);
  double t = v * (1 - (1 - f) * s);

  double r, g, b;
  switch (i % 6) {
    case 0:
      r = v;
      g = t;
      b = p;
      break;
    case 1:
      r = q;
      g = v;
      b = p;
      break;
    case 2:
      r = p;
      g = v;
      b = t;
      break;
    case 3:
      r = p;
      g = q;
      b = v;
      break;
    case 4:
      r = t;
      g = p;
      b = v;
      break;
    case 5:
      r = v;
      g = p;
      b = q;
      break;
    default:
      r = 0;
      g = 0;
      b = 0;
      break;
  }

  int red = (r * 255).round();
  int green = (g * 255).round();
  int blue = (b * 255).round();

  return (opacity & 0xff) << 24 | (red & 0xff) << 16 | (green & 0xff) << 8 | (blue & 0xff);
}