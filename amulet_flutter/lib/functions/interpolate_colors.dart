
int interpolateColors(int colorA, int colorB, double i) {
  if (i < 0.0 || i > 1.0) {
    throw ArgumentError('Parameter "i" must be between 0 and 1 inclusive.');
  }

  int redA = (colorA >> 16) & 0xFF;
  int greenA = (colorA >> 8) & 0xFF;
  int blueA = colorA & 0xFF;

  int redB = (colorB >> 16) & 0xFF;
  int greenB = (colorB >> 8) & 0xFF;
  int blueB = colorB & 0xFF;

  int interpolatedRed = (redA + (i * (redB - redA))).round();
  int interpolatedGreen = (greenA + (i * (greenB - greenA))).round();
  int interpolatedBlue = (blueA + (i * (blueB - blueA))).round();

  return (interpolatedRed << 16) | (interpolatedGreen << 8) | interpolatedBlue;
}