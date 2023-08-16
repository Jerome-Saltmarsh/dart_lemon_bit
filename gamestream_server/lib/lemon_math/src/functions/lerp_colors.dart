
import 'color.dart';
import 'interpolate.dart';

int lerpColors(int colorA, int colorB, double t) {
  final alphaA = (colorA >> 24) & 0xFF;
  final redA = (colorA >> 16) & 0xFF;
  final greenA = (colorA >> 8) & 0xFF;
  final blueA = colorA & 0xFF;

  final alphaB = (colorB >> 16) & 0xFF;
  final redB = (colorB >> 16) & 0xFF;
  final greenB = (colorB >> 8) & 0xFF;
  final blueB = colorB & 0xFF;

  return aRGBToColor(
    interpolate(alphaA, alphaB, t).toInt(),
    interpolate(redA, redB, t).toInt(),
    interpolate(greenA, greenB, t).toInt(),
    interpolate(blueA, blueB, t).toInt(),
  );
}

