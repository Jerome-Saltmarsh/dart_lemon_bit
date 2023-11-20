int merge32BitsColors3(int a, int b, int c) {
  // Extract the alpha, red, green, and blue components of each color.
  int alphaA = (a >> 24) & 0xFF;
  int redA = (a >> 16) & 0xFF;
  int greenA = (a >> 8) & 0xFF;
  int blueA = a & 0xFF;

  int alphaB = (b >> 24) & 0xFF;
  int redB = (b >> 16) & 0xFF;
  int greenB = (b >> 8) & 0xFF;
  int blueB = b & 0xFF;

  int alphaC = (c >> 24) & 0xFF;
  int redC = (c >> 16) & 0xFF;
  int greenC = (c >> 8) & 0xFF;
  int blueC = c & 0xFF;

  // Merge the components into a single color.
  int mergedColor = 0;

  mergedColor |= ((alphaA + alphaB + alphaC) ~/ 3) << 24;
  mergedColor |= ((redA + redB + redC) ~/ 3) << 16;
  mergedColor |= ((greenA + greenB + greenC) ~/ 3) << 8;
  mergedColor |= ((blueA + blueB + blueC) ~/ 3);

  return mergedColor;
}