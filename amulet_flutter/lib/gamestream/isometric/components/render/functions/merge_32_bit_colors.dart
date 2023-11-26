int merge32BitColors(int a, int b) {

  final alphaA = (a >> 24) & 0xFF;
  final redA = (a >> 16) & 0xFF;
  final greenA = (a >> 8) & 0xFF;
  final blueA = a & 0xFF;

  final alphaB = (b >> 24) & 0xFF;
  final redB = (b >> 16) & 0xFF;
  final greenB = (b >> 8) & 0xFF;
  final blueB = b & 0xFF;

  final mergedAlpha = (alphaA + alphaB) ~/ 2;
  final mergedRed = (redA + redB) ~/ 2;
  final mergedGreen = (greenA + greenB) ~/ 2;
  final mergedBlue = (blueA + blueB) ~/ 2;

  return (mergedAlpha << 24) | (mergedRed << 16) | (mergedGreen << 8) | mergedBlue;
}
