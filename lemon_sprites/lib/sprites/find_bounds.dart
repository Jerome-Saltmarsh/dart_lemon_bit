
import 'package:image/image.dart';

int findBoundsLeft({
  required Image image,
  required int srcX,
  required int srcY,
  required int width,
  required int height,
}){
  final endX = srcX + width;
  final endY = srcY + height;
  for (var x = srcX; x < endX; x++) {
    for (var y = srcY; y < endY; y++) {
      if (image.getPixel(x, y).a > 0) {
        return x;
      }
    }
  }
  return -1;
}

int findBoundsRight({
  required Image image,
  required int srcX,
  required int srcY,
  required int width,
  required int height,
}){
  final endX = srcX + width;
  final endY = srcY + height;
  for (var x = endX - 1; x >= srcX; x--) {
    for (var y = srcY; y < endY; y++) {
      if (image.getPixel(x, y).a > 0) {
        return x;
      }
    }
  }
  return -1;
}

int findBoundsTop({
  required Image image,
  required int srcX,
  required int srcY,
  required int width,
  required int height,
}){
  final endX = srcX + width;
  final endY = srcY + height;
  for (var y = srcY; y < endY; y++){
    for (var x = srcX; x < endX; x++){
      if (image.getPixel(x, y).a > 0) {
        return y;
      }
    }
  }
  return -1;
}

int findBoundsBottom({
  required Image image,
  required int srcX,
  required int srcY,
  required int width,
  required int height,
}){
  final endX = srcX + width;
  final endY = srcY + height;
  for (var y = endY -1; y >= srcY; y--){
    for (var x = srcX; x < endX; x++){
      if (image.getPixel(x, y).a > 0) {
        return y;
      }
    }
  }
  return -1;
}