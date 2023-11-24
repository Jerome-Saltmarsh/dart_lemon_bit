
int interpolateByte(int byteA, int byteB, double i) {
  assert (i >= 0 && i <= 1);
  return (byteA + ((byteB - byteA) * i)).round();
}

int interpolateColors(int colorA, int colorB, double i) {
  assert (i >= 0 && i <= 1);

  final alphaA = (colorA >> 24) & 0xFF;
  final redA = (colorA >> 16) & 0xFF;
  final greenA = (colorA >> 8) & 0xFF;
  final blueA = colorA & 0xFF;

  final alphaB = (colorB >> 24) & 0xFF;
  final redB = (colorB >> 16) & 0xFF;
  final greenB = (colorB >> 8) & 0xFF;
  final blueB = colorB & 0xFF;

  final interpolatedAlpha = interpolateByte(alphaA, alphaB, i);
  final interpolatedRed = interpolateByte(redA, redB, i);
  final interpolatedGreen = interpolateByte(greenA, greenB, i);
  final interpolatedBlue = interpolateByte(blueA, blueB, i);

  return
    (interpolatedAlpha << 24) |
    (interpolatedRed << 16) |
    (interpolatedGreen << 8) |
    interpolatedBlue;
}