
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
