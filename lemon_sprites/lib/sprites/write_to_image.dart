import 'dart:typed_data';

import 'package:image/image.dart';

Image writeToImage({
  required int width,
  required int height,
  required Uint32List colors,
}) {
  if (width * height != colors.length) {
    throw Exception('size mismatch');
  }

  final image = Image(width: width, height: height);
  final pixel =  ColorInt32.rgba(0, 0, 0, 0);

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final index = y * width + x;
      final color = colors[index];
      pixel.r = color & 0xFF;
      pixel.g = (color >> 8) & 0xFF;
      pixel.b = (color >> 16) & 0xFF;
      pixel.a = (color >> 24) & 0xFF;
      image.setPixel(x, y, pixel);
    }
  }
  return image;

}
