import 'dart:math';

int lerpColors(int colorA, int colorB, double t) {
  // Extract the individual components of colorA
  final alphaA = (colorA >> 24) & 0xFF;
  final redA = (colorA >> 16) & 0xFF;
  final greenA = (colorA >> 8) & 0xFF;
  final blueA = colorA & 0xFF;

  // Extract the individual components of colorB
  final alphaB = (colorB >> 24) & 0xFF;
  final redB = (colorB >> 16) & 0xFF;
  final greenB = (colorB >> 8) & 0xFF;
  final blueB = colorB & 0xFF;

  // Convert the colors to HSV
  final hsvColorA = RGBtoHSV(redA, greenA, blueA);
  final hsvColorB = RGBtoHSV(redB, greenB, blueB);

  // Interpolate the HSV components
  int interpolatedHue = lerpInt(hsvColorA >> 16, hsvColorB >> 16, t);
  int interpolatedSaturation = lerpInt((hsvColorA >> 8) & 0xFF, (hsvColorB >> 8) & 0xFF, t);
  int interpolatedValue = lerpInt(hsvColorA & 0xFF, hsvColorB & 0xFF, t);

  // Convert the interpolated HSV color back to RGB
  return HSVtoRGB(alphaA, interpolatedHue, interpolatedSaturation, interpolatedValue);

}

int RGBtoHSV(int red, int green, int blue) {
  double r = red / 255.0;
  double g = green / 255.0;
  double b = blue / 255.0;

  double maxV = max(max(r, g), b);
  double minV = min(min(r, g), b);
  double delta = maxV - minV;

  double hue = 0.0;
  double saturation = 0.0;

  if (delta != 0) {
    if (maxV == r) {
      hue = 60 * (((g - b) / delta) % 6);
    } else if (maxV == g) {
      hue = 60 * (((b - r) / delta) + 2);
    } else {
      hue = 60 * (((r - g) / delta) + 4);
    }

    saturation = delta / maxV;
  }

  double value = maxV;

  // Pack the HSV components into a single integer
  int packedHSV = ((hue.round() & 0xFF) << 16) | ((saturation * 255).round() << 8) | (value * 255).round();

  return packedHSV;
}

int HSVtoRGB(int alpha, int hue, int saturation, int value) {
  double c = value / 255.0 * saturation / 255.0;
  double x = c * (1 - (((hue / 60) % 2) - 1).abs());
  double m = value / 255.0 - c;

  double r, g, b;

  if (0 <= hue && hue < 60) {
    r = c;
    g = x;
    b = 0;
  } else if (60 <= hue && hue < 120) {
    r = x;
    g = c;
    b = 0;
  } else if (120 <= hue && hue < 180) {
    r = 0;
    g = c;
    b = x;
  } else if (180 <= hue && hue < 240) {
    r = 0;
    g = x;
    b = c;
  } else if (240 <= hue && hue < 300) {
    r = x;
    g = 0;
    b = c;
  } else {
    r = c;
    g = 0;
    b = x;
  }

  int red = ((r + m) * 255).round();
  int green = ((g + m) * 255).round();
  int blue = ((b + m) * 255).round();

  return (alpha << 24) | (red << 16) | (green << 8) | blue;
}

int lerpInt(int a, int b, double t) {
  // Ensure the interpolation factor is within the valid range (0 to 1)
  double clampedT = t.clamp(0.0, 1.0);
  // Perform the linear interpolation between a and b
  return (a + ((b - a) * clampedT)).round();
}
