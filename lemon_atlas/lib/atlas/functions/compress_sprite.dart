

import 'package:image/image.dart';
import 'package:lemon_atlas/atlas/classes/sprite.dart';

void compressSprite(Sprite sprite) {

  final dst = sprite.dst;
  final image = sprite.image;

  final match = getMatch(
      image: image,
      width: dst[2],
      height: dst[3],
      ax: dst[0],
      ay: dst[1],
      bx: dst[4],
      by: dst[5],
  );

  print('match: $match');
}

double getMatch({
  required Image image,
  required int width,
  required int height,
  required int ax,
  required int ay,
  required int bx,
  required int by,
}){
  var matches = 0.0;
  var area = width * height;

  for (var x = 0; x < width; x++){
    for (var y = 0; y < height; y++){
      final a = image.getPixel(ax + x, ay + y);
      final b = image.getPixel(bx + x, by + y);
      matches += comparePixels(a, b);
    }
  }
  return matches / area;
}

double comparePixels(Pixel a, Pixel b) {
  final redDiff = (a.r - b.r).abs();
  final greenDiff = (a.g - b.g).abs();
  final blueDiff = (a.b - b.b).abs();
  final alphaDiff = (a.a - b.a).abs();
  final averageDiff = (redDiff + greenDiff + blueDiff + alphaDiff) / 4.0;
  final normalizedDiff = averageDiff / 255.0;
  return normalizedDiff;
}